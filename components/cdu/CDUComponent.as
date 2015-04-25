// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package components.cdu {

	import fl.core.UIComponent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class CDUComponent extends UIComponent {
		private var _savedCDUArray:Array;
		private var _savedheader1_lft:Array;

		public function CDUComponent() {
			super();
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage, false, 0, true);
		}
		
		private function onRemovedStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage);
			delete this;
		}
		
		function updateTextFields():void {
			if (savedCDU != null) {
				for (var i = 0; i < savedCDU.length; i++ ) {
					var format:TextFormat = new TextFormat();
					var componentVariableName:Array = this["saved" + savedCDU[i]];
					this[savedCDU[i]].text = componentVariableName[0];
					if(componentVariableName[1] != "undefined"){
						format.align = componentVariableName[1];
					}
					this[savedCDU[i]].setTextFormat(format);
				}
			}
		}
		
		override protected function draw():void {
			// called when all component values had been loaded.
			updateTextFields();
		}
		
		[Inspectable(name="savedCDU", variable="savedCDU", category="", verbose="0", defaultValue="", type="Array")]
		public function set savedCDU(arrayValue:Array):void {
			if (arrayValue == null) {

			}else {
				_savedCDUArray = arrayValue;
			}
		}
		
		public function get savedCDU():Array {
			return _savedCDUArray;
		}
	}

}
