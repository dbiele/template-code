package  {
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Expo;
	import com.greensock.TweenLite;
	import com.invision.client.components.BasicButton;
	import com.invision.client.controllers.OutlineController;
	import com.invision.client.interfaces.IOutline;
	import com.invision.client.model.OutlineModel;
	import com.invision.client.views.OutlineView;
	import com.invision.Core;
	import com.invision.CoreConstants;
	import com.invision.data.ResponseWindow;
	import com.invision.Scene;
	import com.invision.client.components.CaptionButton;
	import com.invision.client.components.NavButton;
	import com.invision.client.components.NavPlayButton;
	import com.invision.client.components.PauseButton;
	import com.invision.data.Hashtable;
	import com.invision.data.List;
	import com.invision.events.AudioEvent;
	import com.invision.interfaces.IControl;
	import com.invision.interfaces.ISequence;
	import com.invision.Template;
	import com.invision.ui.Popup;
	import com.invision.ui.PopupManager;
	import com.invision.utils.DebugTrackingUtility;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
    
	
	/**
	 * Navigiation Manager controls the main navigation bar.  
	 */
    public class NavigationManager extends EventDispatcher {
		
		public static var STAGE_WIDTH:Number = 1016;
		public static var STAGE_HEIGHT:Number = 645;
		
        private var OVERLAY_NONE:String = "none";
        private var mCaptionWasOpenedByAudio:Boolean = false;
    
        private var mAudioEnabled:Boolean = true;    
		private var mMenuOutlineOpen:Boolean = false;
        
        // scene ID of a scene in the final test where we hit the "Review" button and need to be able to jump back when the user hits the "return" button
        private var mFinalTestReviewTarget:String = "";
        // special mode flags for buttons that change names, like "Pause" (which change to "Flag") and "Exit" which changes to "Return")
        private var mPauseButtonMode:Boolean = true;
        private var mAudioCompleteListenerEnabled:Boolean = true;
        
        private var mCurrentOverlay:String = OVERLAY_NONE;
        
        private var flashingTween:TweenLite;
        private var mToolTip:MovieClip;
        
		static private const ON_SCENE_COMPLETED:String = "onSceneCompleted";
		static public const PAUSE_STATE:String = "pauseState";
		static public const PLAY_STATE:String = "playState";
		
		private var outlineMC:OutlineView;
		private var _debuggerKeyDown:Boolean;
		private var _debugUtility:DebugTrackingUtility;
		private var _responseLogger:ResponseWindow;
		private var _responseLoggerKeyDown:Boolean;
		private var _previousIndex:int;
		private var _emptyMovieClip:MovieClip;
		private var _reviewbutton:MovieClip;
		private var _reviewBasicButton:BasicButton;
        
        public function NavigationManager() {
			trace("NavigationManager called");
            Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_PLAY_COMPLETE, onAudioPlayComplete, false, 0, true);   
            Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_PLAY_COMPLETE_ASYNC, onAudioPlayCompleteAsync, false, 0, true);   
            Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_PLAY_START, onAudioPlayStart, false, 0, true);   
            Core.getInstance().addEventListener(ON_SCENE_COMPLETED, onSceneCompleted, false, 0, true);   
			Core.getStage().addEventListener(KeyboardEvent.KEY_UP, onKeyBoardEventUp, false, 0, true);  
			Core.getStage().addEventListener(KeyboardEvent.KEY_DOWN, onKeyBoardEventDown, false, 0, true); 
			trace("NavigationManager called");
            //Key.addListener(this);
        }
        
        public function deactivate():void{
            // help button
            Core.Controls.item(CoreConstants.CONTROL_ID_HELP).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // glossary button
            //Core.Controls.item(CoreConstants.CONTROL_ID_GLOSSARY).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // job aids button
            //Core.Controls.item(CoreConstants.CONTROL_ID_JOBAIDS).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // audio button
            //Core.Controls.item(CoreConstants.CONTROL_ID_AUDIO).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // captions button
            Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // back button
            Core.Controls.item(CoreConstants.CONTROL_ID_BACK).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // play/pause button 
            Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_DISABLED);;
            // play button 
            //Core.Controls.item(CoreConstants.CONTROL_ID_PLAY).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // next button
            Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // exit button 
            Core.Controls.item(CoreConstants.CONTROL_ID_EXIT).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // menu button 
            //Core.Controls.item(CoreConstants.CONTROL_ID_FEEDBACK).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // menu button 
            Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW).setState(CoreConstants.CONTROL_STATE_DISABLED);
            // updates all the states
            Core.Controls.update();
        }
        
        public function initialize():void {
			addCourseTitle();
			addTrainingCodeTitle();
			addDefaultLessonName();
			addDefaultPageName();
			
            // initialize the controls
			var currentControl:NavButton;
			var currentPause:PauseButton;
			
            // help button
			trace("getNavigationBox = "+Core.CourseObject.getNavigationBox());
            Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_HELP, Core.CourseObject.getNavigationBox().btn_help, CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE));
			currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_HELP) as NavButton;
			currentControl.addEventListener(MouseEvent.MOUSE_DOWN, onHelpButton, false, 0, true);
			trace("help complete");
			// glossary button
			//Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_GLOSSARY, Core.CourseObject.getNavigationBox().btn_glossary, CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE));
			//currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_GLOSSARY) as NavButton;
			//currentControl.addEventListener(MouseEvent.MOUSE_DOWN, onGlossaryButton);
            // job aids button
            //Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_JOBAIDS, Core.CourseObject.getNavigationBox().btn_reference, CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE));
            //currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_JOBAIDS) as NavButton;
			//currentControl.addEventListener(MouseEvent.MOUSE_UP, onJobAidsButton, false, 0, true); 
            // audio button
            //Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_AUDIO, Core.CourseObject.getNavigationBox().btn_audio, CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE));
            //currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_AUDIO) as NavButton;
			//currentControl.addEventListener(MouseEvent.MOUSE_UP, onAudioButton, false, 0, true);
            // captions button
            Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_CAPTION, Core.CourseObject.getNavigationBox().btn_captions, CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE));
            currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION) as NavButton;
			currentControl.addEventListener(MouseEvent.MOUSE_UP, onCaptionButton, false, 0, true);
            // back button
            Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_BACK, Core.CourseObject.getNavigationBox().btn_back));
            currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_BACK) as NavButton;
			currentControl.addEventListener(MouseEvent.MOUSE_UP, onBackButton, false, 0, true);
            // play/pause button
			trace("add pause button");
            Core.Controls.add(new PauseButton(CoreConstants.CONTROL_ID_PAUSE, Core.CourseObject.getNavigationBox().btn_pause));
            currentPause = Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE) as PauseButton;
			currentPause.addEventListener(MouseEvent.MOUSE_UP, onPauseButton, false, 0, true);
            // next button
            Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_NEXT, Core.CourseObject.getNavigationBox().btn_next));
			currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_NEXT) as NavButton;
            currentControl.addEventListener(MouseEvent.MOUSE_UP, onNextButton, false, 0, true);
            currentControl.addEventListener(MouseEvent.ROLL_OUT, onNextButtonRollOut, false, 0, true);
            // exit button
            Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_EXIT, Core.CourseObject.getNavigationBox().btn_exit));
            currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_EXIT) as NavButton;
			currentControl.addEventListener(MouseEvent.MOUSE_UP, onExitButton, false, 0, true);
            // feedback button
            //Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_FEEDBACK, Core.CourseObject.getNavigationBox().btn_feedback));
            //currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_FEEDBACK) as NavButton;
			//currentControl.addEventListener(MouseEvent.MOUSE_UP, onFeedbackButton, false, 0, true);
            // menu button
			trace("*******add menu button");
            Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_MENUWINDOW, Core.CourseObject.getNavigationBox().btn_menu, CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE));
            currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW) as NavButton;
			currentControl.addEventListener(MouseEvent.MOUSE_UP, onMenuButton, false, 0, true);
			// replay button
            Core.Controls.add(new NavButton(CoreConstants.CONTROL_ID_REPLAY, Core.CourseObject.getNavigationBox().btn_replay));
            currentControl = Core.Controls.item(CoreConstants.CONTROL_ID_REPLAY) as NavButton;
			currentControl.addEventListener(MouseEvent.MOUSE_UP, onReplayButton, false, 0, true);
			
			addOutline();
        }
		
		private function addDefaultPageName():void 
		{
			var pageName:TextField = Core.CourseObject.getNavigationWindow().pagetitle_tfield;
			pageName.text = "";
		}
		
		private function addDefaultLessonName():void 
		{
			var lessonName:TextField = Core.CourseObject.getNavigationWindow().lessontitle_tfield;
			lessonName.text = "";
		}
		
		public function minimizeMenu():void {
			if(Core.Controls.getOrigState(CoreConstants.CONTROL_ID_MENUWINDOW) != CoreConstants.CONTROL_STATE_DISABLED){
				Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW).setState(CoreConstants.CONTROL_STATE_TOGGLE_OFF);
				Core.Controls.item(CoreConstants.CONTROL_ID_MENUWINDOW).update();
			}
			onMenuButton();
		}
    
        public function hideOverlay(event:Event = null):void {
			
			trace("hideOverlay called");
            if (mCurrentOverlay != OVERLAY_NONE) {
                if (!mPauseButtonMode) {
                    mPauseButtonMode = true;
                }
                //Core.getInstance().getRenderer().clearPauseScene();
                var navWindow:MovieClip = Core.CourseObject.getNavigationWindow();
				var target:DisplayObject = navWindow.getChildByName(mCurrentOverlay);
				var mc:MovieClip = target as MovieClip;
				try {
					Core.CourseObject.getNavigationWindow().removeChild(mc);
					mc = null;
				} catch (err:Error) {
					trace("unable to delete mc in naviation manager = " + err.getStackTrace);
				}
                Core.Controls.item(mCurrentOverlay).setState(CoreConstants.CONTROL_STATE_TOGGLE_OFF);
                Core.Controls.item(mCurrentOverlay).update();
                mCurrentOverlay = OVERLAY_NONE;
                if(!Core.CourseObject.isBegun()){
                    Core.CourseObject.startCourse();
                }
            }      
			
        }
        
        public function showOverlay(id:String, symbol:String):void {
			trace("showOverlay");
			
            if (mCurrentOverlay != id) {
                hideOverlay();
                mCurrentOverlay = id;
                var depth:Number;
                depth  = Core.CourseObject.getNavigationWindow().numChildren;
				trace("show overlay depth = " + depth);
				trace("call classname");
                var className:Class = getDefinitionByName(symbol) as Class;
				var mc:* = new className();
				mc.name = mCurrentOverlay;
				Core.CourseObject.getNavigationWindow().addChildAt(mc,depth);
                switch (mCurrentOverlay) {
                    case CoreConstants.CONTROL_ID_HELP:
                        //mc.bkCover_mc.onRelease = function() { };
                        //mc.bkCover_mc.onReleaseOutside = function() { };
                        //mc.bkCover_mc.onPress = function() { };
                        //mc.bkCover_mc.useHandCursor = false;
						//mc.helpWindow.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hideOverlay);
                        //mc.helpWindow.btnClose.onPress = Delegate.create(this, hideOverlay);                
                        break;
                    case CoreConstants.CONTROL_ID_GLOSSARY:
						//mc.glossaryWindow.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hideOverlay);
                        //mc.glossaryWindow.btnClose.onPress = Delegate.create(this, hideOverlay);                            
                        break;
                    case CoreConstants.CONTROL_ID_JOBAIDS:
						//mc.jobaidsWindow.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hideOverlay);
                        //mc.jobaidsWindow.btnClose.onPress = Delegate.create(this, hideOverlay);                                
                        break;
                    case CoreConstants.CONTROL_ID_FEEDBACK:
						//mc.jobaidsWindow.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hideOverlay);
                        //mc.jobaidsWindow.btnClose.onPress = Delegate.create(this, hideOverlay);                                
                        break;
					default:
						break;
                }
            } else {
                hideOverlay();
            }  
			
        }
        
        public function onHelpButton(evt:MouseEvent):void { showOverlay(CoreConstants.CONTROL_ID_HELP, "helpWindow"); }
        //public function onGlossaryButton(evt:MouseEvent):void { showOverlay(CoreConstants.CONTROL_ID_GLOSSARY, "glossaryWindow"); }
        public function onJobAidsButton(evt:MouseEvent):void { showOverlay(CoreConstants.CONTROL_ID_JOBAIDS, "jobaidsWindow"); }
		public function onFeedbackButton(event:MouseEvent):void { showOverlay(CoreConstants.CONTROL_ID_FEEDBACK, "feedbackWindow"); }
        
        public function onAudioPlayStart(evt:Event):void {
			trace("CONTROL_ID_PAUSE onAudioPlayStart  called");
            //if(Core.getInstance().getScene().getTemplate().getID() == CoreConstants.TEMPLATE_CUSTOMCONTENT){
				trace("CONTROL_ID_PAUSE audio play start called");
				pauseTitleText(PAUSE_STATE);
                Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_NORMAL);
                Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).update();
            //}
        }
        
        public function onAudioPlayComplete(evt:Event):void {
            trace("on audio play complete");
			if (Core.Controls.item(CoreConstants.CONTROL_ID_PLAY) != null) {
				// sets the play button in the media window back to normal state.
				Core.Controls.item(CoreConstants.CONTROL_ID_PLAY).setState(CoreConstants.CONTROL_STATE_NORMAL);
				Core.Controls.item(CoreConstants.CONTROL_ID_PLAY).update();
			}
        }    
        
        public function onAudioPlayCompleteAsync(evt:Event):void {
            trace("onAudioPlayCompleteAsync called in navigation manager");
            updatePauseState();
        }
        
        public function onAudioButton(evt:MouseEvent):void {
            var theButton:IControl = Core.Controls.item(CoreConstants.CONTROL_ID_AUDIO);
			trace("mAudioEnabled = " + mAudioEnabled);
            if (mAudioEnabled) {
				trace("audio enabled 1 = "+theButton.getMovieClip().muteunmuteToggle_mc);
                theButton.getMovieClip().muteunmuteToggle_mc.gotoAndStop(2);
				Core.AudioObject.setMasterVolume(0);
                mAudioEnabled = false;
                if (!Core.CourseObject.getCaptionClip().isCaptionOpen()) {
                    mCaptionWasOpenedByAudio = true;
					if (Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).getState() != CoreConstants.CONTROL_STATE_DISABLED){
						//Core.getInstance().getScene().getTranscript() != ""){
						openCaption();
					}
                }
                Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).setState(CoreConstants.CONTROL_STATE_DISABLED);
                Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).update();
            } else {
				trace("audio enabled 2");
                theButton.getMovieClip().muteunmuteToggle_mc.gotoAndStop(1);
                Core.AudioObject.setMasterVolume(1);
                mAudioEnabled = true;
                if (mCaptionWasOpenedByAudio) {
					
					if(Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).getState() != CoreConstants.CONTROL_STATE_DISABLED){
						if (Core.CourseObject.getCaptionClip().isCaptionOpen()) {
							closeCaption();
						}
					}
                    mCaptionWasOpenedByAudio = false;
                } else {
                    trace("set caption to activated"); 
					trace("Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION). = " + Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).getToggleState());
					
                }
				Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).setState(CoreConstants.CONTROL_STATE_ACTIVATED);
                Core.Controls.item(CoreConstants.CONTROL_ID_CAPTION).update();   
            }        
        }
        
        public function setFinalTestReviewTarget(s:String):void {
            resetPauseButton();
            mFinalTestReviewTarget = s;
        }
        public function getFinalTestReviewTarget():String {
            return mFinalTestReviewTarget;
        }    
        
		/**
		 * show the menu window
		 */
        public function onMenuButton(event:MouseEvent = null):void {
			if (!mMenuOutlineOpen) {
				openMenuOutline();
			}else {
				closeMenuOutline();
			}
        }
		
		/**
		 * replay the scene
		 */
        public function onReplayButton(event:MouseEvent = null):void {
			resetPauseButton();
			Core.getInstance().replayScene();
		}
		
		public function openMenuOutline():void {
			mMenuOutlineOpen = true;
			outlineMC.visible = true;
			outlineMC.x =  (STAGE_WIDTH - outlineMC.width)/2;
			var aHeight:Number = Math.ceil(645 - outlineMC.height);
			TweenLite.to(outlineMC, 1, { y:aHeight, ease:Expo.easeOut } );
		}
		
		public function closeMenuOutline():void {
			mMenuOutlineOpen = false;
			var aHeight:Number = 645;
			TweenLite.to(outlineMC, 0.5, { y:aHeight, onComplete:onMenuCloseComplete } );
		}
		
		private function onMenuCloseComplete():void {
			outlineMC.visible = false;
		}
        
        public function onCaptionButton(evt:MouseEvent):void {
            if (Core.CourseObject.getCaptionClip().isCaptionOpen()) {
				closeCaption();
            } else {
                openCaption();
            }
        }
        public function openCaption():void {
			
            // initialize the caption container
			//Core.CourseObject.getNavigationWindow()
			trace("Core.CourseObject.getNavigationWindow()= " + Core.CourseObject.getNavigationWindow());
			try {
				//Core.CourseObject.getNavigationWindow().swapChildren(Core.CourseObject.getNavigationWindow(), Core.CourseObject.getCaptionClip());
				var topPosition:uint = PopupManager.getNextLevel(Core.CourseObject.getNavigationWindow());
			}catch (error:ArgumentError) {
				trace("argument error called in open caption "+error);
			}		
            Core.CourseObject.getCaptionClip().visible = true;

			flashingTween = new TweenLite(Core.CourseObject.getCaptionClip(), ProgramConstants.SCENE_FADE_SECONDS, { alpha:1 } );

            Core.CourseObject.getCaptionClip().openWindow();
			
        }
    
        //public function isCaptionOpen():Boolean { return mCaptionOpen; }
        
        public function closeCaption():void {
            Core.CourseObject.getCaptionClip().closeWindow();
        }
		
		private function pauseTitleText(state:String):void {
			var theButton:IControl = Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE);
			switch(state) {
				case PAUSE_STATE:
					theButton.getMovieClip().playpauseToggle_mc.gotoAndStop(2);	
					theButton.getMovieClip().buttontitle_tfield.text = "Pause";
					break;
				case PLAY_STATE:
					theButton.getMovieClip().playpauseToggle_mc.gotoAndStop(1);
					theButton.getMovieClip().buttontitle_tfield.text = "Play";
					break;
				default:
					break;
			}
		}
        
        public function onPauseButton(evt:MouseEvent):void {
            var theButton:IControl = Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE);
            var customTemplateType:Boolean = Core.getInstance().getScene().getTemplate().getID() == CoreConstants.TEMPLATE_CUSTOMCONTENT;
            if (customTemplateType) {
                // this is a custom template page.  We need to handle the audio differently.
                var regClips:Hashtable = Core.Renderer.getRegisteredClips();
                var bComplete:Boolean = (regClips.getCount() != 0) ? Core.Renderer.getSceneComplete() : true;
                var bPlaying:Boolean = (regClips.getCount() != 0) ? Core.Renderer.isPlaying() : false;
                if (Core.AudioObject.isFinished() && !bPlaying && bComplete) {
                    // if audio is not playing, the timeline is not playing and the scene is complete
                    // then we can refresh the page
					resetPauseButton();
                    Core.getInstance().replayScene();
				}else if (!Core.getInstance().getScene().hasAudio() && !bPlaying && bComplete) {
					trace("replay the scene called for custom scene");
					var clipKeys:Array = regClips.getKeys();
					for (var i:int = 0; i < clipKeys.length; i++) {
						var id:String = clipKeys[i];
						var mc:MovieClip = regClips.getValue(id).mc;
						trace("mc = " + mc);
						mc.isPlaying = true;
					}
					resetPauseButton();
					Core.getInstance().replayScene();
                }else {
					trace("navigationmanager.as pause called");
                    Core.AudioObject.pauseAllAudio();
					if (Core.AudioObject.isPaused()) {
						pauseTitleText(PLAY_STATE);
					}else {
						pauseTitleText(PAUSE_STATE);
					}
                }
				trace("--------------------------");
            }else if (!Core.AudioObject.isFinished()) {
                trace("*** on pause button");
                Core.AudioObject.pauseAllAudio();
                if (Core.AudioObject.isPaused()) {
					trace("theButton.getMovieClip().playpauseToggle_mc = " + theButton.getMovieClip().playpauseToggle_mc);
                    pauseTitleText(PLAY_STATE);
                }else {
					trace("playpauseToggle_mc = 1");
                    pauseTitleText(PAUSE_STATE);
                }
            } else {
				trace("renderer is playing = " + Core.Renderer.isPlaying());
                trace("is scene complete = " + Core.Renderer.getSceneComplete());
				
                if (!Core.Renderer.getSceneComplete()) {
                    Core.AudioObject.pauseAllAudio();
                }else {
					resetPauseButton();
                    Core.getInstance().replayScene();
                }
            }
			
        }    
    
        //--------------------------
        /*
        public function onPlayButton() {
            // if audio has stopped, replay the scene
            if (Core.AudioObject.isPaused()) {
                Core.AudioObject.pause();
            } else if (Core.AudioObject.isFinished()) {
                // replay the scene
                Core.getInstance().replayScene();
            }
        }
        */
        //-------------------------
        
        public function resetPauseButton():void {

            var theButton:IControl = Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE);
			var currentMC:MovieClip = theButton.getMovieClip();

			pauseTitleText(PAUSE_STATE);
            if (!Core.Modules.AssessmentModule.isInProgress())  {
                //Core.AudioObject.stop();
				//Core.AudioObject.stopAllSounds();
            }
            if (Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).getState() == CoreConstants.CONTROL_STATE_TOGGLE_ON) {
                Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_TOGGLE_OFF);
            }
			//updatePauseState();
        }
		
		/**
		 * enables the pause/play button and sets the state to "Pause".
		 * this is used when a timeline is currently playing.
		 */
		public function enablePauseButton():void {
			pauseTitleText(PAUSE_STATE);
			Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_NORMAL);
			Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).update();
		}
		
		public function disablePauseButton():void {
			Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_DISABLED);
			Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).update();
			pauseTitleText(PLAY_STATE);			
		}
		
		public function enableReplayButton():void {
			Core.Controls.item(CoreConstants.CONTROL_ID_REPLAY).setState(CoreConstants.CONTROL_STATE_NORMAL);
			Core.Controls.item(CoreConstants.CONTROL_ID_REPLAY).update();
		}
		
		/**
		 * Used to set the state of the pause button
		 * @param	buttonState supported states are: NavigationManager.PLAY_STATE or NavigationManager.PAUSE_STATE
		 */
		public function setPauseButtonState(buttonState:String):void {
			switch(buttonState) {
				case PAUSE_STATE:
					resetPauseButton();
					break;
				case PLAY_STATE:
					pauseTitleText(PLAY_STATE);
					
					break;
				default:
					break;
			}
		}
		
		public function addReturnButton():void {
			if(_reviewbutton == null){
				_reviewbutton = new btn_return as MovieClip;
				_reviewbutton.x = 0;
				_reviewbutton.y = 617;
				Core.CourseObject.getNavigationWindow().addChild(_reviewbutton);
				_reviewBasicButton = new BasicButton("return", _reviewbutton);
				_reviewBasicButton.addEventListener(MouseEvent.MOUSE_UP, onReturnButtonHandler, false, 0, true);
				Core.CourseObject.getNavigationBox().btn_exit.visible = false;
			}			
		}
		
		private function showFlashingReturn():void {
			if (_reviewbutton != null) {
				_reviewbutton.gotoAndPlay("Flashing");
			}
		}
		
		private function removeReturnButton():void {
			Core.CourseObject.getNavigationWindow().removeChild(_reviewbutton);
			_reviewbutton = null;
			Core.CourseObject.getNavigationBox().btn_exit.visible = true;	
		}
		
		private function onReturnButtonHandler(e:MouseEvent):void {
			Core.Modules.setMode(CoreConstants.MODE_NORMAL);
			resetPauseButton();
			removeReturnButton();
			var sceneID:String = Core.getInstance().getSystemVariable(CoreConstants.SYSVAR_SCENE_REFERENCE_ID);				
			Core.getInstance().setScene(sceneID);
		}
		
        public function onBackButton(evt:MouseEvent = null):void {
    //---------------------
            var previousSceneID:String;
            resetPauseButton();
            previousSceneID = Core.getInstance().getPreviousSceneID();    
            // if getNextSceneID returns an undefined value, we're probably at the end of a lesson.
            // pop to the next one if we can, and get the first scene from it instead.
            if (previousSceneID == CoreConstants.UNDEFINED) {
                var theScene:Scene = Core.getInstance().getScene();
                var sequenceID:String = Core.Modules.getSequenceList().getPrevious(theScene.getSequenceID());
				//if (!Core.Module.getSequenceList().isLast(sequenceID)) {
                    var theSequence:ISequence = Core.Modules.getSequence(sequenceID);
                    previousSceneID = theSequence.getLast();
				//}
            }
            // if for some reason that didn't work, just reload the current scene.
            if (previousSceneID== "" || previousSceneID == null) {
                previousSceneID = Core.getInstance().getScene().getID();
            }
            // whatever we decided the next scene should be, load it.   
            Core.getInstance().setScene(previousSceneID);
        }		
    
        public function onNextButton(evt:Event = null):void {
            var nextSceneID:String;
            resetPauseButton();
			switch (Core.Modules.getMode()) {
				case CoreConstants.MODE_QUIZ_REVIEW:
					Core.Modules.setMode(CoreConstants.MODE_NORMAL);
					//Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setCaption("Next");
					nextSceneID = Core.getInstance().getSystemVariable(CoreConstants.SYSVAR_SCENE_REFERENCE_ID);
					break;
				case CoreConstants.MODE_ASSESSMENT_REVIEW:
					nextSceneID = Core.getInstance().getNextSceneID();
					// next scene is last of lesson
					var theScene:Scene = Core.getInstance().getScene();
					var currentSequence:ISequence = Core.Modules.getSequence(theScene.getSequenceID());
					if (currentSequence.getLast() == nextSceneID) {
						trace("is last scene in sequence");
						
						Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_DISABLED);
						showFlashingReturn();
						// show flashing return button
						//Core.Controls.item(CoreConstants.CONTROL_ID_EXIT).setCaption("Exit");						
						//nextSceneID = Core.getInstance().getSystemVariable(CoreConstants.SYSVAR_SCENE_REFERENCE_ID);
					}
					if (currentSequence.getLast() == theScene.getID()) {
						Core.Modules.setMode(CoreConstants.MODE_NORMAL);
						removeReturnButton();
						nextSceneID = Core.getInstance().getSystemVariable(CoreConstants.SYSVAR_SCENE_REFERENCE_ID);
					}
					break;
				default:
					nextSceneID = Core.getInstance().getNextSceneID();
					break;
			}
			trace("nextSceneID = " + nextSceneID);
            // if getNextSceneID returns an undefined value, we're probably at the end of a lesson.
            // pop to the next one if we can, and get the first scene from it instead.
            if (nextSceneID == CoreConstants.UNDEFINED) {
				trace("the scene ='" + Core.getInstance().getScene()+"'");
				if (Core.getInstance().getScene() == null) {
					Core.ErrorsManager.displayError(1, "SCENE ERROR", "The next frame does not have a movie clip with a class scene container or content_mc.");
					return;
				}
                var theScene:Scene = Core.getInstance().getScene();
                var sequenceID:String = Core.Modules.getSequenceList().getNext(theScene.getSequenceID());
                //if (!Core.Modules.getSequenceList().isLast(sequenceID)) {
                    var lastSequence:ISequence = Core.Modules.getSequence(sequenceID);
                    nextSceneID = lastSequence.getFirst();
                //}
            }
            // if for some reason that didn't work, just reload the current scene.
            if (nextSceneID == "" || nextSceneID == CoreConstants.UNDEFINED) {
				trace("next scene = null");
                nextSceneID = Core.getInstance().getScene().getID();
            }
            Core.getInstance().setScene(nextSceneID);
            
            // stop the next button from flashing
        }
        
        public function onNextButtonRollOut(evt:MouseEvent):void {
            closeFlashing();
        }
    
        public function onExitButton(evt:MouseEvent):void {
            Core.Popups.showDialog("exitWindow", PopupManager.MODE_ALWAYS_ON_TOP, {x:0,y:0});
        }
        
        public function onHomeButton(evt:MouseEvent):void {
            closeCaption();
            resetPauseButton();
			var sceneID:String
            if(Core.Modules.getHomeSceneID() != CoreConstants.UNDEFINED){
                // use home scene if it exists
                sceneID  = Core.Modules.getHomeSceneID();
            }else if(Core.Modules.getMenuSceneID() != CoreConstants.UNDEFINED){
                // retrieve the courses main menu
                sceneID = Core.Modules.getMenuSceneID();
            }else if (Core.Modules.getLessonSceneID() != CoreConstants.UNDEFINED) {
                // retrieve the first lesson menu
                sceneID = Core.Modules.getLessonSceneID();
            }else {
                // get the first page of the course
                var sequenceMainID:String = Core.Modules.getSequenceList().getFirst();
                var firstSequence:ISequence = Core.Modules.getSequence(sequenceMainID);
                sceneID = firstSequence.getFirst();
            }
            // retrieve the first lesson main menu
            Core.getInstance().setScene(sceneID);
        }    
        
        public function setAudioCompleteListenerEnabled(b:Boolean):void {
            mAudioCompleteListenerEnabled = b;
        }
        public function isAudioCompleteListenerEnabled():Boolean {
            return mAudioCompleteListenerEnabled;
        }
        
        public function onSceneCompleted(evt:Event = null):void {
            trace("onSceneCompleted caught!!!! in navigationmanagaer.as");
            Core.Renderer.setSceneComplete();
            var sceneID:String = Core.getInstance().getScene().getID();
            //var theSequence:ISequence = Core.Modules.getSequence(Core.getInstance().getScene().getSequenceID());
            if (mAudioCompleteListenerEnabled) {
                //&& !theSequence.isLast(sceneID)
                // turn on the tooltip if audio exists
                // set the button to flash
                var theScene:Scene = Core.getInstance().getScene();
                if(!Core.Modules.isLastScene(sceneID) ){
                    // show the flashing audio button 
                    if (theScene.getTemplate().getID() != CoreConstants.TEMPLATE_ASSESSMENT_INTRO 
                    && theScene.getTemplate().getID() != CoreConstants.TEMPLATE_ASSESSMENT_SUBMIT) {
						trace("Core.Modules.getQuestion(sceneID) = " + Core.Modules.getQuestion(sceneID));
						if (Core.Modules.getQuestion(sceneID) != null) {
							trace("Core.Modules.getQuestion(sceneID).getQuestionType() = " + Core.Modules.getQuestion(sceneID).getQuestionType());
							if(Core.Modules.getQuestion(sceneID).getQuestionType() != CoreConstants.QUESTION_TYPE_QUIZ && Core.Modules.getQuestion(sceneID).getQuestionType() != CoreConstants.QUESTION_TYPE_PRACTICE) {
								showFlashingNextButton(sceneID);
							}else {
								if (Core.getInstance().isDebugEnabled()) {
									showFlashingNextButton(sceneID);
								}
							}
						}else {
							//not a question
							//check flashing
							showFlashingNextButton(sceneID);
						}
                    }
                }
				if (theScene.getTemplate().getID() == CoreConstants.TEMPLATE_CUSTOMCONTENT) {
					trace("on scene complete");
					var hasAudio:Boolean = Core.getInstance().getScene().hasAudio();
					var audioPaused:Boolean = false;
					if (!hasAudio && !audioPaused) {
						//if is custom, does not have audio, set the audio is paused to true.
						trace("end of custom frame set audio to paused.");
						//Core.AudioObject.pause();
						//Core.AudioObject.setPaused(true);
					}
					
				}
                // if necessary, turn the pause button on
                updatePauseState();
            }
        }
		
		private function showFlashingNextButton(sceneID:String):void {
			trace("show flashing next button = " + Core.Modules.AssessmentModule.isInProgress());
			if (!Core.Modules.AssessmentModule.isInProgress()) {
				if(!Core.Modules.isLastScene(sceneID)){
					showFlashing();
				}
				Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).setState(CoreConstants.CONTROL_STATE_FLASHING);
				Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).update();
			}			
		}
		
        private function updatePauseState():void {
			trace("CONTROL_ID_PAUSE updatePauseState");
            trace("*Core.Renderer.getSceneComplete() = " + Core.Renderer.getSceneComplete());
            trace("*Core.Renderer.isPlaying() =" + Core.Renderer.isPlaying());
			trace("Core.getInstance().getScene().getTemplate().getID() = " + Core.getInstance().getScene().getTemplate().getID());
            var isPlayingType:Boolean;
            if (Core.getInstance().getScene().getTemplate().getID() != CoreConstants.TEMPLATE_CUSTOMCONTENT) {
                // if the scene is not a custom template then always assume it is not playing
                isPlayingType = false;
            }else {
                isPlayingType = Core.Renderer.isPlayingType();
				trace(" frame is custom template enable the pause button");
				pauseTitleText(PAUSE_STATE);
                Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_NORMAL);				
            }
			trace("Core.AudioObject.isAudioPlaying() = " + Core.AudioObject.isAudioPlaying());
			trace("isPlayingType = " + isPlayingType);
			trace("Core.Renderer.getSceneComplete() = " + Core.Renderer.getSceneComplete());
            if (!Core.AudioObject.isAudioPlaying() && !isPlayingType) {
                trace("set the play button to disabled");
                // audio is not playing,
                // timeline is not playing 
                // scene is not complete
                // then disable it.
                
                Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_DISABLED);
				pauseTitleText(PLAY_STATE);
            }else if (Core.getInstance().getScene().hasAudio()) {
				if (!Core.AudioObject.isAudioPlaying()) {
					pauseTitleText(PLAY_STATE);
				}else {
					pauseTitleText(PAUSE_STATE);
				}
                Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).setState(CoreConstants.CONTROL_STATE_NORMAL);
            }
            Core.Controls.item(CoreConstants.CONTROL_ID_PAUSE).update();
		
        }
		
        public function showFlashing():void {
			
            // stop the tween if transitioning and set the alpha to 100
            // this only happens once.
            if (mToolTip == null) {
                trace("tool tip show flashing");
            }
			if(flashingTween != null){
				flashingTween.kill();
			}
            setFlashingHighestDepth();
		
        }
        
        public function closeFlashing():void {

			if(mToolTip != null){
				flashingTween = new TweenLite(mToolTip, ProgramConstants.SCENE_FADE_SECONDS, {alpha:0 } );
            }
       }
        
        public function setFlashingHighestDepth():void {
			

			
			
			
			//Core.CourseObject.getNavigationWindow().swapChildren(mToolTip, Core.CourseObject.getNavigationWindow());
            //mToolTip.swapDepths(PopupManager.getNextLevel(Core.CourseObject.getNavigationWindow()));
			
        }
        
        public function isAudioEnabled():Boolean { return mAudioEnabled; }
        public function setAudioEnabled(b:Boolean):void { mAudioEnabled = b; }    
		
		public function addOutline() {
			trace("addOutline called");
			// setup outline
			var outlineModel:OutlineModel = new OutlineModel();
			
			Core.CourseObject.NavOutline = outlineModel;
			var outlineController:OutlineController = new OutlineController(outlineModel);			
			
			// add movieclip to the navigation window
			// set to the lowest depth.
			var maskMC:Sprite = new Sprite();
			maskMC.graphics.beginFill(0xFF0000);
			maskMC.graphics.drawRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
			Core.CourseObject.getNavigationWindow().addChildAt(maskMC, 0);
			
			outlineMC = new mainmenuoutline_mc() as OutlineView;
			outlineMC.name = "outlineMovieClip";
			outlineMC.initialize(outlineModel, outlineController);
			outlineMC.visible = false;
			outlineMC.y = 645;
			Core.CourseObject.getNavigationWindow().addChildAt(outlineMC, 0);
			
			outlineMC.mask = maskMC;
			outlineModel.initialize();
		}
		
		private function addCourseTitle():void {
			Core.CourseObject.getNavigationBox()
			var courseTitle:TextField = Core.CourseObject.getNavigationWindow().coursetitle_tfield;
			if (courseTitle !=  null) {
				courseTitle.text = Core.Modules.AdminDataModule.getTitle();
			}else {
				courseTitle.text = "";
			}
		}
		
		private function addTrainingCodeTitle():void {
			var courseTField:TextField = Core.CourseObject.getNavigationWindow().trainingcode_tfield;
			var courseCode:String = Core.Modules.AdminDataModule.getCourseCode();
			if (courseCode != null) {
				courseTField.text = "TRAINING CODE: "+courseCode;
			}else {
				courseTField.text = "TRAINING CODE: ";
			}
		}
        
        private function onKeyBoardEventUp(evt:KeyboardEvent):void {
            switch (evt.keyCode) {
				case Keyboard.NUMPAD_0:
					//var SCORMTest:MovieClip = new SCORM_window as MovieClip;
					//SCORMTest.x = 0;
					//SCORMTest.y = 0;
					//Core.getStage().addChild(SCORMTest);
				case Keyboard.SPACE :
					// var cType:String = Core.Modules.AdminDataModule.getCourseType();
					// && cType != "cd"
					// 
					if (Core.getInstance().isDebugEnabled()) {
						onSceneCompleted();
					}
					break;
				case Keyboard.LEFT :
					// behave as if the "back" button had been clicked
					if (_emptyMovieClip != null) {
						Core.CourseObject.getRoot().removeChild(_emptyMovieClip);
						_emptyMovieClip = null;
					}
					if (Core.Controls.item(CoreConstants.CONTROL_ID_BACK).isEnabled()) {
						onBackButton(null);
					}
					break;
				case Keyboard.UP :
					// behave as if the "re" button had been clicked
					if (Core.Controls.item(CoreConstants.CONTROL_ID_REPLAY).isEnabled()) {
						onReplayButton();
					}
					break;
				case Keyboard.RIGHT :
					// behave as if the "Next" button had been clicked
					if (Core.Controls.item(CoreConstants.CONTROL_ID_NEXT).isEnabled()) {
						onNextButton(null);
					}
					break; 
				case Keyboard.DOWN :
					break;
				case Keyboard.NUMPAD_5:
					_debuggerKeyDown = false;
					break;
				case Keyboard.NUMPAD_7:
					_responseLoggerKeyDown = false;
					break;
				case Keyboard.CONTROL:
					if (_debuggerKeyDown) {
						// opens the debug utility.
						if (_debugUtility != null) {
							_debugUtility.removeUtility();
						}else{
							_debugUtility = new DebugTrackingUtility(Core.getInstance().getRoot());
							_debugUtility.addEventListener(Event.REMOVED_FROM_STAGE, destroyDebugHandler, false, 0, true);
						}
					}
					if (_responseLoggerKeyDown) {
						// opens the course trackinging response window.
						if(_responseLogger != null){
							Core.getInstance().getRoot().removeChild(_responseLogger);
						}else {
							_responseLogger = new responseWindow as ResponseWindow;
							Core.getInstance().getRoot().addChild(_responseLogger);
							_responseLogger.addEventListener(Event.REMOVED_FROM_STAGE, destroyResponseHandler, false, 0, true);
						}
					}
					break;
				default :
					break;
            }
			
        }
		
		/**
		 * called when response window is removed from the stage.  
		 * @param	e
		 */
		private function destroyResponseHandler(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroyResponseHandler);
			if (_responseLogger != null) {
				_responseLogger = null;
			}
		}
		
		/**
		 * called when debug utility is removed from the stage.
		 * @param	e
		 */
		private function destroyDebugHandler(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroyDebugHandler);
			if (_debugUtility != null) {
				_debugUtility = null;
			}
		}
		
		private function onKeyBoardEventDown(evt:KeyboardEvent):void {
            switch (evt.keyCode) {
				case Keyboard.NUMPAD_5:
					//necessary for debug utility.
					_debuggerKeyDown = true;
					break;
				case Keyboard.NUMPAD_7:
					_responseLoggerKeyDown = true;
					break;
					
			}
		}
    }
}
