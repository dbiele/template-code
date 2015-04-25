package components 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class AutosizeContentWindow extends MovieClip {
		
		public function AutosizeContentWindow() {
			if(stage){
				init();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			}
			
		}
		
		private function init(evt:Event = null):void {
			//var origWidth:Number  = this.width;
			//var origHeight:Number  = this.height;
			//var currentWindow:MovieClip = this.getChildAt(0) as MovieClip;
			//trace("this x = " + this.x);
			//trace("this x = " + this.y);
			//trace("currentWindow = " + currentWindow.name);
			var windowCenterGrid:Rectangle = new Rectangle(-147, -47, 294, 94);
			scale9Grid = windowCenterGrid;
			//scale9Grid = windowCenterGrid;
		}		
		
	}

}