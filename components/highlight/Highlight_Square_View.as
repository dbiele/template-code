package components.highlight 
{
	import com.greensock.easing.Bounce;
	import com.greensock.TweenLite;
	import fl.core.UIComponent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import fl.events.ComponentEvent;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class Highlight_Square_View extends UIComponent 
	{
		private var _mWidth:Number;
		private var _mHeight:Number;
		private var _mMinMovie:Number;
		private var _mMaxMovie:Number;
		private var _mSpeed:Number;
		private var _mType:String;
		private var _mColor:uint;
		private var _mFill:Boolean;
		private var _bEvent:Boolean;
		private var _highlightMC:Highlight_Square_Asset_View;
		
		public static var ON_MCDONE:String = "onMCDone";
		

		[Inspectable (name="Transition Scale Percent (0-2.0)", variable="mMinMovie", category="", verbose="0", defaultValue="1.0", type="Number")]
		//public var mMinMovie:Number;
		public function set mMinMovie(value:Number) {
			_mMinMovie = value;
		}
		
		public function get mMinMovie():Number {
			return _mMinMovie;
		}
		[Inspectable (name="Time Transition(.01-.4)", variable="mSpeed", category="", verbose="0", defaultValue=".2", type="Number")]
		//public var mSpeed:Number;
		
		public function set mSpeed(value:Number) {
			_mSpeed = value;
		}
		
		public function get mSpeed():Number {
			return _mSpeed;
		}
		[Inspectable (name="Type", variable="mType", category="", verbose="0", defaultValue="circle", enumeration="circle", type="List")]
		//public var mType:String;
		public function set mType(value:String):void {
			_mType = value;
		}
		
		public function get mType():String {
			return _mType;
		}
		[Inspectable (name="Color", variable="mColor", category="", verbose="0", defaultValue="#FF0000", type="Color")]
		//public var mColor:uint;
		public function set mColor(value:uint):void {
			trace("mColor = " + value);
			_mColor = value;
		}
		public function get mColor():uint {
			return _mColor;
		}
		[Inspectable (name = "Fill Center?", variable = "mFill", category = "", verbose = "0", defaultValue = "false", type = "Boolean")]
		//public var mFill:Boolean;
		public function set mFill(value:Boolean):void {
			_mFill = value;
		}
		
		public function get mFill():Boolean {
			return _mFill;
		}

		[Inspectable (name = "Wait for Event and then show?", variable = "bEvent", category = "", verbose = "0", defaultValue = "false", type = "Boolean")]
		public function set bEvent(value:Boolean):void {
			_bEvent = value;
		}
		
		public function get bEvent():Boolean {
			return _bEvent;
		}

		
		public function Highlight_Square_View() 
		{
			super();
			this.addEventListener(ON_MCDONE, onTriggerEventHandler, false, 0, true);
			this.addEventListener(ComponentEvent.SHOW, onShowHandler, false, 0, true);
			this.addEventListener(ComponentEvent.HIDE, onHideHandler, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage, false, 0, true);
		}
		
		private function onRemoveFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			removeChild(_highlightMC);
			_highlightMC = null;
		}
		
		/**
		 * call from other movieclips will show the highlight.
		 * @param	e
		 */
		public function onTriggerEventHandler(evt:Event):void 
		{
			trace("onTriggerEventHandler");
			var displayName:DisplayObject = evt.currentTarget as DisplayObject;
			trace("displayName.name = " + displayName.name);
			if (bEvent) {
				initialize();
			}
		}
		
		private function onHideHandler(e:Event):void
		{
			trace("hide handler called");
		}
		
		private function onShowHandler(e:Event):void 
		{
			trace("show handler called");
		}
		
		override protected function draw():void {
			this.scaleX = 1;
			this.scaleY = 1;
			trace("draw bEvent = " + bEvent);
			if (!bEvent) {
				initialize(true);
			}
		}
		
		
		override public function setSize(width:Number, height:Number):void {
			
			super.setSize(width, height);
			_mWidth = width;
			_mHeight = height;
		}
		
		
		private function onMCDoneHandler(evt:Event):void 
		{
			var displayName:DisplayObject = evt.currentTarget as DisplayObject;
			if (bEvent && _highlightMC == null) {
				initialize();
			}
		}
		
		public function initialize(checkRest:Boolean = false):void 
		{
			if (checkRest && _highlightMC != null) {
				_highlightMC.gotoAndPlay(1);
			}else {
				var highlightWidth:Number = _mWidth * (1 + mMinMovie);
				var highlightHeight:Number = _mHeight * (1 + mMinMovie);
				_highlightMC = new Highlight_Square_Asset_View;
				_highlightMC.scaleX = 1;
				_highlightMC.scaleY = 1;
				_highlightMC.x = _mWidth / 2;
				_highlightMC.y = _mHeight / 2;
				_highlightMC.width = highlightWidth;
				_highlightMC.height = highlightHeight;
				_highlightMC.highlightColor = mColor;
				_highlightMC.mFill = mFill;
				_highlightMC.addEventListener(HighlightEvent.ON_HIGHLIGHT_DONE, onMCDoneHandler, false, 0, true);
				addChild(_highlightMC);
				TweenLite.to(_highlightMC, mSpeed, { width:_mWidth, height:_mHeight, ease:Bounce.easeOut } );
			}
		}
		
	}

}