package components
{
	import fl.managers.IFocusManagerComponent;
	import flash.display.MovieClip;
	import fl.core.UIComponent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	
	[Inspectable (name = "refreshCDUData", variable = "refreshCDUData", type = "String", defaultValue = "")]
	
	[Inspectable (name = "cduData", variable = "cduData", type = "Array", defaultValue = "")]
	
	[Inspectable (name = "savedCDU", variable = "savedCDU", type = "Array", defaultValue = "")]
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class CDUView extends UIComponent {
		private var _refreshCDUData:String;
		private var _cduData:Array;
		private var _savedCDU:Array = [];
		
		//public var onscreenTField:TextField;
		public var tempTextField:TextField;
		
		public function CDUView() 
		{
			draw();
		}
		
		override protected function draw():void {
			trace("INFO: XMLTextAreaLivePreview.draw() 2: " + _width);
			refreshCDU();
			try{
				removeChild(tempTextField);
			} catch(e:Error) {
				
			}
			graphics.clear();
			graphics.beginFill(0xEEEEEE, 0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			graphics.lineStyle(1, 0x333333, 0.3);
			graphics.drawRect(0, 0, _width, _height);
			super.draw();
		}
		
		/*
		private function addComponentChild():void {
			var currentComponentMC:Sprite = new componentSymbol() as Sprite;
			currentComponentMC.x = 0;
			currentComponentMC.y = 0;
			this.addChild(currentComponentMC);
		}
		*/
		
		private function refreshCDU():void {
			for (var prop in savedCDU) {
				var format:TextFormat = new TextFormat();
				var componentValue:Array = this["saved" + savedCDU[prop]];
				var currentTextField:TextField = this[savedCDU[prop]] as TextField;
				currentTextField.text = componentValue[0];
				format.align = componentValue[1];
				currentTextField.setTextFormat(format);
			}			
		}
		
		override public function setSize(w:Number, h:Number):void {
			_width = w;
			_height = h;
			draw();
		}
		
		public override function get width():Number {
			return _width;
		}
		public override function set width(w:Number):void {
			setSize(w, height);
		}


		public override function get height():Number {
			return _height;
		}
		public override function set height(h:Number):void {
			setSize(width, h);
		}
		
		public function set refreshCDUData( value : String ) : void {
		        _refreshCDUData = value;
		}
		
		public function get refreshCDUData( ) : String {
		        return _refreshCDUData;
		}
		
		public function set cduData( value : Array ) : void {
		        _cduData = value;
		}
		
		public function get cduData( ) : Array {
		        return _cduData;
		}
		
		public function set savedCDU( value : Array ) : void {
		        _savedCDU = value;
				draw();
		}
		
		public function get savedCDU( ) : Array {
		        return _savedCDU;
		}
	}

}