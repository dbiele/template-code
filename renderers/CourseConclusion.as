package renderers {
	import com.invision.client.BasicRenderer;
	import com.invision.client.components.BasicButton;
	import com.invision.client.renderers.view.CDPrintPage;
    import com.invision.Core;
    import com.invision.client.ProgramConstants;
    import com.invision.client.components.NavButton;
	import com.invision.data.EncryptDecrypt;
	import com.invision.data.events.CourseTrackingEvent;
    import com.invision.data.XMLUtility;
    import com.invision.data.List;
	import com.invision.interfaces.ISceneRenderer;
    import com.invision.interfaces.ISequence;
    import com.invision.CoreConstants;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.xml.XMLNode;
    
    import flash.display.MovieClip;
    
    
    public class CourseConclusion extends BasicRenderer implements ISceneRenderer{

    
        private var DEFAULT_MESSAGE_FAIL:String = "You have failed the Final Assessment for this course. From here, you must repeat the test in order to pass this course.  ";    
        
        //private var content_mc:MovieClip
        private var mDate:String
        private var mName:String
        private var mCourse:String
        private var mBeginSurveyButton:NavButton;
        private var mSendMailButton:NavButton;    
        private var errorWindow:MovieClip;
        private var responseType:String;
        private var theURLString:String;
        private var mScore:Number;
		private var _triesRemainTotal;
		private var _triesRemain:int;
		private var _triedCurrent;
		private var printBasicButton:BasicButton
        
        public function CourseConclusion() { 
		}
        
        override public function startScene():void {
            super.startScene();
			content_mc.cd_instruction_tfield.visible = false;
			content_mc.btnPrint.visible = false;
			content_mc.addFrameScript(1, addIncorrectText);
			
            if (Core.Modules.AssessmentModule.getAssessmentQuestionCount() != 0) {
				trace("has assessment");
				 // the course contains an assessment
                mScore = Math.round(Core.Modules.AssessmentModule.getScore());
				trace("Core.CourseTracking.getCourseComplete() = " + Core.CourseTracking.getStatus());
                if (Core.CourseTracking.getStatus() != CourseTrackingEvent.STATUS_PASSED) {
					trace("failed course");
                    content_mc.gotoAndStop(2);
                   // captions are added with frame script
					if (Core.getInstance().getScene().getXML().audio.audiofileincorrect.hasOwnProperty("@audio")) {
						Core.AudioObject.play(Core.getInstance().getScene().getXML().audio.audiofilecorrect.@audio, true);
						Core.CourseObject.manualCaption("captionsincorrect");
					}
					addInformationTextField();
                }else {
					trace("pass course");
					if (Core.getInstance().getScene().getXML().audio.audiofilecorrect.hasOwnProperty("@audio")) {
						Core.AudioObject.play(Core.getInstance().getScene().getXML().audio.audiofilecorrect.@audio, true);
						Core.CourseObject.manualCaption("captionscorrect");
					}
                    Core.Modules.updateCompletionBookmark();
                    Core.getInstance().getScene().setVisited();
					checkCDVersion();
                    addCorrectText();
					addInformationTextField();
                }
            }else {    
                
                Core.Modules.updateCompletionBookmark();
                Core.getInstance().getScene().setVisited();            
    
                var mSequenceList:List;
                //var hasAssessment:Boolean = false;
                var sequenceVisited:Boolean = true;
                mSequenceList = Core.Modules.getSequenceList();
                
                for (var i:Number = 0; i < mSequenceList.getCount(); i++) {
                    var sItem:String = mSequenceList.getItem(i);
                    var seqItem:ISequence = Core.Modules.getSequence(sItem);
                    //if (seqItem.getType() == CoreConstants.SEQUENCE_TYPE_ASSESSMENT) { hasAssessment = true; }
                    sequenceVisited = (sequenceVisited && (seqItem.getStatus() == CoreConstants.SEQUENCE_STATUS_COMPLETE));
                }            
                
                // the course does not contain an assessment
                if (sequenceVisited) {
                    // user has completed all of the course
					checkCDVersion();
                    addCorrectText();
					addInformationTextField();
                }else {
					addInformationTextField();
                    content_mc.gotoAndStop(2);
                    addIncorrectText();
                }
            }
        }
		
		private function checkCDVersion(){
			var courseType:String = Core.Modules.AdminDataModule.getCourseType();	
			if(courseType == "cd"){
				generatePrintAssets()
			}
		}
		
    	private function generatePrintAssets() {
			content_mc.cd_instruction_tfield.visible = true;
			content_mc.btnPrint.visible = true;
			
			var theDoc:XML = mScene.getXML();
			var theTextNode:XMLList = theDoc.assessmentconclusion.assessment;
			var courseInstructions:String = theTextNode.@["cd_instruction"];
			printBasicButton = new BasicButton("print", content_mc.btnPrint);
			var instructionTextField:TextField = content_mc.cd_instruction_tfield;
			var updatedYPosition:Number = (content_mc.coursepass_mc.y + content_mc.coursepass_mc.height)+20;
			printBasicButton.y = updatedYPosition;
			instructionTextField.y = updatedYPosition;
			instructionTextField.autoSize = TextFieldAutoSize.LEFT;
			instructionTextField.htmlText = courseInstructions;
			printBasicButton.addEventListener(MouseEvent.MOUSE_UP, printCD, false, 0, true);
		}
		
		public function printCD(evt:MouseEvent){
            var mcPrintJob:PrintJob = new PrintJob();
			var hasError:Boolean = false;
			var errorMessage:String = "";
            if (mcPrintJob.start()) {
                try {
					var printMC:MovieClip = Core.getInstance().getSceneContainer();
					var printWindow:CDPrintPage = new CDPrintPage();
					printWindow.x = -3000;
					printWindow.y = -3000;
					printWindow.instruction_txt.htmlText = Core.Modules.AdminDataModule.getInstructions();
					var userXML:XML = Core.CourseTracking.getCDUserXML();
					if(userXML  != null){
						printWindow.lastname_txt.text = userXML.@lastname;
						printWindow.firstname_txt.text = userXML.@firstname;
						printWindow.companyname_txt.text = userXML.@company;
						printWindow.stationid_txt.text = userXML.@stationID;
						printWindow.companyid_txt.text = userXML.@companyID;
						printWindow.continantalid_txt.text = userXML.@continentalID;
						printWindow.programname_txt.text = Core.Modules.AdminDataModule.getTitle();
						printWindow.score_txt.text = mScore.toString();
						printWindow.versionnumber_txt.text = Core.Modules.AdminDataModule.getVersion();
						printWindow.date_txt.text = Core.CourseTracking.getDateTime();
						printMC.addChild(printWindow);					
						
						var printRect:Rectangle = new Rectangle(0, 0, 740, 580);
						mcPrintJob.addPage(printWindow, printRect);
					}else {
						// no data was not found.  Error retrieving data from flash saved XML.
						hasError = true;
						errorMessage = "No CD user xml data found.";
					}
                }
                catch(e:Error) {
                    // handle error 
					errorMessage = e.message;
					hasError = true;
                }
				if(!hasError){
					mcPrintJob.send();
					printMC.removeChild(printWindow);
				}else {
					// problem has occured.
					Core.CourseObject.showErrorMessage("Unable to print information.  Error: " + errorMessage);
				}
            }
			mcPrintJob = null;
		}
		
		private function generateCourseCode() {
			var userData:String = Core.CourseTracking.getEmployeeNumber()+","+Core.CourseTracking.getCourseID()+","+Core.CourseTracking.getCredit()+","+mScore+","+Core.CourseTracking.getResults();
			var edKey = "invisionLearning";
			var cipher = new EncryptDecrypt();
			cipher.setMap("H8AJzaij0pV7_Qhn{vwtl\"(,`~D>m\O:W]4L6u1.Zb/I[$dCGE9&%TB#Ske5@?*xPU)=}' M^c;YK!q2|rgsRo<Nyf+-3XF");
			return cipher.encrypt(userData, edKey);
		}		
		
		
        public function addIncorrectText():void{
			trace("addIncorrectText");
            var theDoc:XML = mScene.getXML();
            var theTextNode:XMLList = theDoc.assessmentconclusion.assessment;
			trace("add text incorrect = "+theTextNode.toXMLString());

			var sVal:String
			var failureResponseType:int = calculateFailures();
			trace("failureResponseType = " + failureResponseType);
			switch(failureResponseType){
				case 1:
					sVal = theTextNode.@["failmessage_1"];
					break;
				case 2:
					sVal = theTextNode.@["failmessage_2"];
					break;
				case 3:
					sVal = theTextNode.@["failmessage_3"];
					break;
				default:
					break;
			}
			
			// create an array to split the string into parts and add attempt values
			var stringArray:Array = new Array()
			stringArray = sVal.split("[1]");
			if(stringArray.length > 1){
				sVal = stringArray[0]+_triedCurrent+stringArray[1];
			}
			stringArray = sVal.split("[2]");
			if(stringArray.length > 1){
				sVal = stringArray[0]+_triesRemain+stringArray[1];
			}
			stringArray = sVal.split("[3]");
			if(stringArray.length > 1){
				sVal = stringArray[0]+_triesRemainTotal+stringArray[1];
			}
			trace("incorrect text sVal = " + sVal);
            
			content_mc.coursefail_mc.textbox.htmlText = sVal;
        }
		
        private function addCorrectText(){
            var theDoc:XML = mScene.getXML();
			var theTextNode:XMLList = theDoc.assessmentconclusion.assessment;
            //var theTextNode:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "assessmentconclusion", "assessment");
			var correctString:String = theTextNode.@["coursecomplete_pass"]
			trace("correctString = " + correctString);
			if (correctString != "") {
				trace("add correct text correctString = "+content_mc.coursepass_mc.textbox.text);
				content_mc.coursepass_mc.textbox.htmlText = correctString;
			}
        }
		
		private function addInformationTextField():void {
			// displays the users employee number and encoded information in text field.
			content_mc.employeeinfo_tfield.text = "Employee Number:" + Core.CourseTracking.getEmployeeNumber()+"\nCode:"+Core.CourseTracking.getEncryptData();
		}
		
		private function calculateFailures():int {
			var theDoc:XML = mScene.getXML();
			var theTextNode:XMLList = theDoc.assessmentconclusion.assessment;
			
			var maxsets:Number = parseFloat(theTextNode.@["maxsets"]);
			var maxattempts:Number = parseFloat(theTextNode.@["maxattempts"]);
			if (isNaN(maxattempts)) { maxattempts = 0; }
			
			var limits:Number = parseFloat(theTextNode.@["limit"]);
			
			var failureNum:int = Core.CourseTracking.getFailures()+1;
			
			var setNum:Number = Math.ceil(failureNum/maxsets);
			_triesRemainTotal = maxattempts//(maxattempts*maxsets)-failureNum;
			_triesRemain = (maxattempts*setNum)-failureNum;
			_triedCurrent = failureNum - (maxattempts * (setNum - 1));
			
			trace("limits = " + limits);
			trace("maxsets = " + maxsets);
			trace("maxattempts = " + maxattempts);
			trace("failureNum = " + failureNum);
			trace("_triesRemain = " + _triesRemain);
			var mFailureTypes:int = 0;
			if (limits == 0 || isNaN(limits)) {
				//Unlimited number of attempts show the standard failure screen
				mFailureTypes = 1;
			}else if (_triesRemain == 0 && setNum == maxsets) {
				// 			The number of test has hit it's max
				mFailureTypes = 3;
			} else if (_triesRemain == 0) {
				//			You have hit the max number for the sets.  
				//			The course is inactive for 5 days.
				mFailureTypes = 2;
			} else {
				//			Standard failure screen
				mFailureTypes = 1;
			}
			//Core.CourseTracking.sendFailures(failureNum)
			trace("mFailureTypes = " + mFailureTypes);
			return mFailureTypes;
		}	
        
    } 
}
