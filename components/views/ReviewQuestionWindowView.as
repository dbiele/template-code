package components.views 
{
	import com.invision.client.components.BasicButton;
	import com.invision.Core;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class ReviewQuestionWindowView extends MovieClip 
	{
		private var _reviewContentBasicButton:BasicButton;
		public var reviewContentButton:MovieClip;
		
		public function ReviewQuestionWindowView() 
		{
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage, false, 0, true);
			if (stage) {
				initialize();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, initialize, false, 0, true);
			}
		}
		
		private function onRemovedStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage);
			_reviewContentBasicButton.removeAllEventListeners();
			_reviewContentBasicButton = null;
		}
		
		private function initialize(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			_reviewContentBasicButton = new BasicButton("reviewcourse", reviewContentButton);
			_reviewContentBasicButton.addEventListener(MouseEvent.MOUSE_UP, onReviewHandlerButton, false, 0, true);
		}
		
		private function onReviewHandlerButton(e:MouseEvent):void 
		{
			Core.CourseObject.Nav.openMenuOutline();
			Core.CourseObject.NavOutline.setAutoClose(true);
			Core.CourseObject.NavOutline.setReviewMode(true);
		}
		
	}

}