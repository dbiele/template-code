package components {
    import com.invision.Core;
    import com.invision.CoreConstants;
    
    import com.invision.interfaces.IControl;
    
    import com.invision.client.components.NavButton;
    
    
    public class CaptionButton extends NavButton implements IControl {

        
        public function CaptionButton(sID:String, mc:MovieClip) {
            super(sID, mc);
            super.setType(CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE);
        }
        
        private function buildToggleListener() {
            var mcep = this;
            this.removeListener(mListener);
            // create a default listener for "toggle" buttons
            trace("Core.CourseObject.getCaptionClip()._visible = "+Core.CourseObject.getCaptionClip().visible);
            mListener = new Object();
            mListener.toggle = Core.CourseObject.getCaptionClip().visible//false;
            mListener.onRollOver = function() {
                trace("onRollover, toggle = " + this.toggle);
                if (!this.toggle) {
                    mcep.mMC.gotoAndPlay("Over");
                }
            };
            mListener.onRollOut = function() {
                trace("onRollout, toggle = " + this.toggle);            
                if (!this.toggle) {
                    mcep.mMC.gotoAndPlay("Out");
                }
            };
            //mListener.onPress = function() {
                //trace("onpress, toggle = " + this.toggle);            
                //if (!this.toggle) {
                    //mcep.mMC.gotoAndPlay("Over");
                    //this.toggle = true;
                //}
            //};
            mListener.onRelease = function(){
                if (!this.toggle) {
                    mcep.mMC.gotoAndPlay("Out");
                    this.toggle = true;
                }
            }
            mListener.onReleaseOutside = function() {
                trace("onReleaseoutside, toggle = " + this.toggle);            
                if (!this.toggle) {
                    mcep.mMC.gotoAndPlay("Out");
                    this.toggle = true;
                }
            };        
            this.addListener(mListener);        
        }    
        
        public function update() {
            var s:String = this.getState();
            trace("C " + this.getID() + " = " + s);
            trace("update information -----------------");
            trace("mListener.toggle = Core.CourseObject.getCaptionClip()._visible = "+Core.CourseObject.getCaptionClip()._visible);
            trace(mListener.toggle);
            //mListener.toggle = Core.CourseObject.getCaptionClip()._visible
            switch (s) {
                case CoreConstants.CONTROL_STATE_ACTIVATED:            
                case CoreConstants.CONTROL_STATE_TOGGLE_ON:
                    mEnabled = true;
                    if (getType() == CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE) {
                        mListener.toggle = true;
                        mMC.gotoAndPlay("Over");
                    }
                    break;
                case CoreConstants.CONTROL_STATE_NORMAL:                
                case CoreConstants.CONTROL_STATE_TOGGLE_OFF:
                    mEnabled = true;
                    if (getType() == CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE) {
                        if(Core.CourseObject.getCaptionClip()._visible){
                            // if the transcript is open on prior page, keep it open and do nothing
                        }else{
                            // the transcript is closed on the prior page
                            mListener.toggle = false;
                            mMC.gotoAndPlay("Out");
                        }
                    }            
                    break;
                case CoreConstants.CONTROL_STATE_DISABLED:
                    mMC.gotoAndStop("Inactive");
                    mMC.useHandCursor = false;
                    if (getType() == CoreConstants.CONTROL_TYPE_BUTTON_TOGGLE) {
                        mListener.toggle = false;
                    }
                    mEnabled = false;
                    break;
                case CoreConstants.CONTROL_STATE_FLASHING:
                    mMC.gotoAndPlay("Flashing");
                    mMC.useHandCursor = true;                
                    mEnabled = true;
                    break;
                case CoreConstants.CONTROL_STATE_NOCHANGE:
                    break;
                default:
            }
        }        
    }
}
