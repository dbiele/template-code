package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class ScrollBarEvent extends Event 
	{
		
		public static const UPDATE_DIRECTION:String = "direction";
		
		public function ScrollBarEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		override public function clone():Event{
			return new OutlineEvent(type, bubbles, cancelable);
		}			
		
	}

}