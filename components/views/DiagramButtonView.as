package components.views 
{
	import com.greensock.easing.Back;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	//import fl.core.InvalidationType;
	//import fl.core.UIComponent;
	//import fl.managers.IFocusManagerComponent;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class DiagramButtonView extends MovieClip {

		private var origWidth:Number;
		private var origHeight:Number;
		private var _titleTextField:TextField;
		private var _lineSprite:Sprite;
		private var _bTextName:String;
		private var _bHighlight:Boolean;
		private var _bTrans:Boolean;
		private var _bHColor:uint;
		private var _bColor:uint;
		private var _bEvent:Boolean;
		private var _blendArray:String;
		private var _bEventName:String;
		private var my_fmt:TextFormat;
		
		public var mHighlightYellow:Sprite;
		public var mHighlight:Sprite;
		public var mBackground:Sprite;
		
		static public const ON_MC_DONE:String = "onMCDone";
		
		public function DiagramButtonView() 
		{
			super();
			addEventListener(Event.EXIT_FRAME, initialize, false, 0, true);
			//addEventListener(Event.ADDED_TO_STAGE, initialize, false, 0, true);
		}
		
		private function initialize(e:Event = null):void 
		{
			//removeEventListener(Event.ADDED_TO_STAGE, initialize);
			removeEventListener(Event.EXIT_FRAME, initialize);
			setSize(width, height);
			scaleX = 1;
			scaleY = 1;
			addTextField();
			setHighlights();
			setBackGround();
			transitionHighlights();
			createLine();
			updateColor();
			updateBlendMode();
			addText();
		}
		
		[Inspectable (name = "Button Text", variable = "bText", defaultValue = "", type = "String")]
		public function set bText(sVal:String):void {
			_bTextName = sVal;
			
			//invalidate(InvalidationType.STATE);
		}
		
		public function get bText():String {
			return _bTextName;
		}
		
		[Inspectable (name = "Highlight On", variable="bHighlight", defaultValue = "false", type = "Boolean")]
		public function set bHighlight(bVal:Boolean):void {
			_bHighlight = bVal;
			//invalidate(InvalidationType.STATE);
		}
		
		public function get bHighlight():Boolean {
			return _bHighlight;
		}
		
		[Inspectable (name = "Tranistion On", variable="bTrans", defaultValue = "false", type = "Boolean")]
		public function set bTrans(bVal:Boolean):void {
			_bTrans = bVal;
			//invalidate(InvalidationType.STATE);
		}
		
		public function get bTrans():Boolean {
			return _bTrans;
		}
		
		[Inspectable (name = "Highlight Color", variable="bHColor", defaultValue = "0x000000", type = "Color")]
		public function set bHColor(bVal:uint):void {
			_bHColor = bVal;
			//invalidate(InvalidationType.STATE);
		}
		
		public function get bHColor():uint {
			return _bHColor;
		}
		
		[Inspectable (name = "Text Color", variable = "bColor", defaultValue = "0x000000", type = "Color")]
		public function set bColor(bVal:uint):void {
			_bColor = bVal;
			//invalidate(InvalidationType.STATE);
		}
		
		public function get bColor():uint {
			return _bColor;
		}
		
		[Inspectable (name = "Blend Mode", variable="blendArray", defaultValue = "normal,layer,multiply,screen,lighten,darken,difference,add,subtract,invert", type = "List")]
		public function set blendArray(sVal:String):void {
			_blendArray = sVal;
			//invalidate(InvalidationType.STATE);
		}
		
		public function get blendArray():String {
			return _blendArray;
		}
		
		[Inspectable (name = "Wait for Event", variable="bEvent", defaultValue = "false", type = "Boolean")]
		public function set bEvent(bVal:Boolean):void {
			_bEvent = bVal;
			//invalidate(InvalidationType.STATE);
		}
		
		public function get bEvent():Boolean {
			return _bEvent;
		}
		
		[Inspectable (name = "Wait on Movie", variable="bEventName", defaultValue = "", type = "String")]
		public function set bEventName(sVal:String):void {
			_bEventName = sVal;
			//invalidate(InvalidationType.STATE);
		}
		
		public function get bEventName():String {
			return _bEventName;
		}
		
		protected function draw():void {
			trace("diagram draw");
			trace("2 diagram setSize = width"+origHeight);
			//initialize();
		}
		
		public function setSize(widthS:Number, heightS:Number):void {
			if(!isNaN(widthS)){
				origWidth = widthS;
			}
			if(!isNaN(heightS)){
				origHeight = heightS;
			}
		}
		
		private function updateBlendMode():void 
		{
			this.blendMode = blendArray;
		}
		
		private function updateColor():void 
		{
			if (bHColor != 0) {
				var c:ColorTransform = new ColorTransform();
				c.color = (bHColor);
				mHighlightYellow.transform.colorTransform = c; 
			}
		}
		
		private function createLine():void 
		{
			trace("origWidth = " + origWidth);
			_lineSprite = new Sprite();
			_lineSprite.graphics.beginFill(0x0000FF, 0);
			_lineSprite.graphics.lineStyle(1, bHColor, 1);
			_lineSprite.graphics.drawRect(0, 0, origWidth, origHeight);
			_lineSprite.graphics.endFill();
			this.addChild(_lineSprite);
		}
		
		private function setBackGround():void 
		{
			mBackground.width = origWidth;
		}
		
		private function setHighlights():void 
		{
			var diffH:Number = 0;
			if (_titleTextField.height>33) {
				diffH = _titleTextField.height+18;
				origHeight = diffH;
				mHighlightYellow.y += (origHeight-mHighlightYellow.height)/2;
				mHighlight.height = diffH-6;
				mHighlightYellow.height = origHeight;
				mBackground.height = diffH;
			} else {
				mHighlightYellow.y += (origHeight-mHighlightYellow.height)/2;
				mBackground.height = origHeight;
				mHighlightYellow.height = origHeight;
			}
			mHighlight.width = origWidth - 6;
			mHighlightYellow.x += (origWidth-mHighlightYellow.width)/2;
			mHighlightYellow.width = origWidth;
		}
		
		private function transitionHighlights():void 
		{
			if (bHighlight && !bEvent) {
				if (bTrans) {
					addTransition();
				} else {
					mHighlightYellow.alpha = 1;
					dispatchEvent(new Event(ON_MC_DONE));
				}
			}else {
				addEventListener(bEventName, onEventTriggered, false, 0, true);
			}
		}
		
		// called when custom event called from somewhere.
		private function onEventTriggered(e:Event):void 
		{
			if (bTrans) {
				addTransition();
			} else {
				mHighlightYellow.alpha = 1;
				dispatchEvent(new Event(ON_MC_DONE));
			}			
		}
		
		private function addTransition():void {
			TweenMax.to(mHighlightYellow, 0.5, { easing:Back.easeOut, onComplete:onTransitionComplete } );
			bHColor = 0xCC9900;
			mHighlightYellow.alpha = 1;
		}
		
		private function onTransitionComplete():void {
			dispatchEvent(new Event(ON_MC_DONE));
		}
		
		private function addTextField():void 
		{
			my_fmt = new TextFormat();
			trace("bColor = " + bColor);
			my_fmt.color = bColor;
			my_fmt.font = "Arial";
			my_fmt.size = 21;
			my_fmt.bold = true;
			my_fmt.align = "center";
			
			_titleTextField = new TextField();
			_titleTextField.name = "mText";
			_titleTextField.x = 0;
			_titleTextField.y = 7;
			_titleTextField.width = origWidth;
			_titleTextField.height = origHeight;
			_titleTextField.embedFonts = true;
			_titleTextField.autoSize = TextFieldAutoSize.CENTER;
			_titleTextField.multiline = true;
			_titleTextField.wordWrap = true;
			_titleTextField.selectable = false;
			_titleTextField.antiAliasType = AntiAliasType.ADVANCED;
			_titleTextField.mouseEnabled = false;
			//_titleTextField.text = bText;
			//_titleTextField.setTextFormat(my_fmt);
			
			this.addChild(_titleTextField);
			
		}
		
		private function addText() {
			trace("add text field = " + bText);
			_titleTextField.text = bText;
			_titleTextField.setTextFormat(my_fmt);
		}
		
	}

}