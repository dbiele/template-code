package components {
	import com.invision.client.components.events.CDLoginEvent;
	import com.invision.client.components.views.CDError;
	import com.invision.client.components.views.CDLogin;
	import com.invision.client.components.views.CDRegister;
	import com.invision.client.components.views.CDRegistrationIntro;
	import com.invision.client.Course;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.system.fscommand;
	import flash.system.System;
    
    import com.invision.Core;
    import com.invision.CoreConstants;
    
    import com.invision.client.components.NavButton;
    
    import com.invision.data.XMLUtility;
    
    import com.invision.ui.Popup;
    import com.invision.interfaces.IPopup;
    
    import com.invision.data.CustomTracking;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
    
    
    public class CDLoginWindow extends Popup implements IPopup {
		
        
        private var FRAME_TRYAGAIN:Number = 4;
        private var FRAME_YES:Number = 3;
        private var FRAME_NO:Number = 2;
        
        private var login_mc:MovieClip;
        private var mLoginButton:NavButton;
        private var mRegisterButton:NavButton;
        private var mSubmitButton:NavButton;
        private var mBackButton:NavButton;
        private var mExitButton:NavButton;
        
        private var mYesButton:NavButton;
        private var mNoButton:NavButton;
        private var mSubmitButton2:NavButton;
        private var mLoadButton:NavButton;
        private var mTryAgainButton:NavButton;
        private var mStartOverButton:NavButton;
        
        private var mDoc:XML;
        
        private var mUserNode:XML;
		
		public var CDIntro:CDRegistrationIntro;
		public var registerMC:CDRegister;
		public var loginMC:CDLogin;
		public var errorMC:CDError;
		
		public var background_mc:MovieClip;
        
        public function CDLoginWindow() {
			stop();
            addEventListener(Event.REMOVED_FROM_STAGE, onMemoryCleanUp);
			Core.getStage().addEventListener(Event.RESIZE, resizeBackgroundCover, false, 0, true);
			resizeBackgroundCover();
			background_mc.useHandCursor = false;
			background_mc.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void { } );
			background_mc.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void { } );
			
			mDoc = Core.CourseTracking.getSharedObject();
			CDIntro.initialize(this);
        }
		
		private function resizeBackgroundCover(event:Event = null):void {
			trace("resizeBackgroundCover called");
			if(!Core.CourseObject.getStubComplete()){
				var offset:Number = (Course.COURSE_WIDTH - Core.getStage().stageWidth)/2;
				background_mc.width = Core.getStage().stageWidth;
				background_mc.height = Core.getStage().stageHeight;
				background_mc.x = offset;
			}else{
				var currentWidth:Number = (Course.COURSE_WIDTH * Core.CourseObject.getScale());
				var currentHeight:Number = (Course.COURSE_HEIGHT * Core.CourseObject.getScale());
				var increment:Number = Course.COURSE_WIDTH / currentWidth;
				var incrementHeight:Number = Course.COURSE_HEIGHT / currentHeight;
				var offsetX:Number = (currentWidth - Core.getStage().stageWidth) / 2;
				var offsetY:Number = (currentHeight - Core.getStage().stageHeight) / 2;
				background_mc.x = increment * offsetX;
				background_mc.y = increment * offsetY;
				background_mc.width = Core.getStage().stageWidth * increment;
				background_mc.height = Core.getStage().stageHeight * incrementHeight;
			}
		}
		
		private function onMemoryCleanUp(evt:Event):void {
		
			trace("onMemoryCleanUp");
			Core.getStage().removeEventListener(Event.RESIZE, resizeBackgroundCover);
			background_mc.removeEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void { } );
			background_mc.removeEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void { } );
			
		}
		
		public function gotoFrame(frameTo:String):void 
		{
			switch(frameTo) {
				case "register":
					gotoAndStop(frameTo);
					registerMC.initialize(this);
					break;
				case "login":
					gotoAndStop(frameTo);
					loginMC.initialize(this);
					break;
				case "error":
					gotoAndStop(frameTo);
					errorMC.initialize(this);
					break;
				default:
					//none
					break;
			}
		}
        
        private function restrictValues(){
            //login_mc.set_textbox_firstname.tfield.restrict = "^\u0020";
            //login_mc.set_textbox_lastname.tfield.restrict = "^\u0020";
        }
        
        public function verifyUser(firstname:String,lastname:String,companyid:String,unitedid:String):void {
            trace("verifyUser");
			firstname = firstname.replace(/^\s+|\s+$/gs, '');
			lastname = lastname.replace(/^\s+|\s+$/gs, '');
            var firstName:String = firstname.toLowerCase();
            var lastName:String = lastname.toLowerCase();
            var companyID:String = companyid;
            var unitedID:String = unitedid;
			
			var errorString:String = "";
            
            var userNodes:XMLList = mDoc.user;
            
            if (firstName == "" || lastName == "") {
                errorString = "Please enter your full name.";
            } else if (unitedID != "" && companyID != "") {
                errorString = "Please enter either a Company ID or a United ID.";  
            } else if (companyID != "") {
                errorString = "The supplied user information was not found on this computer.";
				trace("check company id");
				trace("userNodes = " + userNodes.toXMLString());
                for each(var user:XML in userNodes) {     
                    var userFirstName:String = user.@["firstname"].toLowerCase();
                    var userLastName:String = user.@["lastname"].toLowerCase();
                    if (user.@["companyID"] == companyID && userLastName == lastName && userFirstName == firstName) {
						mUserNode = user;
                    }
                }
            } else if (unitedID != "") {
                errorString = "The supplied user information was not found on this computer.";
                for each(var userXML:XML in userNodes) {           
                    var userXMLFirstName:String = userXML.@["firstname"].toLowerCase();
                    var userXMLLastName:String = userXML.@["lastname"].toLowerCase();
                    if (userXML.@["continentalID"] == unitedID && userXMLLastName == lastName && userXMLFirstName == firstName) {
                        mUserNode = userXML;
                    }
                }
            } else {
               errorString = "Please enter either a Company ID or a Continental ID.";	
            }
            
            if (mUserNode != null) {
                launch();
            } else {
				var dispatchCDEvent:CDLoginEvent = new CDLoginEvent(CDLoginEvent.REGISTER_ERROR);
				dispatchCDEvent.errorDescription = errorString;
				dispatchEvent(dispatchCDEvent);
				// The error string is passed.  user is notified.  they now must do resubmit or leave.  
            }
        }
        
        public function onExit() {
			if (ExternalInterface.available) {
				Core.getInstance().closeWindow();
			}else {
				fscommand("quit");
			}
        }
        
        public function addUser(firstname:String,lastname:String,companyid:String,unitedid:String, stationID:String, companyname:String):Boolean {
            var hasError:Boolean = false;
			try {
                var userNodes:XMLList = mDoc.user;
                
                var userNode:XML = <user/>;
                
				firstname = firstname.replace(/^\s+|\s+$/gs, '');
				lastname = lastname.replace(/^\s+|\s+$/gs, '');
				
                var unitedID:String = unitedid;
                var companyID:String = companyid;
                var firstName:String = firstname.toLowerCase();
                var lastName:String = lastname.toLowerCase();
				var stationID:String = stationID;
				var company_name:String = companyname;
            
                // check if the id exists already
                if (firstName == "") {
                    throw new Error("You must enter your first name.");
                }            
        
                if (lastName == "") {
                    throw new Error("You must enter your last name.");
                }                
                
                if (companyID == "" && unitedID == "") {
                    throw new Error("You must enter your Company ID or an assigned Continental ID.");
                }
                
                if(companyID != "" && unitedID != "") {
                    throw new Error("Add only one Company ID or an assigned Continental ID. Do not add both.");
                }
                
                for each(var item:XML in userNodes){  
                    // check if first name, last name and companyID or continentalID already exist.
                    if(item.@["firstname"] == firstName && item.@["lastname"] == lastName 
						&& ((item.@["continentalID"] == unitedID) || (item.@["companyID"] == companyID))){
                        throw new Error("A user with the specified information already exists in the system.");
                    }
                }
                if (mUserNode == null) {
                    // write the values
                    addAttribute(userNode, "firstname", "your full name", firstName);
                    addAttribute(userNode, "lastname", "your full name", lastName);
                    addAttribute(userNode, "companyID", "your Company ID or your assigned Continental ID", companyID, false);
                    addAttribute(userNode, "continentalID", "your Company ID or your assigned Continental ID", unitedID, false);
                    addAttribute(userNode, "stationID", "your Station ID", stationID);
                    addAttribute(userNode, "company", "your Company Name", company_name);
    
					mDoc.users += userNode;
					trace("mDoc.users = " + mDoc.user.toXMLString());
					for each(var itemXML:XML in mDoc.user) {
						trace("item = " + itemXML.toXMLString());
						if (itemXML == userNode) {
							mUserNode = itemXML;
						}
					}
					//mUserNode = mDoc.users.user.(@firstname == firstName && @lastname == lastName && @companyID == companyID && @continentalID == unitedID && @stationID == stationID && company == company_name);
					//userNode
					trace("mUserNode xml = " + mUserNode.toXMLString());
					hasError = Core.CourseTracking.setSharedObject();
                }
            } catch (e:Error) {
				var dispatchCDEvent:CDLoginEvent = new CDLoginEvent(CDLoginEvent.REGISTER_ERROR);
				dispatchCDEvent.errorDescription = e.message;
				dispatchEvent(dispatchCDEvent);
				hasError = true;
            }
			if (!hasError) {
				launch();
			}
			return hasError;
        }
        
        private function addAttribute(node:XML, attributeName:String, attributeDesc:String, attributeValue:String, errorIfBlank:Boolean = true) {
            if (attributeValue != "" || !errorIfBlank) {
                node.@[attributeName] = attributeValue;
            } else {
                throw new Error ("You must enter " + attributeDesc + ".");
            }
        }
        
        private function getModuleNode():XML {
            var moduleNode:XML;
			var hasError:Boolean;
            var bFound:Boolean = false;
            var nodes:XMLList = mUserNode.module;
            for each(var item:XML in nodes){
                if (item.@["id"] == Core.Modules.AdminDataModule.getID()) {
					moduleNode = item;
                    bFound = true;
                    break;
                }
            }
            if (!bFound) {
				trace("module not found");
                moduleNode = <module/>;
                moduleNode.@["id"] = Core.Modules.AdminDataModule.getID();
                moduleNode.@["empNum"] = mUserNode.@["companyID"];
                moduleNode.@["bookmark"] = "";
                moduleNode.@["failures"] = 0;
                mUserNode.appendChild(moduleNode);
				hasError = Core.CourseTracking.setSharedObject();         
            }
            return moduleNode;
        }
        
        private function launch() {
            var moduleNode:XML = getModuleNode();
            // add the mDoc to the tracker
			Core.CourseTracking.setCDUserXML(mUserNode);
			Core.CourseTracking.setCDDataXML(moduleNode);
            // set the bookmark
			trace("cd login bookmark information = " + moduleNode.@["bookmark"]);
            Core.Modules.setBookmark(moduleNode.@["bookmark"]);
			
			Core.Popups.closeDialog(this.getID());
			/*
			if (!Core.getInstance().isDebugEnabled()) {
				Core.CourseObject.initializeCourse();
				Core.CourseObject.startCourse();
			}else {
				Core.CourseObject.startPlayingCourse();
			}
			*/
			if (Core.getInstance().isDebugEnabled()) {
				Core.CourseObject.initializeCourse();
				Core.CourseObject.startCourse();
			}else {
				Core.CourseObject.startPlayingCourse();
			}
			trace("Core.getInstance().isDebugEnabled() = " + Core.getInstance().isDebugEnabled());
			//
			
        }
    }
}
