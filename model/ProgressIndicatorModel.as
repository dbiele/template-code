package model 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class ProgressIndicatorModel extends EventDispatcher 
	{
		public static const UPDATE_PROGRESS:String = "onUpdateProgress"; 
		
		private var loadPercentage:int = 0;
		private var totalPageNumber:Number = 0;
		private var currentPageNumber:Number = 0;
		
		public function ProgressIndicatorModel(target:IEventDispatcher = null) {
			super(target);
		}
		
		public function updateProgress(_totalPageNumber:Number, _currentPageNumber:Number):void {
			trace("progress indicator mode updateProgress");
			totalPageNumber = _totalPageNumber;
			currentPageNumber = _currentPageNumber;
			loadPercentage = Math.round((_currentPageNumber / _totalPageNumber) * 100);
			dispatchEvent(new Event(UPDATE_PROGRESS));
		}
		
		/**
		 * values 0 - 100
		 * @return
		 */
		public function getPercentage():int {
			return loadPercentage;
		}
		
		public function getTotalPageNumber():Number {
			return totalPageNumber;
		}
		
		public function getCurrentPageNumber():Number {
			return currentPageNumber;
		}
	}

}