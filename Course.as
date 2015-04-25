package  {
	
	import com.invision.client.components.CDLoginWindow;
	import com.invision.client.controllers.ProgressIndicatorController;
	import com.invision.client.model.OutlineModel;
	import com.invision.client.model.ProgressIndicatorModel;
	import com.invision.client.renderers.LessonSummary;
	import com.invision.client.views.BackgroundView;
	import com.invision.client.views.ProgressIndicatorView;
	import com.invision.data.CourseDataTracking;
	import com.invision.data.events.CourseTrackingEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.xml.XMLNode;
    import flash.geom.Transform;
    import flash.external.*;
	import flash.geom.ColorTransform;

    import com.invision.Core;
	
    import com.invision.interfaces.IPopup;
	import com.invision.utils.KeyListener;
	import com.invision.events.AudioEvent;
	import com.invision.module.Assessment;
    import com.invision.interfaces.ISequence;
    import com.invision.ui.PopupManager;
	import com.invision.CoreConstants;
	import com.invision.Audio;
	import com.invision.Scene;
    
    import com.invision.client.components.AudioPreloaderWindow;
    import com.invision.client.components.NavigationWindow;
	import com.invision.client.components.TranscriptWindow;
    import com.invision.client.components.ErrorWindow;
	
	import com.invision.client.renderers.Introduction;
	import com.invision.client.renderers.LessonComplete
	import com.invision.client.renderers.LessonObjectives;
	import com.invision.client.renderers.LessonOverview;
	import com.invision.client.renderers.ImageHalfCircle;
	import com.invision.client.renderers.ImageTop;
	import com.invision.client.renderers.ImageBottom;
	import com.invision.client.renderers.ImageLeft;
	import com.invision.client.renderers.ImageRight;
	import com.invision.client.renderers.ImageFullScreen;
	import com.invision.client.renderers.VideoPlayer;
	import com.invision.client.renderers.ClickToLearn;
	import com.invision.client.renderers.Contemplative;
	import com.invision.client.renderers.JobAid;
	import com.invision.client.renderers.MultipleChoice;
	import com.invision.client.renderers.FillInTheBlank;
	import com.invision.client.renderers.Explore;
	import com.invision.client.renderers.DragDrop;
	import com.invision.client.renderers.DragDropV2;
	import com.invision.client.renderers.RankOrder;
	import com.invision.client.renderers.RankOrderImage;
    import com.invision.client.renderers.FinalTestIntro;
    import com.invision.client.renderers.FinalTestSubmit;
    import com.invision.client.renderers.FinalTestResults;
	import com.invision.client.renderers.CourseConclusion;
	import com.invision.client.renderers.TrueFalse;
	import com.invision.client.renderers.QuizIntroduction;
	import com.invision.client.renderers.AdministrativeText;
	import com.invision.client.renderers.CustomContent;
	import com.invision.client.renderers.CustomContentQuiz;
	import com.invision.client.renderers.InteractiveSimulation;
	import com.invision.client.renderers.InteractiveSimulationQuiz;
	
	import com.invision.client.controllers.OutlineController;
	import com.invision.client.model.OutlineModel;
	import com.invision.client.views.OutlineView;
    
    
	/**
	 * Course used as the Flash Files main document class.  
	 * Add to Flash document properties.
	 */
    public class Course extends MovieClip {	
		public var navigation_mc:NavigationWindow;
		public var content_mc:MovieClip;
		//public var background_mc:MovieClip;
		
        private var mRoot:MovieClip;
        private var mProgressIndicatorView:ProgressIndicatorView;
        private var mNavigationManager:NavigationManager;
        private var mXMLPath:String;
        private var mBegun:Boolean = false;
        private var mCC:TranscriptWindow;
        private var mNoLMS:Boolean;
        private var mOutline:OutlineModel;
        private var mNavigationWindow:NavigationWindow
        private var mAudioPreloaderWindow:AudioPreloaderWindow;
        private var mXMLLoaded:Boolean;
		private var mSecurity:CourseSecurity;
		private var mStubComplete:int = 0;
		
		private const XMLPATH:String = "content.xml";
		private const INT_COURSE:String = "initializeCourse";
		private const CONTENT_LOAD:String = "onContentLoad";
		private const ON_CAPTION:String = "onCaption";
		private const ON_SCENE_START:String = "onSceneStart";
		private const ON_SCENE_COMPLETED:String = "onSceneCompleted";
		private var _openBookFlag:Boolean = false;
		
		protected var mProgressIndicatorModel:ProgressIndicatorModel;
		protected var mProgressIndicatorController:ProgressIndicatorController;
		protected var outlineModel:OutlineModel;
		protected var outlineController:OutlineController;
		protected var outlineView:OutlineView;
		protected var _currentScale:Number = 1;
		
		public static const COURSE_WIDTH:int = 1016;
		public static const COURSE_HEIGHT:int = 690;
		
        public function Course(container_mc:MovieClip = null, xmlPathString:String = null) {
			super();
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP;
			}			
			mRoot = (container_mc != null) ? container_mc : this;
			mXMLPath = (xmlPathString != null) ? xmlPathString : XMLPATH;
			if (stage) {
				init();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			}
        }
		
		public function init(event:Event = null):void {
			if (event != null) {
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}
			if (ApplicationDomain.currentDomain.hasDefinition("com.invision.client.StubCore")) {
				var currentDisplayObject:DisplayObject = stage.getChildAt(0);
				var classReference:Class = getDefinitionByName("com.invision.client.StubCore") as Class;
				if (currentDisplayObject is classReference) {
					mStubComplete = 1;
					currentDisplayObject.addEventListener(INT_COURSE, initializeCourse);
				}
			}
			removeEventListener(Event.ADDED_TO_STAGE, init);
			Core.getInstance();
			Core.setCourse(this);
			Core.setStage(stage);
			
			mRoot.stop();
            mNoLMS = false;
			mSecurity = new CourseSecurity();
			if(mRoot.content_mc != null){
				mRoot.content_mc.visible = false;
				mRoot.x = 0;
				mRoot.y = 0;
			}
            mBegun = false;    
            mXMLLoaded = false;
    
			Core.getInstance().addRenderer(new Introduction());
			Core.getInstance().addRenderer(new AdministrativeText());
			Core.getInstance().addRenderer(new LessonComplete());
			Core.getInstance().addRenderer(new LessonObjectives());
			Core.getInstance().addRenderer(new LessonOverview());
			Core.getInstance().addRenderer(new LessonSummary());
			Core.getInstance().addRenderer(new ImageHalfCircle());
			Core.getInstance().addRenderer(new ImageTop());
			Core.getInstance().addRenderer(new ImageBottom());
			Core.getInstance().addRenderer(new ImageLeft());
			Core.getInstance().addRenderer(new ImageRight());
			Core.getInstance().addRenderer(new ImageFullScreen());
			Core.getInstance().addRenderer(new VideoPlayer());
			Core.getInstance().addRenderer(new ClickToLearn());
			Core.getInstance().addRenderer(new Contemplative());
			Core.getInstance().addRenderer(new JobAid());
            Core.getInstance().addRenderer(new FinalTestIntro());
            Core.getInstance().addRenderer(new FinalTestSubmit());
            Core.getInstance().addRenderer(new FinalTestResults());
            Core.getInstance().addRenderer(new CourseConclusion());
			Core.getInstance().addRenderer(new MultipleChoice());
			Core.getInstance().addRenderer(new FillInTheBlank());
			Core.getInstance().addRenderer(new Explore());
			Core.getInstance().addRenderer(new DragDrop());
			Core.getInstance().addRenderer(new DragDropV2());
			Core.getInstance().addRenderer(new RankOrder());
			Core.getInstance().addRenderer(new RankOrderImage());
			Core.getInstance().addRenderer(new TrueFalse());
			Core.getInstance().addRenderer(new QuizIntroduction());
			Core.getInstance().addRenderer(new CustomContent());
			Core.getInstance().addRenderer(new CustomContentQuiz());
			Core.getInstance().addRenderer(new InteractiveSimulation());
			Core.getInstance().addRenderer(new InteractiveSimulationQuiz());
			
            Core.getInstance().setRoot(mRoot);
			Core.getInstance().addEventListener(CONTENT_LOAD, onContentLoad, false, 0, true);
            Core.load(mXMLPath);
		}
        
        public function initializeCourse(event:Event = null):void {
            trace("Program.initializeCourse")
			var currentDisplayObject:DisplayObject = stage.getChildAt(0);
			if(ApplicationDomain.currentDomain.hasDefinition("com.invision.client.StubCore")){
				var classReference:Class = getDefinitionByName("com.invision.client.StubCore") as Class;
				if (currentDisplayObject is classReference) {
					var stubCoreClass:Object = currentDisplayObject as classReference;
					_currentScale = stubCoreClass.getScale();
				}			
			}
			var courseType:String = Core.Modules.AdminDataModule.getCourseType();
            if (!Core.getInstance().isDebugEnabled() && mStubComplete != 0) {
				// course does not have debug mode.  Need to start tracking
				// and wait for tracking to inititate the start course.
				if (courseType == "cd") {
					// do nothing. wait for cd login to start the course.
					courseConfig();
					Core.Modules.setTrackMode(CoreConstants.TRACKING_MODE_CD);
				}else{
					initializeCourseTracking();
				}
			}else if (Core.getInstance().isDebugEnabled() && mStubComplete != 0) {
				// course has a debug file
				// and has a stub file.  No need to turn on tracking
				if (courseType == "cd") {
					trace("CD window debug mode");
					// do nothing. wait for cd login to start the course.
					courseConfig();
					Core.Modules.setTrackMode(CoreConstants.TRACKING_MODE_CD);
				}else{
					courseConfig();
					validateStartCourse();
				}
            }else {
				// course in debug mode.  check and start the course immediately.
				//validateStartCourse();
				if (courseType == "cd") {
					//Core.Modules.setTrackMode(CoreConstants.TRACKING_MODE_CD);
				}
				validateStartCourse();
			}
			
        }
		
		public function validateStartCourse():void 
		{
			trace("validateStartCourse");
            if (!hasLMS()) {
                showErrorMessage("152: Cannot find Learning Management System.  Please close the course window and try again. ");
            } else {
				startPlayingCourse();
            }
		}
		
		/**
		 * Everything has been checked.  Start running the course.
		 */
		public function startPlayingCourse():void {
			Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_LOAD_ERROR, onAudioLoadError, false, 0, true);
			Core.Modules.AssessmentModule.addEventListener(Assessment.ON_ASSESSMENT_BEGIN, onAssessmentBegun, false, 0, true);
			Core.Modules.AssessmentModule.addEventListener(Assessment.ON_ASSESSMENT_COMPLETED, onAssessmentCompleted, false, 0, true);
			Core.getInstance().addEventListener(ON_CAPTION, onCaption, false, 0, true);
			Core.getInstance().addEventListener(ON_SCENE_START, onSceneStart, false, 0, true);
			Core.getInstance().addEventListener(ON_SCENE_COMPLETED, onSceneCompleted, false, 0, true);
			trace("Core.Modules.getBookmarkActive() = " + Core.Modules.getBookmarkActive());
			// 
			if (mStubComplete != 0 && !Core.Modules.getBookmarkActive()) {
			   startCourse();
			}
		}
		
		public function getScale():Number {
			return _currentScale;
		}
		
		private function onErrorWindowEvent(event:Event):void {
			Core.getInstance().closeWindow();
			
		}
		
		public function setStubComplete(state:int = 1):void {
			mStubComplete = state;
		}
		
		public function getStubComplete():int {
			return mStubComplete;
		}
        
        private function onContentLoad(event:Event):void {
            trace("onContentLoad in course.as mStubComplete = "+mStubComplete);
			Core.getInstance().removeEventListener(CONTENT_LOAD, onContentLoad);
			mXMLLoaded = true;
			if (Core.getInstance().isDebugEnabled() && mStubComplete == 0) {
				courseConfig();
			}else if (mStubComplete == 0) {
				var courseType:String = Core.Modules.AdminDataModule.getCourseType();
				if (courseType == "cd") {
					showErrorMessage("Stub file required to run course in CD mode.  Course has stopped.  Please run with CD file. [error:1CD]");
				}else{
					showErrorMessage("Stub file required to run course.  Course has stopped.  Please run with preload stub file. [error:1]");
				}
			}
        }
		
		/**
		 * checks to see if tracking exists
		 */
		private function initializeCourseTracking():void 
		{
			trace("initializeCourseTracking ***");
			Core.CourseTracking.addEventListener(CourseDataTracking.TRACKING_INTIALIZED, onCourseTrackingInitialized, false, 0, true);
			Core.Modules.setTrackMode(Core.Modules.AdminDataModule.getCourseTracking());
		}
		
		private function onCourseTrackingInitialized(e:Event):void 
		{
			trace("onCourseTrackingInitialized = " + Core.CourseTracking.hasLMS());
			courseConfig();
			validateStartCourse();
		}
        
        private function courseConfig():void {
            if(mXMLLoaded){
                mNavigationManager = new NavigationManager();
				
				addBackgroundWindow();
                addNavigationWindow();
				
				addCCWindow();
				
                addAudioPreloadWindow();
                initProgressWindow();
				
                var bkText:String = Core.Modules.AdminDataModule.getTitle();

				if(Core.CourseObject.getNavigationWindow().coursetitle_mc != null){
					Core.CourseObject.getNavigationWindow().coursetitle_mc.textbox.htmlText = bkText;
				}
				// the program was loaded successfully.  What mode should we run in?
				var courseType:String = Core.Modules.AdminDataModule.getCourseType();
				if (Core.hasDebugXML()) {
					trace("compensating for lack of LMS");
					Core.Modules.AdminDataModule.setNavigationType(CoreConstants.NAVIGATION_MODE_OPEN);
					Core.CourseTracking.setLessonLocation(Core.Modules.AdminDataModule.getLessonLocation());
                    mNoLMS = true;
                    if (mStubComplete == 0) {
						trace("showBookmarkWindow a2");
						Core.Modules.setBookmark(Core.CourseTracking.getLocationData());
                        //Core.showBookmarkWindow();
                        initializeCourse();
                    }
                } else if (courseType == "cd") {
					showCDWindow();
				} else if (mStubComplete == 0){
                    Core.log("ERROR in Program.onCoreInitialize(): no stub file found");
                    showErrorMessage("Stub file required to run course.  Please run with stub file.");
                    return;
                } else if (!hasLMS()) {
					showErrorMessage("A learning management system is required to run this course.  The course will not work.");
					return;
				}
				
				//Core.CourseTracking.sendLocation();
                Core.Modules.setBookmark(Core.CourseTracking.getLocationData());
                if(Core.Modules.getMenuSceneID() == CoreConstants.UNDEFINED && Core.Modules.getHomeSceneID() == CoreConstants.UNDEFINED && hasLMS()){
                }
				
                mNavigationManager.initialize();
                mNavigationManager.deactivate();

                if (mNoLMS && !Core.Modules.getBookmarkActive()) {
                    startCourse();
                }
				
            } else {
                showErrorMessage("Could not load XML file: " + this.mXMLPath);                    
            }
        }
		
		private function showCDWindow(){
			// open the login window
			// check for valid login information
			// check existing values
			// update tracking variables
            var id:String = Core.Popups.showDialog("CD_login", PopupManager.MODE_ALWAYS_ON_TOP, { x:0, y:0 } );
			var p:IPopup = Core.Popups.getPopup(id);
            var ew:CDLoginWindow = CDLoginWindow(p);
		}
		
		private function addBackgroundWindow():void 
		{
			var backgroundView:BackgroundView = new BackgroundView();
			addChildAt(backgroundView, 0);
			backgroundView.initialize(this);
		}
        
        public function startCourse():void {
			trace("startCourse called startCourse");
            setBegun();
            Core.getInstance().setScene(Core.Modules.getFirstSceneID());
			Core.showBookmarkWindow();
        }
        
        public function get Nav():NavigationManager { return mNavigationManager; }
        public function get NavOutline():OutlineModel { return mOutline; }
		public function set NavOutline(aOutline:OutlineModel):void { mOutline = aOutline; }
        
        private function hasLMS():Boolean {
            switch (Core.Modules.getTrackMode()) {
                case CoreConstants.TRACKING_MODE_NONE:
                    return true;
                    break;
                case CoreConstants.TRACKING_MODE_WEBSERVICE:
					var employeeNumber:String = Core.CourseTracking.getEmployeeNumber();
                    if ((employeeNumber == null || employeeNumber == "") && !mNoLMS) {
                        return false;
                    }
                    return true;
                    break;
                case CoreConstants.TRACKING_MODE_SCORM12:
					if (Core.CourseTracking.getSCORMErrors() != 0 && !mNoLMS) {
						// does not have an LMS and errors were reported.
						return false;
					}
                    return true;
					break;
				case CoreConstants.TRACKING_MODE_CUSTOM:
					// not supported
                    return false;
					break;
                default:
                    if (Core.CourseTracking.getSCORMErrors() != 0 && !mNoLMS) {
                        return false;
                    }
                    return true;
					break;
            }
        }
        
        public function showErrorMessage(errorText:String, initObj:Object = null):ErrorWindow {
            mRoot.visible = true;
            if (initObj == null) {
                initObj = new Object();
            }
            initObj.x = 0;
            initObj.y = 0;
            var id:String = Core.Popups.showDialog("errorWindow", PopupManager.MODE_ALWAYS_ON_TOP, initObj);
            var p:IPopup = Core.Popups.getPopup(id);
            var ew:ErrorWindow = ErrorWindow(p);
            ew.setErrorText(errorText);
			return ew;
        }
        
        public function openExternalFile(urlString:String):void {
            if (ExternalInterface.available) {
				var urlRequest:URLRequest = new URLRequest(urlString);
				navigateToURL(urlRequest, "_blank");
            }else{
                Core.CourseObject.showErrorMessage("Your browser does not support links to external files.  Please contact an administrator.");
            }
        }
        
        public function getCaptionClip():TranscriptWindow { return mCC; }
		
		public function clearCaption():void {
			var mScene:Scene = Core.getInstance().getScene();
			mScene.clearAllCaptionEvents();
			Core.CourseObject.getCaptionClip().setTranscript("");
		}
		
		/**
		 * 
		 * @param	captionNode, captionText, captionTiming
		 * Send the name of the captioning node from the xml file.  use the name defined in the XML
		 * If the captionText exists, the course uses that data instead of the captionNode.
		 * No reset when true will no call manualResetTimes.
		 */
		public function manualCaption(captionNode:String, captionText:String = null, captionTiming:String = null) {
			

			var mScene:Scene = Core.getInstance().getScene();
			var sceneXML:XML = mScene.getXML();
			var resultsXML:XMLList = new XMLList(sceneXML.captioning);

			var transcriptNode:XMLList;
			if (captionText != null) {
				trace("captionText = " + captionText);
				transcriptNode = new XMLList(<caption></caption>);
				var captionRow:XML = new XML();
				captionRow.@["captiontext"] = captionText;
				captionRow.@["captiontime"] = captionTiming;
				transcriptNode.appendChild(captionRow);
			}else {
				transcriptNode = resultsXML.child(captionNode);
			}
			if (transcriptNode != null) {
				var transcriptText:String = transcriptNode[0].@["captiontext"];
				var theText:String = transcriptText.split(String.fromCharCode(Keyboard.ENTER)).join("\\r");
				theText = theText.split(String.fromCharCode(10)).join("");
				var transcriptArray:Array = theText.split("\\r");
				
				var markers:String = transcriptNode[0].@["captiontime"];
				markers = markers.split(" ").join("");
				var markerArray:Array = markers.split(",");
				if (markerArray.length == 0) {
					markerArray.push(markers);
				}
				if (transcriptArray.length != markerArray.length) {
					Core.log("ERROR in XMLManager.processXML(): number of transcript markers does not match number of lines of transcript text in " + sceneXML.@["id"]);
				}
				
				for (var j:Number = 0; j < markerArray.length; j++) {
					var time:Number = parseFloat(markerArray[j]);
				}
				
				Core.CourseObject.getCaptionClip().setTranscript(transcriptArray.join("\r"));
			}
		}
        
        private function onCaption(event:Event):void {
            var tString:String = Core.getInstance().sceneEventObject().text;
            if(tString == null){
                tString = " ";
            }
            setCaptionText(tString);
        }
        
        private function setCaptionText(s:String):void {
			Core.CourseObject.getCaptionClip().setCaption(s);
        }
        
        private function onSceneStart(event:Event):void { 
			Core.CourseObject.getCaptionClip().setTranscript("");
            //mAudioPreloaderWindow.hide();
            updateProgressBar(Core.getInstance().getScene().getID());
            //}
        }
        
        private function onSceneCompleted(event:Event):void { updateProgressBar(Core.getInstance().getScene().getID()); }
		
		private function onAudioLoadError(event:Event):void {
			Core.CourseObject.showErrorMessage("Problem.  Cannot load audio.", { buttonCaption:"Retry" } );		
		}
        
        private function updateProgressBar(sceneID:String):void {
            var theScene:Scene = Core.Modules.getScene(sceneID);
            var completedScenes:Number = 0;
            var currentPageNumber:int = 0;
            for (var i:Number = 0; i < Core.Modules.getSequenceList().getCount(); i++) {
                var sequenceID:String = Core.Modules.getSequenceList().getItem(i);
                var theSequence:ISequence = Core.Modules.getSequence(sequenceID);
                if (theSequence.getID() != theScene.getSequenceID()) {
                    completedScenes += theSequence.getLength();
                } else {
                    completedScenes += theSequence.getIndex(theScene.getID()) + 1;
                    break;
                }
            }
            var currentSequence:ISequence = Core.Modules.getSequence(theScene.getSequenceID())
			var totalSequencePages:int;
			if(currentSequence != null){
				totalSequencePages = currentSequence.getNumberedScenes()
				//currentPageNumber = currentSequence.getIndex(theScene.getID()) + 1;
			}else {
				
				// compensate for lack of lesson.
				totalSequencePages = 0;
			}
			currentPageNumber = theScene.getPageNumber();
            mProgressIndicatorModel.updateProgress(totalSequencePages, currentPageNumber);
        }
        
        public function onAssessmentBegun(event:Event):void { trace("assessment begun!"); } 
        
        public function onAssessmentCompleted(event:Event):void { 
            var results:int = (Core.Modules.AssessmentModule.getScore() >= Core.Modules.AssessmentModule.getPassPercent()) ? 1 : 0;
			Core.log("SETTING VARIABLE RESULT: " + results);
			//Core.CourseTracking.courseComplete(results);
           
            mNavigationManager.onNextButton();
        }
                
        public function setTitle(s:String):void {
            var tf:TextFormat = mRoot.content_mc.sceneTitle_txt.getTextFormat();
            mRoot.content_mc.sceneTitle_txt.text = s;
            mRoot.content_mc.sceneTitle_txt.selectable = false;
            mRoot.content_mc.sceneTitle_txt.autoSize = "left";
            mRoot.content_mc.sceneTitle_txt.setTextFormat(tf);
        }
        public function isBegun():Boolean { return mBegun; }
		public function setBegun():void { mBegun = true; }
        
        public function getRoot():MovieClip { return mRoot; }
        
        public function getNavigationBox():NavigationWindow { 
            return navigation_mc;
        }
        
        public function getBackground():NavigationWindow { 
            return navigation_mc;
        }
        
        public function getNavigationWindow():NavigationWindow{ return navigation_mc; }
        
        public function getAudioPreloaderWindow():AudioPreloaderWindow {
            return mAudioPreloaderWindow;
        }
        
        private function addAudioPreloadWindow():void {
			trace("addAudioPreloadWindow");
			mAudioPreloaderWindow = new AudioPreloaderWindow();
			mAudioPreloaderWindow.x = 619;
			mAudioPreloaderWindow.y = 653;
			navigation_mc.addChild(mAudioPreloaderWindow);
        }
		
        private function addNavigationWindow():void {
			navigation_mc.initialize(this);
        }
		
		private function addCCWindow():void {
			mCC = new closedcaptionWindow();
			mCC.name = "mCC";
			mCC.x = 0;
			mCC.y = 619;
			mCC.alpha = 0;
			mCC.visible = false;
			navigation_mc.addChild(mCC);
		}
        
        private function initProgressWindow():void {
			mProgressIndicatorModel = new ProgressIndicatorModel();
			mProgressIndicatorController = new ProgressIndicatorController(mProgressIndicatorModel);
			
            mProgressIndicatorView = getNavigationBox().progress_mc;
			mProgressIndicatorView.initialize(mProgressIndicatorModel, mProgressIndicatorController);
        }
		
		public function isOpenBook():Boolean { return _openBookFlag; }
		public function setOpenBookFlag(b:Boolean) { _openBookFlag = b; }
    }
}
