package interfaces 
{
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public interface ITimeline extends IEventDispatcher 
	{
		function setValue(intVal:Number):void;
		function getValue():Number;
		
		function setLoc(pLocation:Point):void;
		function getLoc():Point;
		
		function setStatus(milestoneKey:String, statusName:String, onInit:Boolean = false):void;
		function getStatus(milestoneKey:String):String;
		function checkStatus():Boolean;
		
		function setActiveID(activeID:String):void;
		function getActiveID():String;
		
		function setWidth(p:Number):void;
		function getWidth():Number;	
		
		function setMode(timelineStatus:String):void;
		function getMode():String;			
		
		function getManualActiveID():String;
	}

}