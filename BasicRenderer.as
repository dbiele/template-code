package  {
	import com.invision.client.components.BasicButton;
	import com.invision.client.components.QuestionFeedbackWindow;
	import com.invision.client.components.views.ReviewQuestionWindowView;
	import com.invision.client.renderers.view.ClickToLearnView;
	import com.invision.events.AudioEvent;
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
    import com.invision.client.components.PDAWindow;
    import com.invision.data.Hashtable;
    import com.invision.data.List;
    import com.invision.Scene;
	import flash.utils.Timer;
    
    import com.invision.Core;
    import com.invision.CoreConstants;
    import com.invision.SceneRenderer;
    import com.invision.client.ProgramConstants;
    import com.invision.client.components.ImageWindow;
    import com.invision.data.XMLUtility;
    import com.invision.ui.Image;
    import com.invision.ui.Shape;
    import com.invision.interfaces.IQuestion;
    import com.invision.interfaces.IInteractive;
    import com.invision.interfaces.ISceneRenderer;
    import com.invision.interfaces.ISequence;
    import com.invision.SceneContainer;
    
    import com.invision.interfaces.IPopup;
    import com.invision.ui.PopupManager;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
    
    
    public class BasicRenderer extends SceneRenderer implements ISceneRenderer {

        private var mCheckAnswerButton:MovieClip;
        private var mFlagButton:MovieClip;
        private var mPopups:Hashtable;
        private var _feedbackWindow:QuestionFeedbackWindow;
		
        private var mLocked:Boolean = false;
		
        private var second:Number;
        private var mDate:Date;
        private var startTime:Number;
        private var currentTime:Number;
        private var offset:Number = 0;
        private var mMC:MovieClip;
        private var mFunction:Function;
		private var mTimer:Timer;
		private var mSymbolName:String;
		
		private var _flag_header:MovieClip;
		private var _checkAnswerBasicButton:BasicButton;
		private var _openBookReviewWindow:ReviewQuestionWindowView;
		
		public function BasicRenderer():void {
			
		}
        
		override public function initialize():void 
		{
			super.initialize();
			trace("initialize basic renderer mScene = " + mScene.getID());
			mSymbolName = mScene.getParam("symbol");
			if (mSymbolName != null) {
				/*
				var depth:Number;
				if (Core.Course.Nav.isCaptionOpen()) {
					var captionDepth:Number = Core.Course.getCaptionClip().getDepth();
					var newDepth:Number = PopupManager.getNextLevel(Core.getInstance().getRoot());
					if (newDepth > captionDepth) {
						Core.Course.getCaptionClip().swapDepths(newDepth);
						depth = captionDepth;
					} else {
						depth = newDepth;
					}
				} else {
					depth = PopupManager.getNextLevel(Core.getInstance().getRoot());
				}
				*/
                var className:Class = getDefinitionByName(mSymbolName) as Class;
				content_mc = new className() as MovieClip;
				content_mc.name = mSymbolName;
				//Core.CourseObject.getNavigationWindow().addChildAt(mc,depth);		
				Core.CourseObject.getRoot().addChild(content_mc);
				//content_mc = Core.Course.getRoot().attachMovie(theSymbol, theSymbol, depth, { _alpha:0 });
				//var theTween:Object = new Tween(content_mc, "_alpha", Regular.easeInOut, 0, 100, ProgramConstants.SCENE_FADE_SECONDS, true);
			}
			//
			// if movieclips of the frame type are next to each other in the timeline.
			//content_mc.image_default.visible = false;
			var theFrameNumber:Number = 1;
			if(mScene != null){
				theFrameNumber = parseInt(mScene.getParam("frame"));
				if (isNaN(theFrameNumber)) {
					theFrameNumber = 1;
				}
			}
            if (theFrameNumber != mRoot.currentFrame) {
				Core.getInstance().setGoToFrame(theFrameNumber);
            }
			
        }
		
	
		
		//public function reset():void { };
		//public function setRegisteredClips(h:Hashtable):void { };
        
        override public function preload():void {
            super.preload();
            // if pda content exists, duplicate it and move it to new layer.
			if (content_mc != null) {
				trace("getContainer().getContent().image_remove =" + getContainer().getContent().image_remove);
				if (getContainer().getContent().image_remove != null) {
					trace("remove image *");
					getContainer().getContent().removeChild(getContainer().getContent().image_remove);
				}
				trace("has image property =  " + Core.getInstance().getScene().getXML().images.hasOwnProperty("image"));
				if (Core.getInstance().getScene().getXML().images.hasOwnProperty("image") || Core.getInstance().getScene().getXML().videocanvas.hasOwnProperty("videofile")) {
					if(getContainer().getContent().image_default != null){
						getContainer().getContent().image_default.visible = false;
					}
				}else {
					if(getContainer().getContent().image_default != null){
						getContainer().getContent().image_default.visible = true;
					}
				}
				
				if(content_mc.feedbackWindow != null){
					var initPoint:Point = new Point(content_mc.feedbackWindow.x, content_mc.feedbackWindow.y);
					content_mc.globalToLocal(initPoint);
					// set the pda movie to the root and set visibile to false
					var id:String = Core.Popups.showDialog("questionFeedbackWindow", PopupManager.MODE_ALWAYS_ON_TOP, {x:initPoint.x,y:initPoint.y,visible:false,width:content_mc.feedbackWindow.width});
					_feedbackWindow = QuestionFeedbackWindow(Core.Popups.getPopup(id));
					content_mc.feedbackWindow.visible = false;
				}
			}
        }
        
        override public function startScene():void {
            super.startScene();
			trace("***** start scene basic renderer.as = "+__addPageHeader());
            mPopups = new Hashtable();
            // set the scene title
            if (Core.CourseObject.getNavigationWindow().lessontitle_tfield !=  null) {
                Core.CourseObject.getNavigationWindow().lessontitle_tfield.text = __addPageHeader();
            }
			
			if (Core.CourseObject.getNavigationWindow().pagetitle_tfield !=  null) {
                Core.CourseObject.getNavigationWindow().pagetitle_tfield.text = Core.getInstance().getScene().getTitle();
            }
            
            // on start scene stop button flashing.
            Core.CourseObject.Nav.closeFlashing();
            var sceneID:String = Core.getInstance().getScene().getID();
            if(Core.Renderer.getSceneComplete() && !Core.Modules.isLastScene(sceneID)){
                // if scene is manually set to complete, override the stop flashing
                Core.CourseObject.Nav.showFlashing();
            }
            
            
            // on start scene set the next button to activated.
            trace("x-------set the next button to activated"); 
            trace("mScene.getTemplate() = "+mScene.getTemplate().getType());
            if (mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_MENU  
            && mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_ASSESSMENT_PRE
            && mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_ASSESSMENT_POST){
                // do not enable next when template is menu or in an assessment.
                //Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_NORMAL);
            }
			
			// close the menu window if disabled
			
            // enable or disable captioning based on the status of the "caption" button.  the core has already set the status of 
            // this control.
			trace("enable or disable captioning based on the status of the caption button ");
            if (Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).getState() != CoreConstants.CONTROL_STATE_DISABLED) {
				trace("set the transcript information");
				if (Core.CourseObject.getCaptionClip().isCaptionOpen()) {
					Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).setState(CoreConstants.CONTROL_STATE_ACTIVATED);
				}
                Core.CourseObject.getCaptionClip().setTranscript(mScene.getTranscript());            
            } else {
                Core.CourseObject.Nav.closeCaption();
            }
            // if audio is enabled for the scene, set the state of the button to active and enable play pause button
            if (mScene.hasAudio() || mScene.hasVideo()) {
                if (Core.CourseObject.Nav.isAudioEnabled()) {
					trace("pause 1 = enabled");
					Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_ACTIVATED);
                }else {
                }
				if(Core.Controls.item(CoreConstants.CONTROL_ID_PLAY) != null){
					Core.Controls.item(CoreConstants.CONTROL_ID_PLAY).setState(CoreConstants.CONTROL_STATE_ACTIVATED);
				}
			
            }else {
				trace("pause 2 = enabled = " + mScene.getTemplate().getType());
				if (mScene.getTemplate().getID() != CoreConstants.TEMPLATE_CUSTOMCONTENT) {
					Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_DISABLED);
				}
				if (mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_ASSESSMENT_PRE && mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_ASSESSMENT_POST) {
					trace("*****set state normal");
					//Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_NORMAL);
					//Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_NORMAL);
				}                        
            }
            
            // If this is the first scene in a sequence, the back button should be enabled
			trace("mScene.getSequenceID() = " + mScene.getSequenceID());
            var theSequence:ISequence = Core.Modules.getSequence(mScene.getSequenceID());
			if(theSequence != null){
				if (theSequence.isFirst(mScene.getID())) {
					Core.Controls.item(CoreConstants.CONTROL_ID_BACK).setState(CoreConstants.CONTROL_STATE_NORMAL);
				}
            }
    
    
            // other controls need to change state (or caption, or both) based on whether we're in an assessment or not.
			trace("startScene called2"+Core.Modules.AssessmentModule.isInProgress());
            if (Core.Modules.AssessmentModule.isInProgress()) {
                // ASSESSMENT QUESTIONS
				trace("mScene.getTemplate().getType() = " + mScene.getTemplate().getType());
                if (mScene.getTemplate().getType() == CoreConstants.TEMPLATE_TYPE_QUESTION) {
                    __addQuestionNumber();
                    // disable the home button
					if(Core.Controls.item(CoreConstants.CONTROL_ID_HOME) != null){
						Core.Controls.item(CoreConstants.CONTROL_ID_HOME).setState(CoreConstants.CONTROL_STATE_DISABLED);
					}
                    // pause button should be disabled.
                    Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_DISABLED);
                    // hide the "check answer" button
                    mCheckAnswerButton = content_mc.btnCheckAnswer;   
					if (mCheckAnswerButton != null) {
						mCheckAnswerButton.visible = false;
						
					}
                    // initialize the "flag" button and set up handlers
					trace("flag window called");
					
                    mFlagButton = content_mc.btnFlagReview;
					if(mFlagButton != null){
						mFlagButton.buttonMode = true;
						mFlagButton.useHandCursor = true;
						mFlagButton.addEventListener(MouseEvent.ROLL_OVER, onRollOverHandler, false, 0, true);
						mFlagButton.addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler, false, 0, true);
						mFlagButton.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
						mFlagButton.addEventListener(MouseEvent.MOUSE_UP, onReleaseHandler, false, 0, true);
					}
						
					_flag_header = content_mc.flag_header_mc;
					
                    if (Core.Modules.getQuestion(mScene.getID()).isFlagged()) {
                        trace("page is flagged");
						if(mFlagButton != null){
							mFlagButton.gotoAndPlay("Flagged");
						}
						if(_flag_header != null){
							_flag_header.visible = true;
						}
						content_mc.questionnumber_txt.x = 64;
                    }else {
                        // jump to the first frame
						if(mFlagButton != null){
							mFlagButton.gotoAndStop(1);
						}
						if(_flag_header != null){
							_flag_header.visible = false;
						}
						content_mc.questionnumber_txt.x = 30;
                    }
					
					// if this is an "open book" assessment, show the review movie link in the top right
					trace("is open = " + Core.CourseObject.isOpenBook());
					if (Core.CourseObject.isOpenBook()) {
						trace("course is open book");
						// add review movieclip to question
						_openBookReviewWindow = new reviewQuestionWindow as ReviewQuestionWindowView;
						_openBookReviewWindow.x = 600;
						_openBookReviewWindow.y = 80;
						content_mc.addChild(_openBookReviewWindow);
						/*
						var mc:MovieClip = mContent.attachMovie("reviewWindow", "reviewWindow", PopupManager.getNextLevel(mContent), { _x:754, _y:95 });
						mOpenBookReviewButton = mc.reviewButton;
						mOpenBookReviewButton.onRollOver = function() { this.gotoAndPlay("lOver"); }
						mOpenBookReviewButton.onRollOut = function() { this.gotoAndPlay("lOut"); }
						mOpenBookReviewButton.onPress = function() { this.gotoAndPlay("lDown"); }
						mOpenBookReviewButton.onReleaseOutside = function() { this.gotoAndStop(1); }					
						mOpenBookReviewButton.onRelease = function() { trace("click"); }
						mOpenBookReviewButton.ButtonName = "Review";
						mOpenBookReviewButton.ButtonColor = "blue";
						mOpenBookReviewButton.onRelease = Delegate.create(this, onOpenBookReview);	
						*/
						
					}
					// final test review mode
					trace("Core.Modules.getMode() =" + Core.Modules.getMode());
					if (Core.Modules.getMode() == CoreConstants.MODE_ASSESSMENT_REVIEW) {
						// no non-assessment questions should be displayed when in final test review mode.
						if (mScene.getTemplate().getType() == CoreConstants.TEMPLATE_TYPE_QUESTION) {
							Core.CourseObject.Nav.onNextButton();
							return;
						}
					}
                }
				if (Core.Modules.getMode() == CoreConstants.MODE_ASSESSMENT_REVIEW) {
					//mScene.isVisited() && 
					// automatically enable the next button.
					Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_NORMAL);
				}
            } else {
                // NON-ASSESSMENT QUESTIONS
                if (mScene.getTemplate().getType() == CoreConstants.TEMPLATE_TYPE_QUESTION) {
                    __addQuestionNumber();        
                    // clear the question's history
                    var q:IQuestion = Core.Modules.getQuestion(mScene.getID());
                    q.clearAttempts();
                    // initialize the "check answer" button and set up handlers
                    mCheckAnswerButton = content_mc.btnCheckAnswer;
					if (mCheckAnswerButton != null) {
						mCheckAnswerButton.alpha = 1;
						_checkAnswerBasicButton = new BasicButton("checkanswer", mCheckAnswerButton);
						_checkAnswerBasicButton.addEventListener(MouseEvent.MOUSE_UP, onCheckAnswer, false, 0, true);
					}

                    // the "flag for review" button should be hidden
                    mFlagButton = content_mc.btnFlagReview;
                    mFlagButton.visible = false;
					
					// the header flag should be hidden.
					trace("non assessment question");
					_flag_header = content_mc.flag_header_mc;
					if(_flag_header != null){
						_flag_header.visible = false;
					}
                }
                if (mScene.isVisited() && mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_ASSESSMENT_PRE) {
                    // stops the course from launching the assessment again.
                    Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_NORMAL);
                }else if (!mScene.isVisited()) {
					if (Core.Modules.AdminDataModule.getNavigationType() != CoreConstants.NAVIGATION_MODE_OPEN) {
						if (mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_ASSESSMENT_POST) {
							//Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_DISABLED);
						}
					}
				}
                if (mScene.getTemplate().getType() == CoreConstants.TEMPLATE_TYPE_ASSESSMENT_POST) {
                    Core.Controls.item(CoreConstants.CONTROL_ID_BACK).setState(CoreConstants.CONTROL_STATE_DISABLED);
                }
				
				if (mScene.isVisited() && mScene.getTemplate().getID() != CoreConstants.TEMPLATE_ASSESSMENT_INTRO) {
					//Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_NORMAL);
				}
				
				if (mScene.isVisited() && mScene.getTemplate().getID() != CoreConstants.TEMPLATE_INTERACTIVE && mScene.getTemplate().getType() != CoreConstants.TEMPLATE_TYPE_ASSESSMENT_PRE) {
					Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_NORMAL);
				}
				
				// check for the last page in the last sequence
				if(mScene.getSequenceID() != "undefined"){
					if(Core.Modules.getSequenceList().getLast() == mScene.getSequenceID() && theSequence.isLast(mScene.getID())){
						trace("last scene last id");
						// if the course is not in an assessment tell the course that it is completed
						if (!Core.Modules.hasAssessment) {
							// mark the course as completed
							//Core.Modules.setMode(CoreConstants.MODE_POSTASSESSMENT);
							//set the course variable to complete
							var results:int = 1;
							Core.CourseTracking.courseComplete(results);
						}
					}
				}
				
				if (Core.Modules.getMode() == CoreConstants.MODE_QUIZ_REVIEW) {
					trace("start scene check");
					Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW).setState(CoreConstants.CONTROL_STATE_DISABLED);
					Core.Controls.item(CoreConstants.CONTROL_ID_BACK).setState(CoreConstants.CONTROL_STATE_DISABLED);
					Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_FLASHING);
				}else {
					Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW).setState(CoreConstants.CONTROL_STATE_NORMAL);
				}
				
            }

            // user should not be able to click "Menu" if:
            // - there IS no main menu, or.
            // - final assessment has been completed.
			trace("Core.Modules.getMenuSceneID() = " + Core.Modules.getMenuSceneID());
            if (Core.Modules.getMode() == CoreConstants.MODE_ASSESSMENT_REVIEW || Core.Modules.AssessmentModule.isCompleted()) {
				trace("menu scene called");
				if(Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW) != null){
					Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW).setState(CoreConstants.CONTROL_STATE_DISABLED);
				}
            }
            // user should not be able to click the "next" button under any circumstances on the final page of the final sequence
            // (because this would take the user back to the main menu).
            // next button should also be disabled on lesson complete screens.
			trace("last scene");
            if (Core.Modules.isLastScene(mScene.getID()) ||
                mScene.getTemplate().getID() == CoreConstants.TEMPLATE_LESSON_COMPLETE) {
				trace("next state 11= disabeld");
                Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_DISABLED);
            }
            
            // if the scene is the first in the sequence set the back button to disabled.
            
            var firstSequence:String = Core.Modules.getSequenceList().getFirst();
            if(firstSequence == mScene.getSequenceID() && firstSequence != "undefined"){
                var nSequence:ISequence = Core.Modules.getSequence(mScene.getSequenceID());
                if(nSequence.getIndex(mScene.getID()) == 0){
                    Core.Controls.item(CoreConstants.CONTROL_ID_BACK).setState(CoreConstants.CONTROL_STATE_DISABLED);
                    Core.Controls.item(CoreConstants.CONTROL_ID_BACK).update();
                }
            }
			
			// set auto complete
			if (mScene.getOverrideCompletion() == CoreConstants.SCENE_START_COMPLETE_AUTO && Core.Modules.AdminDataModule.getSceneCompletionType() != CoreConstants.SCENE_START_COMPLETE_AUTO) {
				Core.Modules.updateCompletionBookmark();
                Core.getInstance().getScene().setVisited();
			}
			
			
			// final test review mode
			if (Core.Modules.getMode() == CoreConstants.MODE_ASSESSMENT_REVIEW) {
				// use the exit button as a return button
				Core.CourseObject.Nav.addReturnButton();
				//btn_exit
				/*
				Core.Controls.item(CoreConstants.CONTROL_ID_EXIT).setCaption("Return");				
				Core.Controls.item(CoreConstants.CONTROL_ID_EXIT).setState(CoreConstants.CONTROL_STATE_FLASHING);
				Core.Controls.item(CoreConstants.CONTROL_ID_MENU).setState(CoreConstants.CONTROL_STATE_DISABLED);
				Core.Program.Nav.createPauseButton();
				*/
			}
            
        }
		
		protected function repositionCheckAnswer(posY:int) {
			trace("repositionCheckAnswer = "+posY);
			mCheckAnswerButton.y = posY;
		}
		
		protected function updateFlagReview(yPos:int):void {
			if (mFlagButton != null) {
				mFlagButton.y = yPos;
			}
		}
		
		private function onRollOverHandler(evt:MouseEvent):void {
			var currentMC:MovieClip = evt.currentTarget as MovieClip;
			if (!Core.Modules.getQuestion(mScene.getID()).isFlagged()) {
				currentMC.gotoAndPlay("Over"); 
			}
		}
		
		private function onRollOutHandler(evt:MouseEvent):void {
			var currentMC:MovieClip = evt.currentTarget as MovieClip;
			if (!Core.Modules.getQuestion(mScene.getID()).isFlagged()) {
				currentMC.gotoAndPlay("Out"); 
			}
		}
		
		private function onMouseDownHandler(evt:MouseEvent):void {
			var currentMC:MovieClip = evt.currentTarget as MovieClip;
			currentMC.gotoAndPlay("Down");
		}
		
		private function onReleaseHandler(evt:MouseEvent):void {
			var currentMC:MovieClip = evt.currentTarget as MovieClip;
			if (!Core.Modules.getQuestion(mScene.getID()).isFlagged()) {
				Core.Modules.getQuestion(mScene.getID()).setFlagged(true);
				currentMC.gotoAndPlay("Flagged");
				if(_flag_header != null){
					_flag_header.visible = true;
				}
				content_mc.questionnumber_txt.x = 64;				
			} else {
				Core.Modules.getQuestion(mScene.getID()).setFlagged(false);
				currentMC.gotoAndPlay("Over");
				if(_flag_header != null){
					_flag_header.visible = false;
				}
				content_mc.questionnumber_txt.x = 30;
			}						
		}		
		
		public override function removeContainer():void {
			super.removeContainer();
			trace("basicrenderer.as removeContainer called");
		}
        
        public override function endScene():void {
            super.endScene();
			trace("basic renderer end scene in basicrenderer.as");
			trace("mPopups = " + mPopups);
			if(mPopups != null){
				var keyArray:Array = mPopups.getKeys();
				var hashCount:Number = keyArray.length;
				trace("hashCount = " + hashCount);
				for (var i:Number = 0; i < hashCount; i++) {
					trace("keyArray[i] = " + keyArray[i]);
					var popStringID:String = mPopups.getValue(keyArray[i]) as String;
					Core.Popups.getPopup(popStringID).close();
				}
				// remove the pda if it exists
				trace("_feedbackWindow= " + _feedbackWindow);
				if(_feedbackWindow != null){
					_feedbackWindow.visible = false;
				}
			}
			
			if (Core.AudioObject.isAudioPlaying()) {
				Core.AudioObject.stopAllAudio();
			}
			
			if (_checkAnswerBasicButton != null) {
				_checkAnswerBasicButton.setDisabled();  
				_checkAnswerBasicButton.removeAllEventListeners();
				_checkAnswerBasicButton = null;
			}
			
			if (mTimer != null){           
				mTimer.stop();
				mTimer = null;
			}
			
			Core.AudioObject.removeEventListener(AudioEvent.ON_AUDIO_PLAY_PAUSE, onAudioPlayPause);
			
			if (mFlagButton != null) {
				mFlagButton.removeEventListener(MouseEvent.ROLL_OVER, onRollOverHandler);
				mFlagButton.removeEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
				mFlagButton.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
				mFlagButton.removeEventListener(MouseEvent.MOUSE_UP, onReleaseHandler);
				mFlagButton = null;
			}
			
			if(mSymbolName != null){
				trace("get child by name = " + Core.CourseObject.getRoot().getChildByName(mSymbolName));
				var removeMC:MovieClip = Core.CourseObject.getRoot().getChildByName(mSymbolName) as MovieClip;
			}
			if (removeMC != null) {
				removeMC.visible = false;
				trace("basicrendered remove child");
				Core.CourseObject.getRoot().removeChild(removeMC);
				removeMC = null;
				//content_mc.removeMovieClip();
				//var theTween:Object = new Tween(content_mc, "_alpha", Regular.easeInOut, 100, 0, ProgramConstants.SCENE_FADE_SECONDS, true);
				//theTween.onMotionFinished = Delegate.create(this, onFadeOutComplete);
			} else {
				trace("problem.  could not find library movieclip");
				//Core.log("ERROR in scene '" + mScene.getID() + "' endScene(): no library symbol id specified in XML.");
			}
        }
        
		//------------

        override public function pauseScene(mmc:MovieClip, func:Function, time:Number):void {
            super.pauseScene(mmc,func,time);
            offset = 0;
			mTimer.stop();
			mTimer = null;
            Core.AudioObject.removeEventListener(AudioEvent.ON_AUDIO_PLAY_PAUSE, onAudioPlayPause);
            Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_PLAY_PAUSE,onAudioPlayPause, false, 0, true);
            mMC = mmc;
            if (func != null) {
				this.mFunction = func;
			}
            second = time;
            if(!Core.AudioObject.isPaused()){
                initTimer();
            }
        }
        override public function clearPauseScene():void {
            /**
             * Clears the pause scene functions
             */
            super.clearPauseScene();
            mTimer.stop();
			mTimer = null;
            mFunction = null;
        }
        private function initTimer(){
            // initiliazes the new time each time its called
            mDate = new Date();
            startTime = mDate.getTime();
			mTimer = new Timer(100);
			mTimer.addEventListener(TimerEvent.TIMER, getCurrentTime, false, 0, true);
			mTimer.start();
            //intervalID = Core.setInterval(this, "getCurrentTime", 100);
        }
        private function getCurrentTime(evt:TimerEvent) {
            var currentDate:Date = new Date();
            currentTime = (Math.floor((currentDate.getTime() - startTime)/100))/10 + offset;
            if (currentTime >= second) {
                offset = 0;
				mTimer.stop();
				mTimer = null;
                //Core.clearInterval(intervalID);
                Core.AudioObject.removeEventListener("onAudioPlayPause", onAudioPlayPause);
                mFunction.call(mMC);
                mFunction = null;
            }
        }    
        private function onAudioPlayPause(evt:Event){
            if(evt.target.isPaused){
                // The audio has been paused. 
                // stop the pause interval.
				mTimer.stop();
				mTimer = null;
                //clearInterval(intervalID);
            }else{
                // The audio has been set to play.
                // start where pause left off by adding the currenttime where we left off.
                offset = currentTime;
                initTimer()
            }
        }        
        
        private function __addPageHeader():String {
            var mScene:Scene = Core.getInstance().getScene();
            var nSequence:ISequence = Core.Modules.getSequence(mScene.getSequenceID());
            var pageName:String = (nSequence != null) ? nSequence.getName() : "";
            // check and see if the lesson has a course home and if it does then don't add a currentName.
            var currentName:String = ""
            trace("Core.Modules.getLessonSceneID() = " + Core.Modules.getLessonSceneID());
            var firstSequence:String = Core.Modules.getSequenceList().getFirst();
            if (mScene.getSequenceID() != firstSequence && Core.Modules.getHomeSceneID() != CoreConstants.UNDEFINED) {
                // gets the current name if there is a sequence and if there is a course main menu.
                //currentName = Core.CourseObject.NavOutline.getSelectedItemName();
            }else if (mScene.getSequenceID() == firstSequence && Core.Modules.getLessonSceneID() != CoreConstants.UNDEFINED) {
                // there is only 1 sequence and the sequence has a lesson menu
                var inMenu:Boolean = (mScene.getTemplateID() == CoreConstants.TEMPLATE_COURSEMAINMENU || mScene.getTemplateID() == CoreConstants.TEMPLATE_MAINMENU);
                if (mScene.getID() == Core.Modules.getSequence(firstSequence).getFirst() && inMenu) {
                    // we are in the first scene of the first sequence
                    // do nothing
                }else{
                    //currentName = Core.CourseObject.NavOutline.getSelectedItemName();
                }
                // is this the first frame of the first sequence.  If so, then don't use a current name.
            }
            if(pageName == CoreConstants.UNDEFINED){
                pageName = "";
            }
            if(currentName == CoreConstants.UNDEFINED || currentName == null){
                currentName = "";
            }    

            if (Core.Modules.getHomeSceneID() == CoreConstants.UNDEFINED && Core.Modules.getMenuSceneID() == CoreConstants.UNDEFINED) {
                // the course does not have a course main menu so the lesson title needs to only show currentName
                if (currentName == null || mScene.getID() == Core.Modules.getLessonSceneID()) {
                    // if the currentname is undefined or the current scene is the lesson menu.
                    currentName = "Home";
                }
                if (mScene.getSubSequenceID() == CoreConstants.UNDEFINED) {
					trace("display the sub sequence when we are in a sub");
                    // display the page name when we are in a sequence with no sub sequences
                    return pageName;
                }else {
					
					trace("testing = " + nSequence.getSequence(mScene.getSubSequenceID()).getName());
					currentName = nSequence.getSequence(mScene.getSubSequenceID()).getName();
                    return currentName;
                }
            }else if(pageName == currentName || currentName == ""){
                return pageName;
            }else if (mScene.getSubSequenceID() == CoreConstants.UNDEFINED) {
                // display the page name when we are in a sequence with no sub sequences
                return pageName;
            }else {
                return pageName +" > "+currentName;
            }
            
        }
    
        private function __addQuestionNumber() {
            var theQuestion:IQuestion = Core.Modules.getQuestion(mScene.getID());
			trace("theQuestion.getQuestionType()* = " + theQuestion.getQuestionType());
            if (theQuestion.getQuestionType() != CoreConstants.QUESTION_TYPE_PRACTICE) { 
                var sequenceID:String = mScene.getSequenceID();
                var currentQuestion:Number = theQuestion.getOrdinal();
				trace("add question number = " + currentQuestion);
                var totalQuestions:Number = Core.Modules.getSequence(sequenceID).getQuestionCount();
				trace("content_mc = " + content_mc);
				trace("content_mc.questionnumber_txt = " + content_mc.questionnumber_txt);
				if(content_mc.questionnumber_txt != undefined){
					content_mc.questionnumber_txt.embedFonts = true;
					content_mc.questionnumber_txt.selectable = false;
					var tf:TextFormat = content_mc.questionnumber_txt.getTextFormat();
					trace("Question " + currentQuestion + " of " + totalQuestions);
					var questionTitle:String = "Question " + currentQuestion + " of " + totalQuestions;
					content_mc.questionnumber_txt.text = questionTitle;
					content_mc.questionnumber_txt.setTextFormat(tf);
					Core.CourseObject.getNavigationWindow().pagetitle_tfield.text = questionTitle;
				}
            } else {
                content_mc.questionnumber_txt.visible = false;
            }
			trace("__addQuestionNumber done");
        }
        
        override public function onAnimation(evt:Object):void {
            super.onAnimation(evt);
        }
        
        public function randomize(anArray:Array):Array {
            var numArray:Array = new Array();
            var numArray2:Array = new Array();
			var i:Number = 0;
            for (i = 0; i < anArray.length; i++) {
                numArray.push(i);
                numArray2.push(i);
            }
            var randomArray:Array = new Array();            
            for (i = 0; i < numArray2.length; i++) {
                var cNum:Number = Math.floor(Math.random() * ((numArray.length - 1) + 1));
                var spliceArray:Array = numArray.splice(cNum, 1);
                var tNum:Number = parseInt(spliceArray[0]);
                randomArray.push(anArray[tNum]);
            }
            return randomArray;
        }
        
		//checkForAttempts:Boolean,stopAudio:Boolean
        public function onCheckAnswer(evt:MouseEvent) {
            /**
             * onCheckAnswer is true, then will not set attempts.
             */
			trace("onCheckAnswer");
			if(_feedbackWindow != null){
				_feedbackWindow.show();
			}
            var q:IQuestion = Core.Modules.getQuestion(mScene.getID());
            var done:Boolean = false;
            q.addAttempt();
            if (q.isCorrect()) {
				if(_feedbackWindow != null){
					_feedbackWindow.setState(ProgramConstants.PDA_FRAME_CORRECT);
				}
                done = true;
				disableInteraction();
				//var sceneID:String = Core.getInstance().getScene().getID();
				//Core.CourseObject.Nav.showFlashingNextButton(sceneID);
            } else {
				if (q.getReviewMode()) {
					// has a review scene
					trace("has review mode");
					_feedbackWindow.setState(ProgramConstants.PDA_FRAME_REVIEW);
					disableInteraction();
				}else {
					trace("does not have review mode");
					var attemptCount:Number = q.getAttempts();
					if(_feedbackWindow != null){
						switch (attemptCount) {
							case 1:
								_feedbackWindow.setState(ProgramConstants.PDA_FRAME_INCORRECT1); 
								break;
							case 2:
								_feedbackWindow.setState(ProgramConstants.PDA_FRAME_INCORRECT2);
								break;
							default:
								_feedbackWindow.setState(ProgramConstants.PDA_FRAME_INCORRECT3);
								//done = true;
								break;
						}
					}
				}
            }        
            if (done) {
				trace("is done**");
                if (!q.isCorrect()) {
                    Core.getInstance().getRenderer().getObject().showCorrectAnswer();
                }
                disableInteraction();
                
                // do not show flashing button when last scene of last sequence
                
                var theScene:Scene = Core.getInstance().getScene();
                //var sequenceID:String = Core.Modules.getSequenceList().getIndex(theScene.getSequenceID());
    
                var sequenceID:String = theScene.getSequenceID();
				trace("Core.Modules.getSequenceList().isLast(sequenceID) = " + Core.Modules.getSequenceList().isLast(sequenceID));
				trace("Core.Modules.getSequence(theScene.getSequenceID()).getLast() = " + Core.Modules.getSequence(theScene.getSequenceID()).getLast());
				trace("theScene.getID() = " + theScene.getID());
                if (Core.Modules.getSequenceList().isLast(sequenceID) && theScene.getID() == Core.Modules.getSequence(theScene.getSequenceID()).getLast()) {
                    // show flashing when not at last scene or last sequence.  Otherwise, do nothing.
					trace("do not show flashing");
                }else {
					trace("show flashing");
                    Core.CourseObject.Nav.showFlashing();
                    Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_FLASHING);
				}
                
                // this is necessary to mark the scene as completed!
                mScene.setVisited();
				trace("updateCompletionBookmark 4");
                Core.Modules.updateCompletionBookmark();
                
                Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).update();
            }    
            return done;
        }
        
        private function disableInteraction() {
            // disable interaction in the scene renderer
            var sub:com.invision.interfaces.IInteractive;
            sub = com.invision.interfaces.IInteractive(this);
            if (sub == null) {
                Core.log("ERROR: renderer " + mScene.getTemplate().getRendererClass() + " does not implement com.invision.interfaces.IInteractive.");
            }
            sub.disableListeners();
            // and disable the "check answer" button
            _checkAnswerBasicButton.setDisabled();  
			_checkAnswerBasicButton.removeAllEventListeners();
        }
        
        public function getShapePopUp(id:String):String {
            return mPopups.getValue(id) as String;
        }
        
        public function onShapeActivate(evt:Object):void {
            trace("shape activate");
            var theShape:Shape = evt.target;
            var iNode:XML = theShape.getXML();
            var propertyType:String = iNode.@["propertywindow"];
            var propertyCallout:String = iNode.@["propertycallout"];
			
			// used to call callout detail graphic
			if(propertyType == "_toolbox_hotspot"){
				if (theShape.getImageID() != CoreConstants.UNDEFINED) {
					var theImage:Image = mImageContainer.getImage(theShape.getImageID());
					theImage.doEvent( { message:theImage.getTransition() } );
				}
			}
			if (propertyType != "_toolbox_text_pop") {
                // used to call pop-up callout window
                if(propertyCallout != CoreConstants.UNDEFINED && propertyCallout != "0"){
                    var id:String = Core.Popups.showDialog("clicktolearnWindow2", PopupManager.MODE_NORMAL, { alpha:0, mShape:theShape, shapeXML:iNode })
                    var iw:ClickToLearnView = ClickToLearnView(Core.Popups.getPopup(id));
                    mPopups.add(theShape.getID(), id);
                }
            } 
			

        }
        
            // used by interactive renderers
        public function lock():void { mLocked = true; }
        public function unlock():void { mLocked = false; }
        public function isLocked():Boolean { return mLocked; }
    }
}
