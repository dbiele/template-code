package renderers {
	import com.invision.client.BasicRenderer;
    import com.invision.Core;
    import com.invision.CoreConstants;
	import com.invision.interfaces.ISceneRenderer;
    import com.invision.ui.TextContainer;
    import com.invision.ui.ImageContainer;
    import com.invision.data.XMLUtility;
    import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
    
    
    public class ContemplativePrint extends BasicRenderer implements ISceneRenderer{

        
        private var mcContainer:MovieClip;
        private var mAnswerChecked:Boolean;
        private var mcAnswer:MovieClip;
        private var theDoc:XML;
        
        private var INSTRUCTION_TFIELD:String = "questionarea_mc";
        private var theInstructionField:TextField;
        private var printWindowContainer:MovieClip;
        private var mParagraphText:String;    
        private var theText:String;
        
        public function ContemplativePrint() { }
        
        public function startScene() {
            super.startScene();
            mcContainer = this["content_mc"];
            mcAnswer = mcContainer.btnCheckAnswer;
            mAnswerChecked = false;
            //mcContainer = content_mc
            theDoc = mScene.getXML();
            var theTextNode:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "explore", "question");
            theText = theTextNode.attributes["questiontext"];
            theInstructionField = mcContainer[INSTRUCTION_TFIELD].textbox;
            var checkAnswerNode:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "fillblank", "question");
            
            theInstructionField.htmlText = theText;
            
            mcContainer.handheld_mc.textbox.onChanged = Delegate.create(this, userInput);
        }
        
        private function printAnswer():void {

            // change it
            trace("create page");
            var mcPrintJob:PrintJob = new PrintJob();
            
            createPage(mcPrintJob.orientation);    
            if (mcPrintJob.start()) {
                try {
                    createPage(mcPrintJob.orientation);                
                    //mcPrintJob.addPage(printWindowContainer, { xMin:63, xMax:943, yMin:48, yMax:620 }, null, 1);
                    mcPrintJob.addPage(printWindowContainer, { xMin:0, xMax:740, yMin:0, yMax:580 }, null, 1);
                    printWindowContainer.removeMovieClip();
                    printWindowContainer._rotation = 0;
                }
                catch(e:Error) {
                    // handle error 
                    trace("error with printing");
                }
                mcPrintJob.send();
                
            }
            delete mcPrintJob;
        }
        
        private function createPage(mOrientation:String):void {

            // attach Print window to screen    
            trace("createPage = " + createPage);
            printWindowContainer = mcContainer.attachMovie("PrintWindow", "printWindow_mc", mcContainer.getNextHighestDepth(), { _x:-1500, _y:-1500 } );
            
            if (mOrientation == "portrait") {
                // "landscape" not "portrait"
                // turn the image 90 degrees
                printWindowContainer._rotation = 90;
            }        
            // add text to text fields
            var mTField:TextField = printWindowContainer.questionarea_mc.textbox;
            var mFormat:TextFormat = mTField.getTextFormat();
            printWindowContainer.questionarea_mc.textbox.htmlText = theText;
            mTField.setTextFormat(mFormat);
            printWindowContainer.handheld_mc.textbox.text = Core.removeHTML(mcContainer.handheld_mc.textbox.htmlText);
            printWindowContainer.lessontitle_mc.textbox.htmlText =  Core.Module.AdminData.getTitle();
            printWindowContainer.date_mc.textbox.htmlText = Core.CourseTracking.getMonthDayYear();
            //
            printWindowContainer.bullet_mc._visible = false;
            printWindowContainer.textarea_mc._visible = false;
            addStaticBulletText();
            //printWindowContainer.textarea_mc.textbox.text = mParagraphText;
        }    
        
        private function userInput():void {

            if (!mAnswerChecked) {
                mAnswerChecked = true;
                mcAnswer._alpha = 100;
                mcAnswer.onRelease = Delegate.create(this, printAnswer);
            }
        }
        //------------------------------
        public function removeBullets():void {

            //--------------------------------
        }
        
        //-----------------------------
        public function addStaticBulletText() {
            // adds the text and bullets into the print screen
            mBulletMaster._visible = false;
            mParagraphText = "";
            // create the bullets one by one
            var bulletArray:Array = XMLUtility.getMatchingNodes(theDoc, "scene", "bullets", "bullet");
            var xmlDescriptor:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "bullets", "bullettype");
            var bulletType:Number = parseInt(xmlDescriptor.attributes["type"]);
            bulletType = (isNaN(bulletType)) ? 1 : bulletType;
            var bulletTypeMarker:String;
            var mBulletMaster:MovieClip = printWindowContainer[CoreConstants.SYMBOL_BULLET];
            var mTextMaster:MovieClip = printWindowContainer["textarea_mc"];
            var mBulletOffsetX:Number = mTextMaster._x;
            var mBulletOffsetY:Number = mTextMaster._y;
            var mPositionY:Number = 0;
            var doFade:Boolean = false;
            for (var i:Number = 0; i < bulletArray.length; i++) {
                var bulletNode:XMLNode = XMLNode(bulletArray[i]);
                //mTextContainer.addBullet(bulletNode);
                var bulletString:String = Core.removeHTML(XMLUtility.innerText(bulletNode));
                bulletTypeMarker = bulletNode.attributes["marker"];
                if (bulletString != "undefined") {
                    //textarea_mc
                    var mcText:MovieClip = mTextMaster.duplicateMovieClip("mText" + i, printWindowContainer.getNextHighestDepth(), { _x:mBulletOffsetX, _y:mPositionY + mBulletOffsetY, _alpha:(doFade) ? 0 : 100});        
                    mcText.textbox.text = bulletString;
                    mcText.textbox.autoSize = true;
                    //---------------------
                    if (bulletTypeMarker == "true") {
                        // position it according to the bullet offset and if this bullet is to be faded in, set the alpha to 0
                        var mcBullet:MovieClip = mBulletMaster.duplicateMovieClip("bullet" + i, printWindowContainer.getNextHighestDepth(), { _x:mBulletMaster._x, _y:mPositionY + mBulletOffsetY +4, _alpha:(doFade) ? 0 : 100});
                        mcBullet.gotoAndStop(bulletType);
                    }
                    mPositionY += mcText._height;                
                    //
    
                }
            }        
        }        
    } 
}
