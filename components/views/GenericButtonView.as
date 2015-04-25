package components.views
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class GenericButtonView extends MovieClip {
		private var origWidth:Number;
		private var origHeight:Number;
		private var _bTextName:String;
		private var _titleTextField:TextField;
		private var my_fmt:TextFormat;
		
		/**
		 * Used in conjunction with component parameters to resize button.
		 */
		public function GenericButtonView() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize, false, 0, true);
		}
		
		[Inspectable (name = "Button Text", variable = "bText", defaultValue = "", type = "String")]
		public function set bText(sVal:String):void {
			_bTextName = sVal;
			addText();
		}
		
		public function get bText():String {
			return _bTextName;
		}
		
		private function initialize(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			setSize(width, height);
			trace("scale x = " + scaleX);
			trace("scale y = " + scaleY);
			addTextField();
		}
		
		private function addTextField():void 
		{
			trace("add text field");
			my_fmt = new TextFormat();
			my_fmt.color = 0xFFFFFF;
			my_fmt.font = "Calibri";
			my_fmt.size = 12;
			my_fmt.align = TextFieldAutoSize.CENTER;
			
			_titleTextField = new TextField();
			_titleTextField.name = "mText";
			_titleTextField.x = 0;
			_titleTextField.y = 2.8;
			_titleTextField.width = origWidth;
			_titleTextField.height = origHeight;
			_titleTextField.embedFonts = true;
			_titleTextField.autoSize = TextFieldAutoSize.CENTER;
			_titleTextField.multiline = true;
			_titleTextField.wordWrap = true;
			_titleTextField.selectable = false;
			_titleTextField.antiAliasType = AntiAliasType.ADVANCED;
			_titleTextField.scaleX = 1 / scaleX;
			_titleTextField.scaleY = 1 / scaleY;
			_titleTextField.mouseEnabled = false;
			
			this.addChild(_titleTextField);
			trace("add textfield complete");
		}
		
		private function addText() {
			trace("add text field = " + bText);
			_titleTextField.text = bText;
			_titleTextField.setTextFormat(my_fmt);
		}
		
		protected function draw():void {
			// 
		}
		
		public function setSize(widthS:Number, heightS:Number):void {
			trace("setSize widthS = "+widthS+"heightS = "+heightS );
			if(!isNaN(widthS)){
				origWidth = widthS;
			}
			if(!isNaN(heightS)){
				origHeight = heightS;
			}
			

		}
		
	}

}