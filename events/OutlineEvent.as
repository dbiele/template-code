package events 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class OutlineEvent extends Event 
	{
		
		public static const OPEN:String = "open";
		public static const CLOSE:String = "close";
		public static const RESIZE:String = "resize";
		public static const BUILD_OUTLINE:String = "buildoutline";
		public static const INITIALIZE_OUTLINE:String = "initalizeoutline";
		public static const UPDATE:String = "update";
		public static const OUTLINE_MOUSEUP:String = "onMouseUp";
		
		public var triggerEvent:Event;
		

		public function OutlineEvent(type:String, bubbles:Boolean = false,
                                  cancelable:Boolean = false,
                                  triggerEvent:Event = null){
			super(type, bubbles, cancelable);
			this.triggerEvent = triggerEvent;
		}
		
		override public function clone():Event{
			return new OutlineEvent(type, bubbles, cancelable, triggerEvent);
		}	

		
	}

}