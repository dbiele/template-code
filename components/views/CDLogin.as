package components.views 
{
	import com.invision.client.components.BasicButton;
	import com.invision.client.components.CDLoginWindow;
	import com.invision.client.components.events.CDLoginEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class CDLogin extends MovieClip 
	{
		public var btnExit:MovieClip;
		public var btnSubmit:MovieClip;
		public var error_tfield:TextField;
		
		public var fname_tfield:TextField;
		public var lname_tfield:TextField;
		public var companyid_tfield:TextField;
		public var unitedid_tfield:TextField;
		
		private var _exitBasicButton:BasicButton;
		private var _submitBasicButton:BasicButton;
		private var _currentView:CDLoginWindow;
		
		public function CDLogin() 
		{
			
		}
		
		public function initialize(cDLoginWindow:CDLoginWindow):void 
		{
			_currentView = cDLoginWindow;
			_currentView.addEventListener(CDLoginEvent.REGISTER_ERROR, onRegisterError, false, 0, true);
			
			_exitBasicButton = new BasicButton("exit", btnExit);
			_submitBasicButton = new BasicButton("submit", btnSubmit);
			_exitBasicButton.addEventListener(MouseEvent.MOUSE_UP, onExitHandler, false, 0, true);
			_submitBasicButton.addEventListener(MouseEvent.MOUSE_UP, onSubmitHandler, false, 0, true);
			restrictValues();
		}
		
		private function restrictValues(){
			//fname_tfield.restrict = "^\u0020";
			//lname_tfield.restrict = "^\u0020";
		}
		
		private function onSubmitHandler(e:MouseEvent):void {
			_currentView.verifyUser(fname_tfield.text, lname_tfield.text, companyid_tfield.text, unitedid_tfield.text);
		}
		
		private function onRegisterError(e:CDLoginEvent):void 
		{
			error_tfield.text = e.errorDescription;
		}
		
		private function onExitHandler(e:MouseEvent):void 
		{
			_currentView.onExit();
		}
		
	}

}