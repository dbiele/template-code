package renderers.view 
{
	import com.invision.client.components.BasicButton;
	import com.invision.controller.AudioEvent;
	import com.invision.Core;
	import com.invision.CoreConstants;
	import com.invision.ui.events.VideoControlsEvent;
	import com.invision.ui.VideoControls;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class VideoPlayerView extends MovieClip 
	{
		public var mc_ProgressBar:MovieClip;
		public var mc_Player:MovieClip;
		public var mc_player_bottom:Sprite;
		public var mc_lock:MovieClip;
		public var videospace_mc:MovieClip;
		static public const VIDEO_BUFFER_TIME:Number = 1;
		private var _hiVideoFile:String;
		private var _videoSlider:String;
		private var _totalSliderWidth:int;
		private var _sliderStartXPoint:Number;
		private var _sliderStartY:int;
		private var _videoControl:VideoControls;
		private var _videoDisabled:Boolean;
		private var _forwardButton:BasicButton;
		private var _rewindButton:BasicButton;
		private var _scrubberBar:BasicButton;
		private var _prePressWidth:Number;
		private var _content_video_mcs:MovieClip;
		private var _playerButton:BasicButton;
		private var _disabled:Boolean;
		private var _sliderSelected:Boolean;
		private var _pauseplayBasicButton:BasicButton;
		private var _video_loading:MovieClip;
		private var _videoBufferStartTime:Number;
		private var _videoBufferTimer:Timer;
		
		public function VideoPlayerView() 
		{
			trace("added VideoPlayerView");
		}
		
		public function initialize() {
			this.alpha = 0;
			_videoControl = Core.VideoControlsObject;//new VideoControls();
			
            var videoNode:XMLList = Core.getInstance().getScene().getXML().video.videofile

            _hiVideoFile = videoNode.@["videohigh"];
            _videoSlider = videoNode.@["videoslider"];
            
            if(_hiVideoFile == ""){
                _hiVideoFile = CoreConstants.UNDEFINED;
            }

            if(_videoSlider == ""){
                _videoSlider = CoreConstants.UNDEFINED;
            }

            _content_video_mcs = videospace_mc;

            _sliderStartXPoint = mc_ProgressBar.slider_mask_mc.x;
			_sliderStartY = mc_ProgressBar.mc_Slider.y;
            _totalSliderWidth = mc_ProgressBar.mc_Slider.width;
            
            _videoControl.disable();
            _videoControl.setSizes(mc_ProgressBar.slider_mask_mc.width-_totalSliderWidth, _sliderStartXPoint);
            _videoControl.addEventListener(VideoControlsEvent.ON_VIDEO_FOUND, onVideoFound, false, 0, true);
            _videoControl.addEventListener(VideoControlsEvent.ON_VIDEO_ERROR, onVideoError, false, 0, true);
            _videoControl.addEventListener(VideoControlsEvent.ON_VIDEO_PLAY_COMPLETE, onVideoPlayComplete, false, 0, true);
            _videoControl.addEventListener(VideoControlsEvent.ON_VIDEO_LOAD_COMPLETE, onVideoLoadComplete, false, 0, true);
            _videoControl.addEventListener(VideoControlsEvent.ON_VIDEO_LOAD_PROGRESS, onVideoLoadProgress, false, 0, true);    
            _videoControl.addEventListener(VideoControlsEvent.UPDATE_SCRUBBER_POSITION,updateScrubberPosition, false, 0, true);
            _videoControl.addEventListener(VideoControlsEvent.REPOSITION, onRepositionHandler, false, 0, true);
			_videoControl.addEventListener(VideoControlsEvent.ON_START_BUFFERING, onStartBufferingHandler, false, 0, true);
			_videoControl.addEventListener(VideoControlsEvent.ON_STOP_BUFFERING, onStopBufferingHandler, false, 0, true);
			Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_PLAY_PAUSE, onAudioPlayPause, false, 0, true);
			Core.getInstance().addEventListener(Core.ON_SCENE_END, onSceneEndHandler, false, 0, true);
            setupButtons();
			_videoControl.setAutoPlay(1);
            //this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedStageHandler, false, 0, true);	
		}
		
		private function onSceneEndHandler(e:Event):void 
		{
			endScene();
		}
		
		private function onStopBufferingHandler(e:VideoControlsEvent):void 
		{
			// remove buffering mc
			trace("onStopBufferingHandler");
			stopBufferTimer();
			removeLoadingWindow();
		}
		
		private function onStartBufferingHandler(e:VideoControlsEvent):void 
		{
			trace("onStartBufferingHandler");
			if(_videoBufferTimer == null){
				_videoBufferStartTime = new Date().getTime();
				_videoBufferTimer = new Timer(250);
				_videoBufferTimer.addEventListener(TimerEvent.TIMER, onBufferTimer, false, 0, true);
				_videoBufferTimer.start();
			}
			//addLoadingWindow();
		}
		
		private function stopBufferTimer():void 
		{
			trace("stop video timer");
			if(_videoBufferTimer != null){
				_videoBufferTimer.stop();
				_videoBufferTimer.removeEventListener(TimerEvent.TIMER, onBufferTimer);
				_videoBufferTimer = null;
			}
		}
		
		private function onBufferTimer(e:TimerEvent):void 
		{
			var currentTime:Number = new Date().getTime();
            var expiredTime:Number = Math.floor((currentTime-_videoBufferStartTime) / 1000);
			if (expiredTime >= VIDEO_BUFFER_TIME) {
				stopBufferTimer();
				addLoadingWindow("Buffering ...");
			}
		}
		
		private function addLoadingWindow(displayText:String):void {
			// display buffering mc
			if (_video_loading == null) {
				_video_loading = new video_loading_window();
				_video_loading.x = 0;
				_video_loading.y = videospace_mc.height - _video_loading.height;
				_video_loading.info_text.text = displayText;
				this.addChild(_video_loading);
			}			
		}
		
		private function removeLoadingWindow():void {
			if (_video_loading  != null) {
				this.removeChild(_video_loading);
				_video_loading = null;
			}
		}
		
		private function onRemovedStageHandler(e:Event):void 
		{
			trace("onRemovedStageHandler");
			trace("video player view onRemovedStageHandler");
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedStageHandler);
            _videoControl.clearVideo();
            _videoControl.clearIntervals();
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_FOUND, onVideoFound);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_ERROR, onVideoError);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_PLAY_COMPLETE, onVideoPlayComplete);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_LOAD_COMPLETE, onVideoLoadComplete);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_LOAD_PROGRESS, onVideoLoadProgress);
            _videoControl.removeEventListener(VideoControlsEvent.UPDATE_SCRUBBER_POSITION, updateScrubberPosition);
			_videoControl.removeEventListener(VideoControlsEvent.ON_START_BUFFERING, onStartBufferingHandler);
			_videoControl.removeEventListener(VideoControlsEvent.ON_STOP_BUFFERING, onStopBufferingHandler);
            Core.AudioObject.removeEventListener(AudioEvent.ON_AUDIO_PLAY_PAUSE, onAudioPlayPause);			
			_videoControl.clearIntervals();
			removeNavButtons();
		}
		
        public function endScene() {
			trace("video player view endScene");
			trace("video player endScene");
            _videoControl.clearVideo();
            _videoControl.clearIntervals();
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_FOUND, onVideoFound);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_ERROR, onVideoError);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_PLAY_COMPLETE, onVideoPlayComplete);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_LOAD_COMPLETE, onVideoLoadComplete);
            _videoControl.removeEventListener(VideoControlsEvent.ON_VIDEO_LOAD_PROGRESS, onVideoLoadProgress);
            _videoControl.removeEventListener(VideoControlsEvent.UPDATE_SCRUBBER_POSITION, updateScrubberPosition);
			_videoControl.removeEventListener(VideoControlsEvent.ON_START_BUFFERING, onStartBufferingHandler);
			_videoControl.removeEventListener(VideoControlsEvent.ON_STOP_BUFFERING, onStopBufferingHandler);
            Core.AudioObject.removeEventListener(AudioEvent.ON_AUDIO_PLAY_PAUSE, onAudioPlayPause);
			_videoControl.clearIntervals();
			removeNavButtons();
        }
		
        public function doProgressBar(totalPercent:Number){
            //mc_ProgressBar.mc_vsliderfill.width = _totalSliderWidth * totalPercent;
        }
		
		public function onRepositionHandler(evt:VideoControlsEvent):void {
			//this.x = (Core.getStage().stageWidth - evt.videoWidth) / 2) - 345;
			this.x = 508 - (evt.videoWidth/2);
			mc_player_bottom.y = evt.videoHeight;
			mc_player_bottom.width = evt.videoWidth;
			mc_lock.y = evt.videoHeight + 2;
			mc_Player.y = evt.videoHeight;
			mc_ProgressBar.y = evt.videoHeight + 5;
			// 82 is the white space in the video player.
			mc_ProgressBar.slider_mask_mc.width = evt.videoWidth - 86;
			mc_ProgressBar.scrubline_mc.width = evt.videoWidth - 82;
			
			_videoControl.setSizes(mc_ProgressBar.slider_mask_mc.width - _totalSliderWidth, _sliderStartXPoint);
			dispatchEvent(evt);
		}
		
        // ---------------------
        private function setupButtons(){
            disableControlButtons();
            if(_videoSlider == CoreConstants.UNDEFINED){
                if(!Core.getInstance().getScene().isVisited()){
                    disable();
                }else {
					enable();
				}
            }
            //--------------------
            mc_Player.gotoAndStop(1);
            mc_ProgressBar.mc_Slider.gotoAndStop(1);    
			// set to pause
            mc_Player.togglePlayPause.gotoAndStop(2);
            mc_ProgressBar.mc_Slider.x = _sliderStartXPoint;
            if(_hiVideoFile != CoreConstants.UNDEFINED){
                enableControlButtons();
                _videoControl.loadVideo(_hiVideoFile, _content_video_mcs.videoInstance, this , _content_video_mcs.videoBackground, false);
                // set the navigation pause button to pause
            }else if(_hiVideoFile == CoreConstants.UNDEFINED){
                //content_mcs.defaultText.text = "Video has not been added.";
            }
        }
		
        private function enableControlButtons() {
			trace("enableControlButtons");
			if(mc_Player.mc_forwardButton != null){
				mc_Player.mc_forwardButton.enabled = true;
			}
			mc_Player.enabled = true;
			if(mc_Player.mc_rewindButton != null){
				mc_Player.mc_rewindButton.enabled = true;
			}
        }
        private function disableControlButtons() {
			if(mc_Player.mc_forwardButton != null){
				mc_Player.mc_forwardButton.enabled = false;
			}
			mc_Player.enabled = false;
			if(mc_Player.mc_rewindButton != null){
				mc_Player.mc_rewindButton.enabled = false;
			}
        }  
		
        private function disable() {
			mc_lock.visible = true;
            _videoDisabled = true;
        }
        private function enable(){
            _videoDisabled = false;
			mc_lock.visible = false;
        }
		
        private function initializeNavButtons() {
			trace("initializeNavButtons called");
            _videoControl.enable();
			if(mc_Player != null){
				_playerButton = new BasicButton("playerbutton", mc_Player);
				_playerButton.addEventListener(MouseEvent.MOUSE_UP, playerCallHandler, false, 0, true);
			}
			if(mc_Player.mc_forwardButton != null){
				_forwardButton = new BasicButton("playerfastforward", mc_Player.mc_forwardButton);
				_forwardButton.addEventListener(MouseEvent.MOUSE_DOWN, startFFCall, false, 0, true);
			}
			
			if (mc_Player.mc_rewindButton != null) {
				_rewindButton = new BasicButton("playerrewind", mc_Player.mc_rewindButton);
				_rewindButton.addEventListener(MouseEvent.MOUSE_DOWN, startRWCall, false, 0, true);
			}
			mc_ProgressBar.mc_Slider.buttonMode = true;
			mc_ProgressBar.mc_Slider.useHandCursor = true;
			mc_ProgressBar.mc_Slider.addEventListener(MouseEvent.MOUSE_DOWN, scrubberPress, false, 0, true);
			mc_ProgressBar.mc_Slider.addEventListener(MouseEvent.ROLL_OVER, scrubberRollOver, false, 0, true);
            mc_ProgressBar.mc_Slider.addEventListener(MouseEvent.ROLL_OUT, scrubberRollOut, false, 0, true);
			
            //set button states
            if (!Core.getInstance().getScene().isVisited()) {
				if(mc_Player.mc_forwardButton != null){
					mc_Player.mc_forwardButton.gotoAndStop("lInactive");
					mc_Player.mc_forwardButton.enabled = false;
				}
            }else {
				if(mc_Player.mc_forwardButton != null){
					mc_Player.mc_forwardButton.gotoAndStop("lOver");
					mc_Player.mc_forwardButton.enabled = true;
				}
            }   
        }
		
        private function startFFCall(e:MouseEvent){
            if(!_videoDisabled){
                _videoControl.startFastForward();
				Core.getStage().addEventListener(MouseEvent.MOUSE_UP, endFFCall, false, 0, true);
            }
        }
    
        private function endFFCall(e:Event){
            if(!_videoDisabled){
                _videoControl.endFastForward();
				Core.getStage().removeEventListener(MouseEvent.MOUSE_UP, endFFCall);
            }
        }  
		
		private function startRWCall(e:MouseEvent){
            _videoControl.startRewind();
			Core.getStage().addEventListener(MouseEvent.MOUSE_UP, endRWCall, false, 0, true);
        }
    
        private function endRWCall(e:Event){
            _videoControl.endRewind();
			Core.getStage().removeEventListener(MouseEvent.MOUSE_UP, endRWCall);
        }
		
        private function scrubberPress(e:MouseEvent) {
			trace("scrubberPress");
            if (!_disabled && !_videoDisabled) {
				_sliderSelected = true;
				Core.getStage().addEventListener(MouseEvent.MOUSE_UP, scrubberRelease, false, 0, true);
                //_videoControl.setInter(false);
				var sliderRectangle:Rectangle = new Rectangle(_sliderStartXPoint, _sliderStartY, mc_ProgressBar.slider_mask_mc.width - _totalSliderWidth,0);
                mc_ProgressBar.mc_Slider.startDrag(false, sliderRectangle);
                if (!_videoDisabled) {
					var aPoint:Point = mc_ProgressBar.globalToLocal(new Point(mc_ProgressBar.mc_Slider.mouseX, mc_ProgressBar.mc_Slider.mouseY));
					trace("hit test point = "+mc_ProgressBar.mc_Slider.hitTestPoint(aPoint.x, aPoint.y));
                    mc_ProgressBar.mc_Slider.gotoAndStop(3);
                }else{
                    mc_ProgressBar.mc_Slider.gotoAndStop(2);
                }
                _prePressWidth = mc_ProgressBar.mc_Slider.x - _sliderStartXPoint;
				_videoControl.saveVideoState();
				_videoControl.setPause();
            }
        }
        private function scrubberRelease(evt:MouseEvent) {
            if (!_disabled && !_videoDisabled) {
				trace("scrubberRelease");
				_sliderSelected = false;
				Core.getStage().removeEventListener(MouseEvent.MOUSE_UP, scrubberRelease);
                mc_ProgressBar.mc_Slider.stopDrag();
                var currentWidth:Number = mc_ProgressBar.mc_Slider.x - _sliderStartXPoint;
                _videoControl.seeking(currentWidth,_prePressWidth);
                if(!_videoDisabled){
					mc_ProgressBar.mc_Slider.gotoAndStop(1);
                }else {
                    mc_ProgressBar.mc_Slider.gotoAndStop(2);
                }
				if (_videoControl.getSavedVideoState() == true && !_videoControl.isPlaying()) {
					_videoControl.playpause();
				}else {
					// just move the play head to the position.
					
				}
            }
        }
		
        private function scrubberRollOver(e:MouseEvent){
            if (!_disabled) {
                if(!_videoDisabled){
                    mc_ProgressBar.mc_Slider.gotoAndStop(3);
                }else{
                    mc_ProgressBar.mc_Slider.gotoAndStop(2);
                }
            }
        }
        private function scrubberRollOut(e:MouseEvent){
            if (!_disabled && !_sliderSelected) {
                mc_ProgressBar.mc_Slider.gotoAndStop(1);
            }
        }
		
        public function updateScrubberPosition(evt:VideoControlsEvent) {
			//trace("updateScrubberPosition");
			var currentPosition:int = _videoControl.position * (mc_ProgressBar.slider_mask_mc.width - _totalSliderWidth);
            mc_ProgressBar.mc_Slider.x = currentPosition + _sliderStartXPoint;
        }
		
		/**
		 * called when the audio is paused using the navigation window
		 * @param	evt
		 */
        public function onAudioPlayPause(evt:Event = null) {
			trace("video onAudioPlayPause");
            //video paused when navigation pause selected.
            if(Core.AudioObject.isPaused()){
                trace("set pause");
                _videoControl.setPause();
				mc_Player.togglePlayPause.gotoAndStop(1);
				//mc_Player.mc_playerButton.titleText.text = "PLAY"
            }else{
                trace("set play");
                _videoControl.setPlay();
				mc_Player.togglePlayPause.gotoAndStop(2);
                //mc_Player.mc_playerButton.titleText.text = "PAUSE"
            }
        }
		
        private function playerCallHandler(e:MouseEvent){
            if (!_disabled) {
                _videoControl.playpause();
                //Core.CourseObject.Nav.onPauseButton();
                if(_videoControl.getPlayerStatus()){
                    //mc_Player.mc_playerButton.titleText.text = "PAUSE"
                    mc_Player.togglePlayPause.gotoAndStop(2)
                }else{
                    //mc_Player.mc_playerButton.titleText.text = "PLAY"
                    mc_Player.togglePlayPause.gotoAndStop(1)
                }
            }
        }
		
        private function onVideoFound(evt:VideoControlsEvent) {
			this.alpha = 1;
            initializeNavButtons();
        }
		
        private function onVideoError(evt:VideoControlsEvent) {
            
        }
		
        private function onVideoPlayComplete(evt:VideoControlsEvent) {
            enable();
            if (mc_ProgressBar.mc_Slider.hitTestPoint(mouseX, mouseY, false)) {
                mc_ProgressBar.mc_Slider.gotoAndStop(3);
            }else{
                mc_ProgressBar.mc_Slider.gotoAndStop(1);
            }
            //mc_Player.mc_playerButton.titleText.text = "PLAY"
            mc_Player.togglePlayPause.gotoAndStop(1);
            //disable the fast forward button
            enableControlButtons();
			if(mc_Player.mc_forwardButton != null){
				mc_Player.mc_forwardButton.gotoAndPlay("lOut");
				mc_Player.mc_forwardButton.enabled = true; 
			}
        }
		
        private function onVideoLoadComplete(evt:VideoControlsEvent) {
			trace("onVideoLoadComplete");
			mc_ProgressBar.mc_vsliderfill.width = mc_ProgressBar.slider_mask_mc.width;
        }
		
        private function onVideoLoadProgress(evt:VideoControlsEvent) {
			trace("onVideoLoadProgress = evt.percentLoaded " + evt.percentLoaded);
			trace("mc_ProgressBar.slider_mask_mc.width = " + mc_ProgressBar.slider_mask_mc.width);
            mc_ProgressBar.mc_vsliderfill.width = mc_ProgressBar.slider_mask_mc.width * (evt.percentLoaded/100);
        }
		
        public function reset() {
			trace("video player view reset");
            _videoControl.clearVideo();
            super.reset();
        }
		
        private function removeNavButtons() {
			if(_forwardButton != null){ _forwardButton.clearMemory(); }
			if(_rewindButton != null){ _rewindButton.clearMemory(); }
			if(_scrubberBar != null){ _scrubberBar.clearMemory(); }
        }
		
	}

}