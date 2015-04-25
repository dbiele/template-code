package renderers.view {
    
	import com.greensock.TweenLite;
	import com.invision.client.components.ErrorMediaAssetsWindow;
	import com.invision.Core;
	import com.invision.CoreConstants;
	import com.invision.client.components.NavButton;
	import com.invision.interfaces.IPopup;
	import com.invision.ui.Graphic;
	import com.invision.ui.Popup;
	import com.invision.ui.Shape;
	import com.invision.utils.BasicButton;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.text.TextField;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
    
    
    public class ClickToLearnView extends Popup implements IPopup {

        
        // the following attributes need to be supplied in an initobject sent to attachMovie or Core.showDialog:
        public var mShape:Shape;
		public var shapeXML:XML;
		
        public var mURL:String;
        public var mTitle:String;
        public var mDetail:String;
        public var mAudio:String;
		
		public var bClose:MovieClip;
		public var imagecanvas_mc:MovieClip;
		public var background_mc:MovieClip;
		public var calloutTitle_txt:TextField;
		public var description_txt:TextField;
		
		
        public var clicktolearnWindow:MovieClip;
        private var mCloseButton:NavButton;
        private var mImage:MovieClip;
        private var mImageCanvasWidth:Number;
        private var mImageCanvasHeight:Number;
        private var mPreLoaderWindow:MovieClip;
		private var _closeBasicButton:BasicButton;
		private var _imageURL:String;
		private var _calloutX:Number;
		private var _calloutY:Number;
		private var _propertyType:String;
		private var _propertyCallout:Number;
		private var _windowTitle:String;
		private var _windowDescription:String;
		private var _windowAudio:String;
		private var _windowX:Number;
		private var _windowY:Number;
		private var _graphicLoader:Loader;
		private var _windowWidth:Number;
		private var _windowHeight:Number;
		
		public static const MINIMUM_WINDOW_WIDTH:Number = 320;
		public static const MINIMUM_WINDOW_HEIGHT:Number = 360;
        
        public function ClickToLearnView() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedStageHandler, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onUnloadMovie, false, 0, true);
        }
		
		private function onAddedStageHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedStageHandler);
			
			getValuesFromXML();
			resizeWindow();
			removeMouseHandlers();
			addButtonHandlers();
			
			calloutTitle_txt.htmlText = _windowTitle;
			description_txt.htmlText = _windowDescription;
			loadImageAudio();
			loadImageFile();
		}
		
		private function resizeWindow():void 
		{
			if(_windowWidth > MINIMUM_WINDOW_WIDTH){
				background_mc.width = _windowWidth;
				bClose.x = _windowWidth - 42;
				imagecanvas_mc.mask_mc.width = _windowWidth - 20;
				imagecanvas_mc.whitebackground_mc.width = _windowWidth - 20;
				calloutTitle_txt.width = _windowWidth - 80;
				description_txt.width = _windowWidth - 20;

			}
			
			if(_windowHeight > MINIMUM_WINDOW_HEIGHT){
				background_mc.height = _windowHeight;
				imagecanvas_mc.mask_mc.height = _windowHeight - 180;
				imagecanvas_mc.whitebackground_mc.height = _windowHeight - 180;
				description_txt.y = _windowHeight - 130;
			}
		}
		
		private function loadImageFile():void 
		{
			getImage(_imageURL);
		}
		
		private function getImage(graphicURL:String):void {
			if (graphicURL != null && graphicURL != CoreConstants.UNDEFINED && graphicURL != "") {
				var request:URLRequest = new URLRequest(graphicURL);
				_graphicLoader = new Loader();
				_graphicLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
				_graphicLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);
				_graphicLoader.contentLoaderInfo.addEventListener(Event.INIT, onLoadInit, false, 0, true);
				_graphicLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
				_graphicLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPError, false, 0, true);
				_graphicLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
				var error:int = 0;
				try{
					_graphicLoader.load(request)
				}catch(err:Error) {
					error = 1;
				}finally {
					trace("error = " + error);
					if (error == 0) {
					}else {
						Core.log("problem loading image window swf file");
					}
				}
			}else {
				fadeIn();
			}
		}
		
		private function clearEventListeners():void 
		{	
			_graphicLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_graphicLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_graphicLoader.contentLoaderInfo.removeEventListener(Event.INIT, onLoadInit);
			_graphicLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			_graphicLoader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPError);
			_graphicLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
		private function onHTTPError(e:HTTPStatusEvent):void 
		{
			switch(e.status) {
				case 0:
					// download is complete when running locally
					break;
				case 200:
					// download is complete over internet
					break;
				default:
					clearEventListeners();
					var errorWindow:ErrorMediaAssetsWindow = new errorMediaAssetsWindow() as ErrorMediaAssetsWindow;
					errorWindow.addText("HTTP Error", "Unable to find image: "+e.status);
					errorWindow.x = (imagecanvas_mc.width - errorWindow.width) / 2;
					errorWindow.y = 0;
					imagecanvas_mc.addChild(errorWindow);
					break;
			}
		}
		
        private function onLoadError(e:IOErrorEvent) { 
			trace("error onLoadError = " + e.text);
			clearEventListeners();
			var errorWindow:ErrorMediaAssetsWindow = new errorMediaAssetsWindow() as ErrorMediaAssetsWindow;
			errorWindow.addText("HTTP IO Error", "Unable to find image: "+e.text);
			errorWindow.x = (imagecanvas_mc.width - errorWindow.width) / 2;
			errorWindow.y = 0;
			imagecanvas_mc.addChild(errorWindow);
			fadeIn(); 
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void 
		{
			clearEventListeners();
			var errorWindow:ErrorMediaAssetsWindow = new errorMediaAssetsWindow() as ErrorMediaAssetsWindow;
			errorWindow.addText("Security Error", "Unable to find image");
			errorWindow.x = (imagecanvas_mc.width - errorWindow.width) / 2;
			errorWindow.y = 0;
			imagecanvas_mc.addChild(errorWindow);
			trace("error onSecurityError called");
			//bytesProgress.text = "Security Error";
		}
		
		private function onLoadProgress(evt:ProgressEvent):void { 
			// Invoked every time the loading content is written to the hard disk during the loading process (that is, between MovieClipLoader.onLoadStart and MovieClipLoader.onLoadComplete).
			// Core.log("onLoadProgress: loadedBytes = " + loadedBytes + ", totalBytes = " + totalBytes);
			dispatchEvent(new Event(Graphic.EVENT_PROGRESS));
		}
		
		private function getValuesFromXML():void 
		{
            _imageURL = shapeXML.@["image"];
            _calloutX = parseFloat(shapeXML.@["x"]);
            _calloutY = parseFloat(shapeXML.@["y"]);
            _propertyType = shapeXML.@["propertywindow"];
            _propertyCallout = parseFloat(shapeXML.@["propertycallout"]);
			_windowTitle = shapeXML.@["title"];
			_windowDescription = shapeXML.@["detail"];
			_windowAudio = shapeXML.@["audio"];
			_windowX = parseFloat(shapeXML.@["x"]);
			_windowY = parseFloat(shapeXML.@["y"]);
			_windowWidth = parseFloat(shapeXML.@["width"]);
			_windowHeight = parseFloat(shapeXML.@["height"]);
		}
		
		/**
		 * removes any mouse actions on the text fields
		 */
		private function removeMouseHandlers():void 
		{
			calloutTitle_txt.mouseEnabled = false;
			description_txt.mouseEnabled = false;
		}
		
		private function addButtonHandlers():void 
		{
			_closeBasicButton = new BasicButton("clicktolearnclose", bClose);
			_closeBasicButton.addEventListener(MouseEvent.MOUSE_UP, onCloseWindow, false, 0, true);
			background_mc.buttonMode = true;
			background_mc.useHandCursor = true;
			background_mc.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag, false, 0, true);
		}
		
		private function onStartDrag(e:MouseEvent):void 
		{
			Core.getStage().addEventListener(MouseEvent.MOUSE_UP, onStopDrag, false, 0, true);
			this.startDrag();
		}
		
		private function onStopDrag(e:MouseEvent):void 
		{
			Core.getStage().removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);
			this.stopDrag();
		}
		
		private function onCloseWindow(e:MouseEvent):void 
		{
			if(Core.getInstance().getScene().getTemplateID() == CoreConstants.TEMPLATE_CLICKTOLEARN){
				Core.getInstance().getRenderer().getObject().deactivateShape(mShape.getID());  
			}
			close();
		}
        
        private function addPreLoader():void {
			mPreLoaderWindow = new AudioPreloaderWindow() as AudioPreloaderWindow;
			clicktolearnWindow.imagecanvas_mc.imagespace.addChild(mPreLoaderWindow);
            //mPreLoaderWindow = clicktolearnWindow.imagecanvas_mc.imagespace.attachMovie("audiopreloaderWindow", "audiopreloaderWindow", 2,{_x:50,_y:15, _alpha:0});
            //mPreLoaderTween = new Tween(mPreLoaderWindow, "_alpha", Regular.easeOut, 0, 100, 2, true);
			TweenLite.to(mPreLoaderWindow, 1, { alpha:1 } );
        }
        
        private function onLoadComplete(evt:Event):void { 
			trace("onLoadComplete called");
			//TweenLite.killTweensOf(mPreLoaderWindow);
			//clicktolearnWindow.imagecanvas_mc.imagespace.removeChild(mPreLoaderWindow);
			clearEventListeners();
			var target_mc:Loader = evt.currentTarget.loader as Loader;
			imagecanvas_mc.imagespace.addChild(target_mc);
			fadeIn();
        }
        
        private function onLoadInit(evt:Event):void {
			var target_mc:Loader = evt.currentTarget.loader as Loader;
            var mcWidth:Number = target_mc.width;
            var mcHeight:Number = target_mc.height;
			//center the image in the content area
            target_mc.x = (imagecanvas_mc.width - mcWidth) / 2;
            target_mc.y = (imagecanvas_mc.height - mcHeight) / 2;
        }
        
        private function fadeIn():void {
            var w:Number = mShape.getWidth();
            var h:Number = mShape.getHeight();
            var center:Point = mShape.getCenter();
            mShape.getMovieClip().localToGlobal(center);
            Core.getInstance().getSceneContainer().globalToLocal(center);
            var xVal:Number = center.x;
            var yVal:Number = center.y;
            var baseMC:MovieClip = Core.getInstance().getRenderer().getImageContainer().getBaseLayer();
            var originalX:Number = (isNaN(_windowX)) ? this.x : _windowX+Core.getInstance().getRenderer().getImageContainer().getImageLayer().x + 6;
            var originalY:Number = (isNaN(_windowY)) ? this.y : _windowY + Core.getInstance().getRenderer().getImageContainer().getBaseLayer().y + 6;
			trace("original width = " + this.width);
            var originalW:Number = this.width;
            var originalH:Number = this.height;
            this.x = xVal;
            this.y = yVal;
            this.width = w;
            this.height = h;
			TweenLite.to(this, CoreConstants.TIME_IMAGE_TRANSITION, { x:originalX, y:originalY, width:originalW, height:originalH, alpha:1} );      
        }
        
        private function loadImageAudio():void {
            //if (loadImageAudio != null || loadImageAudio != "undefined") {
            var hasWindowAudio:Boolean = _windowAudio != null && _windowAudio != "" && _windowAudio != CoreConstants.UNDEFINED;
			trace("hasWindowAudio  " + hasWindowAudio);
			if (Core.Renderer.getScene().hasAudio() && hasWindowAudio) {
				trace("has audio");
				Core.AudioObject.stopAllAudio();
			}
			if (hasWindowAudio) {
				trace("_windowAudio 2 = " + _windowAudio);
				Core.AudioObject.stopEffects();
				Core.AudioObject.playEffect(_windowAudio);
			}
            //}
        }
        
        private function onUnloadMovie(evt:Event):void {
            Core.AudioObject.stopEffects();
			_closeBasicButton.clearMemory();
			background_mc.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			_graphicLoader = null;
        } 
    }
}
