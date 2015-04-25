package components {
	import com.greensock.TweenLite;
	import com.invision.Audio;
	import com.invision.client.Course;
	import com.invision.events.AudioEvent;
	import com.invision.Core;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
    
    
    import com.invision.ui.Popup;
    import com.invision.interfaces.IPopup;
    
    
	/**
	 * Used to show the loading of audio files.
	 * only need to show animation with no need for actual progress indicator.
	 */
    public class AudioPreloaderWindow extends Popup implements IPopup {
		
		static private const TIMER_OUT_SECONDS:int = 3;
		static public const AUDIO_BUFFER_TIME:int = 2;
		
        private var theTweenAlpha:TweenLite;
        public var loading_mc:MovieClip;
        private var intervalID:Timer;
        private var mStartTime:Number
		
		private var _loadSessionInitialized:int = 0;
		private var _bufferTimer:Timer;
		
		public var detail_txt:TextField;

		private var _bufferStartTime:Number;
		private var _active:Boolean = false;
		private var _audioLoadSuccess:Boolean;
        
        public function AudioPreloaderWindow() {
			trace("AudioPreloaderWindow called");
			alpha = 0;
			addEventListener(Event.ADDED, initialize, false, 0, true);
        }  
		
		private function initialize(e:Event):void 
		{
			Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_LOADING, onAudioLoading, false, 0, true);
			Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_LOAD_SUCCESS, audioLoadSuccess, false, 0, true);
			Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_LOAD_ERROR, onAudioLoadError, false, 0, true);
			Core.AudioObject.addEventListener(AudioEvent.ON_AUDIO_SHOW_BUFFERING, onAudioShowBuffering, false, 0, true);
			Core.getInstance().addEventListener(Core.ON_SCENE_START, onSceneStart, false, 0, true);
			Core.getInstance().addEventListener(Core.ON_SCENE_END, onSceneEndHandler, false, 0, true);
		}
		
		private function onSceneEndHandler(e:Event):void 
		{
			trace("AudioPreloaderWindow onSceneEndHandler");
			closeAllActions();
		}
		
		private function onSceneStart(e:Event):void 
		{
			trace("AudioPreloaderWindow onSceneStart");
		}
		
		/**
		 * returns all values to original state.
		 */
		private function closeAllActions():void {
			stopAllTimers();
			closeBufferInfo();
			hideWindow(true);
		}
		
		private function stopAllTimers():void 
		{
			stopPreloadingTimer();
			stopBufferTimer();
		}
		
		private function onAudioLoadError(e:Event):void 
		{
			closeAllActions();
		}
		
        private function onAudioLoading(event:Event):void {
			var currentAudio:Audio = event.currentTarget as Audio;
			var currentPercent:uint = currentAudio.getPercentLoaded();
            if (currentPercent == 100) {
                hideWindow();
            }else {
                //mAudioPreloaderWindow.audioLoading(currentPercent);
				trace("AudioPreloaderWindow onAudioLoading");
				audioLoading(currentPercent);
            }    
        }
		
		private function audioLoadSuccess(event:Event):void {
			trace("AudioPreloaderWindow success");
			_audioLoadSuccess = true;
			closeAllActions();
        }
		
		private function onAudioShowBuffering(e:Event):void 
		{
			trace("AudioPreloaderWindow show buffering");
			addBufferingTimer();
		}		
		
		private function addBufferingTimer():void 
		{
			if (_bufferTimer == null) {
				_bufferStartTime = new Date().getTime();
				_bufferTimer = new Timer(250);
				_bufferTimer.addEventListener(TimerEvent.TIMER, onBufferTimerHandler, false, 0, true);
				_bufferTimer.start();
			}
		}
		
		private function onBufferTimerHandler(e:TimerEvent):void 
		{
			var currentTime:Number = new Date().getTime();
            var expiredTime:Number = Math.floor((currentTime-mStartTime) / 1000);
			trace("expiredTime = " + expiredTime);
			trace("_active = " + _active);
			if (expiredTime >= AUDIO_BUFFER_TIME && !_active) {
				detail_txt.text = "Audio Buffering ..."; 
				fadeIn();
			}
			if (!Core.AudioObject.getLoadedSound().isBuffering) {
				stopBufferTimer();
				closeBufferInfo();
				if (_audioLoadSuccess) {
					closeAllActions();
				}
			}
		}
		
		private function stopBufferTimer():void 
		{
			if(_bufferTimer != null){
				_bufferTimer.stop();
				_bufferTimer.removeEventListener(TimerEvent.TIMER, onBufferTimerHandler);
				_bufferTimer = null;
			}
		}
		
		private function closeBufferInfo():void 
		{
			detail_txt.text = "Audio Loading ...";
		}
		
		private function hideWindow(forceclose:Boolean = false):void {
			
			if (_loadSessionInitialized == 1 || forceclose) {
				trace("AudioPreloaderWindow hide in audio preloader window");
				_loadSessionInitialized = 0;
				if(intervalID != null){
					stopPreloadingTimer();
				}
				fadeOut();
			}
        }
		
		private function fadeOut():void 
		{
			if (_active) {
				TweenLite.to(this, 0.5, {alpha:0,onComplete:onTweenCompleteFadeOutHandler } );
			}
			_active = false;
			
		}
		
		private function fadeIn():void {
			if (!_active) {
				TweenLite.to(this, 0.5, {alpha:1,onComplete:onTweenCompleteFadeInHandler } );
			}
			_active = true;
		}
		
		private function onTweenCompleteFadeInHandler():void {
			
		}
		
		private function onTweenCompleteFadeOutHandler():void {
			
		}
		
		public function audioLoading(currentPercent:uint):void 
		{
			if (_loadSessionInitialized == 0) {
				// start the timer to wait for audio to display
				_audioLoadSuccess = false;
				startPreloadingTimer();
				_loadSessionInitialized = 1;
			}
			
		}
    
        private function dataTimer(evt:Event):void {
            var mcDate:Date = new Date();
            var currentTime:Number = mcDate.getTime();
            var expiredTime:Number = Math.floor((currentTime-mStartTime) / 1000);
			trace("AudioPreloaderWindow expiredTime = " + expiredTime);
            if (expiredTime >= TIMER_OUT_SECONDS) {
				// shows the window and listens when the audio has completed loading.
				trace("fade in after preload");
				fadeIn();
				stopPreloadingTimer();
            }
            if (_loadSessionInitialized == 0) {
                //close the window if the loading stops while in the process of waiting 
                stopPreloadingTimer();
            }
        }
		
		private function stopPreloadingTimer():void {
			if(intervalID != null){
				intervalID.stop();
				intervalID.removeEventListener(TimerEvent.TIMER, dataTimer);
				intervalID = null;
			}
		}
		
		private function startPreloadingTimer():void {
			trace("AudioPreloaderWindow startPreloadingTimer");
			var mcDate:Date = new Date();
			mStartTime = mcDate.getTime();
			intervalID = new Timer(500);
			intervalID.addEventListener(TimerEvent.TIMER, dataTimer, false,0,true);
			intervalID.start();			
		}
    }
}
