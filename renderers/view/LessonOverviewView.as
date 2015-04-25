package renderers.view 
{
	import com.invision.client.components.BasicButton;
	import com.invision.Core;
	import com.invision.CoreConstants;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class LessonOverviewView extends MovieClip 
	{
		
		public var nb101_mc:MovieClip;
		public var btn_yes:MovieClip
		public var btn_no:MovieClip;
		public var version_tfield:TextField;
		public var date_tfield:TextField;
		public var courseTitle_tfield:TextField;
		public var pageTitle_mc:TextField;
		public var helpMenuTField:TextField;
		public var yesnoTField:TextField;
		
		private var _basicButtonYes:BasicButton
		private var _basicButtonNo:BasicButton
		
		public function LessonOverviewView() {
			alpha = 0;
			Core.getInstance().addEventListener(Core.ON_SCENE_START, initialize, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveHandler, false, 0, true);
		}
		
		private function onRemoveHandler(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveHandler);
			if(_basicButtonYes != null){
				_basicButtonYes.removeAllEventListeners();
			}
			if(_basicButtonNo != null){
				_basicButtonNo.removeAllEventListeners();
			}
		}
		
		
		private function initialize(event:Event = null):void {
			var textYPos:int;
			alpha = 1;
			Core.getInstance().removeEventListener(Core.ON_SCENE_START, initialize);

			courseTitle_tfield.text = Core.Modules.AdminDataModule.getTitle();
			if (helpMenuTField != null) {
				courseTitle_tfield.multiline = true;
				courseTitle_tfield.wordWrap = true;
				courseTitle_tfield.autoSize = TextFieldAutoSize.LEFT;
				
				textYPos = courseTitle_tfield.y + courseTitle_tfield.height;
				pageTitle_mc.y = textYPos;
				
				textYPos = pageTitle_mc.y + 60;				
				
				helpMenuTField.y = textYPos;
				textYPos = helpMenuTField.y + 50;
				
				btn_yes.y = textYPos;
				btn_no.y = textYPos;
				
				textYPos = helpMenuTField.y + 86;
				yesnoTField.y = textYPos;
			}
			
			version_tfield.text = Core.Modules.AdminDataModule.getVersion();
			date_tfield.text = Core.Modules.AdminDataModule.getDateCreated();
			pageTitle_mc.text = Core.getInstance().getScene().getTitle();
			
			_basicButtonYes = new BasicButton("introyes", btn_yes);
			_basicButtonYes.addEventListener(MouseEvent.MOUSE_UP, onYesHandler, false, 0, true);
			
			_basicButtonNo = new BasicButton("introno", btn_no);
			_basicButtonNo.addEventListener(MouseEvent.MOUSE_UP, onNoHandler, false, 0, true);
			
			stop()
		}
		
		private function onYesHandler(mouseevent:MouseEvent):void {
			Core.CourseObject.Nav.showOverlay(CoreConstants.CONTROL_ID_HELP, "helpWindow");
		}
		
		private function onNoHandler(mouseevent:MouseEvent):void {
			Core.Modules.updateCompletionBookmark();
            Core.getInstance().getScene().setVisited();			
			Core.CourseObject.Nav.onNextButton();
		}
	}

}