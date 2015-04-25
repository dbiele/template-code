package model 
{
	import com.invision.client.events.OutlineEvent;
	import com.invision.client.interfaces.IOutline;
	import com.invision.Core;
	import com.invision.data.List;
	import com.invision.interfaces.ISequence;
	import com.invision.Scene;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class OutlineModel extends EventDispatcher implements IOutline 
	{
		private var _autoClose:Boolean;
		private var _activeID:String = "";
		private var lessonXMLList:XMLList = new XMLList();
		private var _maxWidth:Number = 0;
		private var _reviewMode:Boolean;
		
		public function OutlineModel() 
		{
			
		}
		
		/**
		 * get the data from the sequences steps
		 * 
		 * 
		 */
		
		public function initialize():void {
			trace("OutlineModel initialize");
			dispatchEvent(new Event(OutlineEvent.BUILD_OUTLINE));
		}
		
		public function setMaxWidth(numWidth:Number):void {
			trace("setMaxWidth");
			trace("numWidth = " + numWidth);
			trace("_maxWidth = " + _maxWidth);
			var currentWidth:int = Math.ceil(numWidth);
			if(currentWidth > _maxWidth){
				_maxWidth = currentWidth;
			}
		}
		
		public function getMaxWidth():Number {
			return _maxWidth;
		}
		
		public function buildComplete():void {
			dispatchEvent(new Event(OutlineEvent.INITIALIZE_OUTLINE));
		}
		
		public function setAutoClose(value:Boolean):void {
			_autoClose = value;
		}
		
		public function getAutoClose():Boolean {
			return _autoClose;
		}
		
		public function setReviewMode(value:Boolean):void {
			_reviewMode = value;
		}
		
		public function getReviewMode():Boolean {
			return _reviewMode;
		}
		
		/**
		 * Builds the items in the outline view.
		 */
		
		private function onSequenceStatusChange(mStatus:String) {
			
		}
		
		public function getLessonsData():XMLList {
			return lessonXMLList;
		}
		
		/* INTERFACE com.invision.client.interfaces.IOutline */
		
		public function setActiveID(sActiveID:String):void 
		{
			_activeID = sActiveID;
		}
		
		public function getActiveID():String 
		{
			return _activeID;
		}
		
	}

}