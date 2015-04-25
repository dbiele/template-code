package controllers 
{
	import com.invision.client.components.SliderInv;
	import com.invision.client.interfaces.ITimeline;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class TimelineController extends EventDispatcher 
	{
		public static const RIGHT_DIRECTION:String = "rightdirection";
		public static const LEFT_DIRECTION:String = "leftdirection";
		public static const UPDATE_POSITION:String = "onupdateposition";
		public static const UPDATE_STATUS:String = "onupdatstatus";
		public static const STOP_POSITION:String = "onstopposition";
		public static const SCRUB_SPEED:Number = 20;
		
		protected var mModel:SliderInv;
		private var dragStartPositionX:Number = 40;
		private var dragEndPositionX:Number = 515;
		private var totalSliderSpan:Number = 475;
		private var totalContentWidth:Number;
		private var currentLoc:Point;
		private var scrubPosition:String;
		private var enabled:Boolean = true;
		
		private var mTimer:Timer;
		
		public function TimelineController(aModel:ITimeline) 
		{
			mModel = aModel as SliderInv;
			totalContentWidth = mModel.getWidth();
		}
		
		public function mouseHandlerDrag(evt:MouseEvent):void {
			trace("evt = " + evt.type);
		}
		
		public function scrub(direction:String):void {
			trace("scrub called");
			scrubPosition = direction;
			dispatchEvent(new Event(UPDATE_POSITION));
		}
		
		public function getScrubDirection():String {
			return scrubPosition;
		}
		
		public function checkPosition(event:TimerEvent = null):void {
			trace("checkPosition called scrubPosition = " + scrubPosition);
			var currentPoint:Point = mModel.getLoc();
			var newPoint:Point;
			var updatex:Number
			if (scrubPosition == LEFT_DIRECTION ) {
				trace("add points");
				updatex = currentPoint.x + 20;
				newPoint = new Point(updatex, 0);

			}
			if (scrubPosition == RIGHT_DIRECTION) {
				updatex = currentPoint.x - 20;
				newPoint = new Point(updatex, 0);
			}
			mModel.setLoc(newPoint);
			
			dispatchEvent(new Event(UPDATE_POSITION));
		}
		
		public function subNavMoveComplete():void {
			dispatchEvent(new Event(SliderInv.UPDATE_LOCATION_COMPLETE));
		}
		
		public function stopScrub():void {
			if (mTimer != null) {
				mTimer.stop();
			}
			dispatchEvent(new Event(STOP_POSITION));
		}
		
		public function isEnabled():Boolean {
			return enabled;
		}
		
		public function setDisable():void {
			trace("setDisable called UPDATE_STATUS");
			enabled = false;
			dispatchEvent(new Event(UPDATE_STATUS));
		}
		
		public function setEnable():void {
			enabled = true;
			dispatchEvent(new Event(UPDATE_STATUS));
		}
		
		/**
		 * Move the timeline to the active id position and open it.
		 * @param	activeID
		 */
		public function gotoMilestone(activeID:String):void {
			trace("go to milestone activeID = " + activeID);
			mModel.setActiveID(activeID);
		}
		
		/**
		 * user clicks button down 
		 */ 
		public function startDragging():void {
			
		}
		
		/**
		 * users releases the button 
		 */ 
		public function stopDragging():void {
			
		}
		
	}

}