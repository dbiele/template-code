package components {
	import flash.display.MovieClip;
    import com.invision.Core;
    import com.invision.client.renderers.MainMenu;
    import com.invision.data.List;
    import flash.filters.GlowFilter;
    import mx.utils.Delegate;
    import mx.events.EventDispatcher;
    
    import mx.transitions.Tween;
    import mx.transitions.easing.*;
    
    import flash.geom.ColorTransform;
    import flash.geom.Transform;
    
    import com.invision.CoreConstants;
    import com.invision.interfaces.ISequence;
    import com.invision.Scene;
    
    
    public class CourseMenuButton extends MainMenu {

    
        private var TWEEN_SECONDS:Number = 0.2;
        private var TWEEN_FPS:Number = 30;
        
        private var mSequence:ISequence;    
        private var mContainer:MovieClip;    
        private var mClip:MovieClip;
        private var mIcon:MovieClip;
        private var mHotSpot:MovieClip;
        
        private var mHome:Number;
        private var mIndex:Number;
        private var mTitle:String;
        private var mType:String;
        private var mState:String;
        private var mStatus:String;
        private var mID:Number
        private var mLinkID:String;
        
        private var mLoaded:Boolean;
        private var mDoubleLine:Boolean;
        
        private var mActivated:Boolean;
        private var mEnabled:Boolean;
        
        private var contentContainer:MovieClip;
            
        private var START_DEPTH:Number = 200;
        private var MCONTENTS:String = "content_mc";
        private var TFIELD:String = "textbox";
        private var LTFIELD:String = "textbox_lesson";
        private var HOTSPOT:String = "hotspot_mc";
        private var MCHECK:String = "check_mc";
        private var SKINCOLOR:String = "skincolor_mc"
        
        public function CourseMenuButton(seq:ISequence, container_mc:MovieClip, attach_mc:String, bIndex:Number, bX:Number, bY:Number, bState:String, bID:Number, bType:String, bTitle:String, bLinkID) {
            super(seq, container_mc,bIndex,bX, bY,bState,bID,bType,bTitle);
            mx.events.EventDispatcher.initialize(this);    
            mSequence = seq;
    
            mSequence.addEventListener("onSequenceStatusChange", this);        
            mSequence.addEventListener("onSequenceActivate", this);        
            mSequence.addEventListener("onSequenceDeactivate", this);    
            
            mContainer = container_mc;
            mIndex = bIndex;
            mHome = bY;
            mLoaded = false;
            mDoubleLine = false;
            mTitle = bTitle;
            mType = bType;
            mStatus = bState;
            mID = bID;
            mLinkID = bLinkID
            trace("----------xxxxxxxx--------------");
            trace("attach_mc = " + attach_mc);
            trace("mHome = " + mHome);
            trace("bx =" + bX);
            trace("bindex = " + mID);
            trace("mStatus = " + mStatus);
            trace("mType = "+mType)
            trace(START_DEPTH + mContainer.getNextHighestDepth());
            mClip = mContainer.attachMovie(attach_mc, "menuitem" + mID, START_DEPTH - mID, { _y: mHome, _x: bX });
            contentContainer = mClip[MCONTENTS];
            trace("clip = " + mClip);
            
            if(mStatus == CoreConstants.SEQUENCE_STATUS_INCOMPLETE){
                disable();
            }else{
                enable();
            }
            trace("mType = " + mType);
            if (mType == CoreConstants.SEQUENCE_TYPE_ASSESSMENT) {
                // change the color of the background
                trace("change the color");
                var backgroundColor:Number = 0x0951AA
                var colorTrans:ColorTransform = new ColorTransform();    
                colorTrans.rgb = backgroundColor;
                var trans:Transform = new Transform(contentContainer[SKINCOLOR]);
                trans.colorTransform = colorTrans;
            }
            
            onSequenceStatusChange(mStatus);
            //mActivated = false;
            //mEnabled = false;        
        }
        public static function get FRAME_OVER():String { return "Over"; }
        public static function get FRAME_OUT():String { return "Out"; }
        public static function get FRAME_DOWN():String { return "Down"; }
        public static function get FRAME_INACTIVE():String { return "Inactive"; }
        public static function get STATE_ENABLED():String { return "STATE_ENABLED"; }
        public static function get STATE_DISABLED():String { return "STATE_DISABLED"; }
        public static function get STATE_HIGHLIGHTED():String { return "STATE_HIGHLIGHTED"; }        
        
        public function activate() {
            // set the button to active
            contentContainer.gotoAndStop(FRAME_OUT);
            mState = CourseMenuButton.STATE_HIGHLIGHTED;
            mActivated = true;
            configure();
        }    
    
        public function deactivate() {
            // sets the button to reg state and allows button to be clicked.
            enable();        
            mActivated = false;    
        }
        
        public function isActivated():Boolean { return mActivated; }
        
        public function disable() { 
            contentContainer.useHandCursor = false;
            mState = CourseMenuButton.STATE_DISABLED;
            mEnabled = false;
            configure();
        }
        
        public function enable() { 
            contentContainer.gotoAndStop(FRAME_OUT); 
            contentContainer.useHandCursor = true;        
            mState = CourseMenuButton.STATE_ENABLED;
            mEnabled = true;
            configure();
        }
    
        public function isEnabled():Boolean { return mEnabled; }
        
        private function configure() {
            // configure text
            trace("configure");
            trace("mActivated = " + mActivated);
            if(!mActivated){
                trace("configure");
                // set the text format
                contentContainer[LTFIELD].text = "EXIT " + mID;
                contentContainer[TFIELD].htmlText = mTitle;
    
                // configure hot spot
    
                mHotSpot = contentContainer[HOTSPOT];
                
                // add events to hotspots
                mHotSpot.onPress = Delegate.create(this, onPress);    
                mHotSpot.onRelease = Delegate.create(this, onRelease);    
                mHotSpot.onReleaseOutside = Delegate.create(this, onRollOut);
                mHotSpot.onRollOver = Delegate.create(this, onRollOver);
                mHotSpot.onRollOut = Delegate.create(this, onRollOut)
                mHotSpot.onDragOut = Delegate.create(this,onRollOut)
            }
        }    
    
        public function getIndex():Number { return mIndex; }
        public function getHome():Number { return mHome; }
        
        private function onSequenceStatusChange(mStatus:String) {
            switch (mStatus) {
                case CoreConstants.SEQUENCE_STATUS_COMPLETE:
                    showComplete();
                    break;
                case CoreConstants.SEQUENCE_STATUS_INCOMPLETE:
                    disable();
                    break;
                case CoreConstants.SEQUENCE_STATUS_NEXT:
                    // search thru all of the sequeneces and check the status/completion of them
                    // if atleast one sub sequence is complete then show the 
                    // attempted graphic
                    var theScene:Scene = Core.Module.getScene(getLinkID());
                    var thisSequenceID:String = theScene.getSequenceID();
                    var theSequence:ISequence = Core.Module.getSequence(thisSequenceID)
                    var subSequenceList:List = theSequence.getSequenceList();
                    var sequenceCount:Number = subSequenceList.getCount();
                    var currentSequence = theSequence.getID();
                    var sequencesComplete:Boolean = true;
                    for (var i:Number = 0; i < sequenceCount; i++) {
                        // check if all the sub sequence are complete, if so then mark the sequence as complete
                        var id:String = subSequenceList.getItem(i);
                        var seq:ISequence = theSequence.getSequence(id);
                        if (seq.getStatus() == CoreConstants.SEQUENCE_STATUS_COMPLETE) {
                            trace("correct is not true");
                            sequencesComplete = false;
                        }
                    }                
                    if (!sequencesComplete) {
                        showAttempted();
                    }
                    deactivate();
                    break;
            }
        }
        
        private function onSequenceActivate(evt:Object) { }
        private function onSequenceDeactivate(evt:Object) { }
        
        private function showComplete() {
            trace("show check");
            var check_mc:MovieClip = contentContainer[MCHECK];
            check_mc.gotoAndStop(3);
        }
        
        private function showAttempted() {
            // show partial fill
            var check_mc:MovieClip = contentContainer[MCHECK];
            check_mc.gotoAndStop(2);
        }
            
        public function getSequence():ISequence { return mSequence; }
        
        public function getLinkID():String { return mLinkID; }
        
        private function onPress() {
            if (mEnabled && !mActivated) {
                trace("activated on press");
                contentContainer.gotoAndStop(FRAME_DOWN); 
                dispatchEvent({type:"onMainItemSelected", target:this});
            }
        }    
        
        private function onRelease() {
            if (mEnabled && !mActivated) {
                contentContainer.gotoAndStop(FRAME_OVER); 
            }
        }    
        
        private function onRollOver(){
            if (mEnabled && !mActivated) {
                contentContainer.gotoAndStop(FRAME_OVER); 
            }
        }
        
        private function onRollOut(){
            if (mEnabled && !mActivated) {
                contentContainer.gotoAndStop(FRAME_OUT); 
            }        
        }
        
        // functions defined by EventDispatcher
         function dispatchEvent() {};
         function addEventListener() {};
         function removeEventListener() {};        
    }
}
