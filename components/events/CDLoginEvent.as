package components.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class CDLoginEvent extends Event 
	{
		public var errorDescription:String;
		static public const REGISTER_ERROR:String = "registerError";
		
		public function CDLoginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event{
			return new CDLoginEvent(type, bubbles, cancelable);
		}	
		
	}

}