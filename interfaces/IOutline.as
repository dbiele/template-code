package interfaces 
{
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public interface IOutline extends IEventDispatcher {
		
		function setActiveID(sActiveID:String):void;
		function getActiveID():String;
		
		function setMaxWidth(numWidth:Number):void;
		function getMaxWidth():Number;
		
		function buildComplete():void;
		
		function setAutoClose(value:Boolean):void;
		function getAutoClose():Boolean;
		
		function setReviewMode(value:Boolean):void;
		function getReviewMode():Boolean;
		
	}

}