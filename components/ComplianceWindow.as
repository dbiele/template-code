package components {
    
    import com.invision.Core;
    import com.invision.client.components.NavButton;
    import com.invision.ui.Popup;
	import flash.events.MouseEvent;
    
    import com.invision.interfaces.IPopup;
	import flash.display.MovieClip;
	import flash.text.TextField;
    
    
    public class ComplianceWindow extends Popup implements IPopup {

        
        private var btnAccept:MovieClip;
        private var mCloseButton:NavButton;    
        private var textbox:TextField;
        
        public function ComplianceWindow(){
            mCloseButton = new NavButton("accept", btnAccept);    
            mCloseButton.addEventListener(MouseEvent.MOUSE_UP, Delegate.create(this, onAcceptButton));
            textbox.htmlText = "Text goes here";
        }
        
        private function onAcceptButton() { 
            // start the course and close the window
            Core.CourseObject.startCourse();
            this._visible = false;
        }
        
        public function launchBrowserWindow(urlString:String):void {

            // open a browser window
            Core.CourseObject.openExternalFile(urlString);
        }
    
    }
}
