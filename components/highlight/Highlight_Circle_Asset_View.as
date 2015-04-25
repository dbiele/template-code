package components.highlight 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class Highlight_Circle_Asset_View extends MovieClip 
	{
		public var mFill:Boolean;
		public var mcType:String;
		
		
		public function Highlight_Circle_Asset_View() 
		{
		}
		
		public function set highlightColor(colorNum:uint):void {
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = colorNum;
			var transform:Transform = new Transform(this);
			transform.colorTransform = colorTransform;
		}
		
		/**
		 * called from section of the timeline
		 */
		public function frameScriptComplete():void {
			dispatchEvent(new HighlightEvent(HighlightEvent.ON_HIGHLIGHT_DONE));
			if (mcType != "detail" && !mFill) {
				stop();
			}
		}
		
		/**
		 * called from the last frame of the timeline.
		 */
		public function frameScriptLast():void {
			stop();
		}
		
	}

}