package components.icons 
{
	import com.greensock.TweenLite;
	import fl.core.UIComponent;
	import fl.motion.Color;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class Icon_Arrow_View extends UIComponent 
	{
		static public const ON_TRANSITION_COMPLETE:String = "onTransitionComplete";
		private var _mWidth:Number;
		private var _mHeight:Number;
		private var _mType:String;
		private var _mColor:uint;
		private var _iconMC:MovieClip;
		
		[Inspectable (name="Transition Type", variable="mcFadeIn", category="", verbose="0", defaultValue="transition out", enumeration="transition out,transition in,none", type="List")]
		//public var mType:String;
		public function set mcFadeIn(value:String):void {
			_mType = value;
		}
		
		public function get mcFadeIn():String {
			return _mType;
		}	
		
		[Inspectable (name="Color", variable="mColor", category="", verbose="0", defaultValue="#FF0000", type="Color")]
		//public var mColor:uint;
		public function set mColor(value:uint):void {
			_mColor = value;
		}
		public function get mColor():uint {
			return _mColor;
		}		
		
		public function Icon_Arrow_View() 
		{
			super();
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage, false, 0, true);
		}
		
		private function onRemoveFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			if(_iconMC != null){
				removeChild(_iconMC);
				_iconMC = null;
			}
		}
		
		override protected function draw():void {
			super.draw();
			this.scaleX = 1;
			this.scaleY = 1;
			initialize(true);
		}
		
		
		override public function setSize(width:Number, height:Number):void {
			super.setSize(width, height);
			_mWidth = width;
			_mHeight = height;
		}
		
		public function set tintColor(colorNum:uint):void {
			var myColor:Color = new Color();
			myColor.setTint(colorNum, 0.5);
			var transform:Transform = new Transform(_iconMC);
			transform.colorTransform = myColor;
		}
		
		public function initialize(checkRest:Boolean = false):void 
		{
			if (checkRest && _iconMC != null) {
				_iconMC.gotoAndPlay(1);
			}else {
				var highlightWidth:Number = _mWidth;
				var highlightHeight:Number = _mHeight;
				// pulled from library
				_iconMC = new icon_arrow_asset;
				_iconMC.scaleX = 1;
				_iconMC.scaleY = 1;
				_iconMC.x = _mWidth / 2;
				_iconMC.y = _mHeight / 2;
				_iconMC.width = highlightWidth;
				_iconMC.height = highlightHeight;
				tintColor = mColor;
				if (mcFadeIn == "transition in") {
					_iconMC.alpha = 0;
					TweenLite.to(_iconMC, 0.5, { alpha:1} );
				}
				addChild(_iconMC);
				//TweenLite.to(_iconMC, mSpeed, { width:_mWidth, height:_mHeight, ease:Bounce.easeOut } );
			}
		}
		
		public function TransitionOut():void {
			if (mcFadeIn == "transition out") {
				fadeOut();
			}else {
				_iconMC.alpha = 0;
			}
		}
		
		public function fadeOut():void {
			TweenLite.to(_iconMC, 0.5, { alpha:0, onComplete:onTransitionFadeOutComplete} );
		}
		
		/**
		 * Dispatches onCompleteEvent when transition is finished
		 */
		private function onTransitionFadeOutComplete():void {
			dispatchEvent(new Event(ON_TRANSITION_COMPLETE));
		}
		
	}

}