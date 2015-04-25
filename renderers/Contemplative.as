package renderers {
	import com.invision.client.BasicRenderer;
	import com.invision.client.components.BasicButton;
    import com.invision.Core;
    import com.invision.CoreConstants;
	import com.invision.events.AudioEvent;
	import com.invision.interfaces.ISceneRenderer;
    import com.invision.Scene;
    import com.invision.ui.TextContainer;
    import com.invision.ui.ImageContainer;
    import com.invision.data.XMLUtility;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
    
    
    public class Contemplative extends BasicRenderer implements ISceneRenderer{

        private var mcContainer:MovieClip;
        private var mAnswerChecked:Boolean;
        private var mcAnswer:MovieClip;
        private var mcPrint:MovieClip;
        private var mCheckAnswer:String
        private var theDoc:XML;
        
        private var INSTRUCTION_TFIELD:String = "questionarea_mc";
        private var theInstructionField:TextField;    
        private var theText:String;
        private var printWindowContainer:MovieClip;    
		private var _checkAnswerBasicButton:BasicButton;
        
        private var mDefaultText:String = "Type your text here.";
		private var _printBasicButton:BasicButton;
        
        public function Contemplative() { }
        
        override public function startScene():void {
            super.startScene();
            mcContainer = content_mc;
            mcAnswer = content_mc.btnCheckAnswer;
			mcAnswer.visible = false;
            mcPrint = content_mc.btnPrintAnswer;
			mcPrint.visible = false;
            mAnswerChecked = false;
			var prop:XML;
			var sceneXML:XML = mScene.getXML();
			var resultsXML:XMLList = sceneXML.explore.question;			
			for each(prop in resultsXML) {
                if(prop.@["questiontext"] != undefined){
                    theText = prop.@["questiontext"];//Core.removeHTML(theTextNode.attributes["questiontext"]);
                    break;
                }
			}
            theInstructionField = content_mc.questionarea_mc.textbox;
			trace("ok1");
			var checkAnswerNode:XMLList = sceneXML.fillblank.question;
            mCheckAnswer = checkAnswerNode.@["casesensitive"];
            theInstructionField.htmlText = theText;
			trace("ok2");
			var tfield:TextField = content_mc.handheld_mc.textbox as TextField;
			tfield.selectable = true;
			tfield.type = "input";
			tfield.addEventListener(TextEvent.TEXT_INPUT, userInput, false, 0, true);
        }
        
        private function printAnswer(evt:MouseEvent):void {

            // change it
            trace("create page");
            var mcPrintJob:PrintJob = new PrintJob();
            if (mcPrintJob.start()) {
                try {
                    createPage(mcPrintJob.orientation);
                    var printRect:Rectangle = new Rectangle(0, 0, 740, 580);
					mcPrintJob.addPage(printWindowContainer,printRect);
                    //printWindowContainer.removeMovieClip();
                    //printWindowContainer.rotation = 0;
                }
                catch(e:Error) {
                    // handle error 
                    trace("error with printing"+ e.message);
                }
                mcPrintJob.send();
                content_mc.removeChild(printWindowContainer);
            }
			mcPrintJob = null;
        }
        
        private function createPage(mOrientation:String):void {

            // attach Print window to screen    
            printWindowContainer = new PrintWindow();
			printWindowContainer.name = "printWindow_mc";
			printWindowContainer.x = 0;// 1500;
			printWindowContainer.y = 0;// 1500;
            content_mc.addChild(printWindowContainer);
            if (mOrientation == "portrait") {
                // "landscape" not "portrait"
                // turn the image 90 degrees
                printWindowContainer.rotation = 90;
            }        
            // add text to text fields
            var mTField:TextField = printWindowContainer.questionarea_mc.textbox;
            var mFormat:TextFormat = mTField.getTextFormat();
            printWindowContainer.questionarea_mc.textbox.htmlText = theText;
            mTField.setTextFormat(mFormat);
            printWindowContainer.handheld_mc.textbox.text = Core.removeHTML(mcContainer.handheld_mc.textbox.htmlText);
            printWindowContainer.lessontitle_mc.textbox.htmlText =  Core.Modules.AdminDataModule.getTitle();
            printWindowContainer.date_mc.textbox.htmlText = Core.CourseTracking.getMonthDayYear();
            //
            printWindowContainer.bullet_mc.visible = false;
            printWindowContainer.textarea_mc.visible = false;
            addStaticBulletText();
			
        }    
        
        private function checkAnswer(evt:MouseEvent):void {

            // take feedback questions and bullets and add them to the screen
            mcContainer.handheld_mc.textbox.selectable = false;
            mcContainer.handheld_mc.textbox.type = "dynamic";
            var theText2:String;
			
			var prop:XML;
			var sceneXML:XML = mScene.getXML();
			var resultsXML:XMLList = sceneXML.explore.question;			
			for each(prop in resultsXML) {		
				if (prop.@["feedbacktext"] != undefined) {
					theText2 = prop.@["feedbacktext"];
                    break;
				}
			}
			
            var theInstructionField:TextField = mcContainer[INSTRUCTION_TFIELD].textbox;
            theInstructionField.htmlText = theText2;
            mcAnswer.visible = false;
            delete mcAnswer.onRelease;
            
            mTextContainer.clear();
            addStaticBulletCheckAnswer();
			mcPrint.visible = true;
            mcPrint.alpha = 1;
			_printBasicButton = new BasicButton("printReflective", mcPrint);
			_printBasicButton.addEventListener(MouseEvent.MOUSE_UP, printAnswer, false, 0, true);
			
			var hasAudio:Boolean = false;
			var questionArray:XMLList = sceneXML.audio.audiofile;			
			for each(prop in questionArray) {	
				var audioString:String = prop.@["audiofile2"];
				if (audioString != "") {
					trace("has audio file 2");
                    hasAudio = true;
					Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_PLAY_COMPLETE, onAudioPlayComplete, false,0,true);
                    Core.AudioObject.play(audioString,false);
                    break;
				}
			}
			
            // handle second closed captioning text
            // add the transcript and time markers, if they are defined
            //trace();
			var transcriptArray:XMLList = sceneXML.captioning.captionsfeedback;
            if (transcriptArray != null) {
                var transcriptText:String = transcriptArray.@["captiontext"];
                // separate out the lines of text - we need to use the \\r notation to unescape the special newline character and 
                // treat it as a string literal.
                var theText:String = transcriptText.split(String.fromCharCode(Keyboard.ENTER)).join("\\r");
                theText = theText.split(String.fromCharCode(10)).join("");
				var transcriptArray2:Array = theText.split("\\r");
                
    
                var markers:String = transcriptArray.@["captiontime"];
                markers = markers.split(" ").join("");
                var markerArray:Array = markers.split(",");
				
				
				
                if (transcriptArray2.length != markerArray.length) {
                    Core.log("ERROR in XMLManager.processXML(): number of transcript markers does not match number of lines of transcript text in scene " + sceneXML.@["id"]);
                }
                // we can't just use the straight text string that we read in - we have to create a new one by joining our array
                // of text lines back together with the escaped newline character.
                
                for (var j:Number = 0; j < markerArray.length; j++) {
                    trace("add caption event");
                    var time:Number = parseFloat(markerArray[j]);
                    mScene.addCaptionEvent(time, transcriptArray2[j]);
                }
                Core.CourseObject.getCaptionClip().setTranscript(transcriptArray2.join("\r"));//mScene.getTranscript());    
            }        
            
            //
            if (!hasAudio) {
                // set the page to complete and the 
                Core.Modules.updateCompletionBookmark();
                Core.getInstance().getScene().setVisited();
            }
            // complete page
        }
        
        private function onAudioPlayComplete(evt:Event) {
            trace("onAudioPlayComplete");
            Core.Modules.updateCompletionBookmark();
            Core.getInstance().getScene().setVisited();
        }
        private function userInput(evt:TextEvent):void {

            trace("userInput mCheckAnswer = "+mCheckAnswer+" mAnswerChecked = "+mAnswerChecked);
            if (mCheckAnswer == "sensitive" && !mAnswerChecked) {
				trace("show button");
                mAnswerChecked = true;
				mcAnswer.visible = true;
                mcAnswer.alpha = 1;
				_checkAnswerBasicButton = new BasicButton("reflectiveCheckAnswer", content_mc.btnCheckAnswer);
				_checkAnswerBasicButton.addEventListener(MouseEvent.MOUSE_UP, checkAnswer, false, 0, true);
            }
        }
        //------------------------------
        public function removeBullets():void {

            //--------------------------------
        }
        
        //------------------------------
        override public function endScene():void {
            super.endScene();
            reset();
        }
        
        override public function reset():void {
            super.reset();
            mcContainer.handheld_mc.textbox.text = mDefaultText;
            mTextContainer.clear();
            
            mcAnswer.visible = false;
            delete mcAnswer.onRelease;
            mcPrint.visible = false;
            delete mcPrint.onRelease;
        }    
        
        /*
        public function addBulletMC() {
            // find and set the bullet type
            var bulletType:XMLNode = XMLUtil.getMatchingNode(theDoc, "scene", "bulletsresponse", "bullettyperesponse");
            trace("scene renderer bullet type = " + bulletType.attributes["type"]);
            mTextContainer.setBulletType(parseInt(bulletType.attributes["type"]));
        }
        */
        //-----------------------------
        public function addStaticBulletText() {
            // create the bullets one by one
			var prop:XML;
			var sceneXML:XML = mScene.getXML();
			var bulletArray:XMLList = sceneXML.bulletsresponse.bulletresponse;	
			var xmlDescriptor:XMLList = sceneXML.bulletsresponse.bullettyperesponse;
			
            //var bulletArray:Array = XMLUtility.getMatchingNodes(theDoc, "scene", "bulletsresponse", "bulletresponse");
            //var xmlDescriptor:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "bulletsresponse", "bullettyperesponse");
            var bulletType:Number = parseInt(xmlDescriptor.@["type"]);
            bulletType = (isNaN(bulletType)) ? 1 : bulletType;
            var bulletTypeMarker:String;
            var mBulletMaster:MovieClip = printWindowContainer[CoreConstants.SYMBOL_BULLET];
            var mTextMaster:MovieClip = printWindowContainer["textarea_mc"];
            var mBulletOffsetX:Number = mTextMaster.x;
            var mBulletOffsetY:Number = mTextMaster.y;
            var mPositionY:Number = 0;
            var doFade:Boolean = false;
			var i:int = 0;
            for each(prop in bulletArray){
                var bulletNode:XML = prop;
                //mTextContainer.addBullet(bulletNode);
                var bulletString:String = Core.removeHTML(XMLUtility.innerText(bulletNode));
                bulletTypeMarker = bulletNode.@["marker"];
                if (bulletString != "undefined") {
					i++;
                    //add text and bullets
					var mcText:MovieClip = new printwindow_textarea_mc();
					mcText.name = "mText" + i;
					mcText.x = mBulletOffsetX;
					mcText.y = mPositionY + mBulletOffsetY;
					mcText.alpha = (doFade) ? 0 : 1;
					printWindowContainer.addChild(mcText);      
                    mcText.textbox.text = bulletString;
                    mcText.textbox.autoSize = TextFieldAutoSize.LEFT;
                    //---------------------
                    if (bulletTypeMarker == "true") {
                        // position it according to the bullet offset and if this bullet is to be faded in, set the alpha to 0
                        var mcBullet:MovieClip = new BulletView();
						mcBullet.x = mBulletMaster.x;
						mcBullet.y = mPositionY + mBulletOffsetY +4;
						mcBullet.alpha = (doFade) ? 0 : 1;
						printWindowContainer.addChild(mcBullet);
                        mcBullet.gotoAndStop(bulletType);
                    }
                    mPositionY += mcText.height;                
                    //
    
                }
            }        
        }
        
        public function addStaticBulletCheckAnswer() {
            addBulletMC();
			
			var prop:XML;
			var sceneXML:XML = mScene.getXML();
			var bulletArray:XMLList = sceneXML.bulletsresponse.bulletresponse;	
			var xmlDescriptor:XMLList = sceneXML.bulletsresponse.bullettyperesponse;
			
            // create the bullets one by one
            //var bulletArray:Array = XMLUtility.getMatchingNodes(theDoc, "scene", "bulletsresponse", "bulletresponse");
            //var xmlDescriptor:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "bulletsresponse", "bullettyperesponse");
            var bulletType:Number = parseInt(xmlDescriptor.@["type"]);
            bulletType = (isNaN(bulletType)) ? 1 : bulletType;
            mTextContainer.setBulletType(bulletType);
            for each(prop in bulletArray){
                var bulletNode:XML = prop;
                
                mTextContainer.addBullet(bulletNode,false);
                //var bulletString:String = Core.removeHTML(XMLUtility.innerText(bulletNode));
            }        
        }        
        
    } 
}
