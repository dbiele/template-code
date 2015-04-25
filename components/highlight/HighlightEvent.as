package components.highlight 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class HighlightEvent extends Event 
	{
		
		public static var ON_HIGHLIGHT_DONE:String = "onHighlightDone";
		
		public function HighlightEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		override public function clone():Event{
			return new HighlightEvent(type, bubbles, cancelable);
		}	
		
	}

}