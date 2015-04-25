package components.views 
{
	import com.invision.client.components.BasicButton;
	import com.invision.client.components.CDLoginWindow;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class CDRegistrationIntro extends MovieClip 
	{
		private var _yesBasicButton:BasicButton;
		private var _noBasicButton:BasicButton;
		private var _currentView:CDLoginWindow;
		public var btnYes:MovieClip;
		public var btnNo:MovieClip;
		
		public function CDRegistrationIntro() 
		{
			
		}
		
		public function initialize(currentView:CDLoginWindow):void
		{
			_currentView = currentView;
			addButtonHandlers();
		}
		
		private function addButtonHandlers():void 
		{
			_yesBasicButton = new BasicButton("cdyes", btnYes);
			_noBasicButton = new BasicButton("cdno", btnNo);
			
			_yesBasicButton.addEventListener(MouseEvent.MOUSE_UP, onYesHandler, false, 0, true);
			_noBasicButton.addEventListener(MouseEvent.MOUSE_UP, onNoHandler, false, 0, true);
		}
		
		private function onNoHandler(e:MouseEvent):void 
		{
			_currentView.gotoFrame("register");
		}
		
		private function onYesHandler(e:MouseEvent):void 
		{
			_currentView.gotoFrame("login");
		}
		
	}

}