package components.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class RankDropDownEvent extends Event 
	{
		static public const ON_RANK_SELECTED:String = "onRankSelected";
		public var rank:Number;
		
		public function RankDropDownEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		override public function clone():Event{
			return new RankDropDownEvent(type, bubbles, cancelable);
		}	
		
	}

}