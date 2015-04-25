package components {
	import com.greensock.TweenLite;
	import com.invision.Core;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
    import flash.text.TextField;
    
	import flash.text.TextFormat;
    
    
    public class Dragger extends EventDispatcher {

        private var MC_DRAGGER_TEXT:String = "dragger_txt";
        
        private var content_mc:MovieClip;
        private var mMaster:MovieClip;
        
        private var mID:String;
        private var mMC:MovieClip;
        private var mTF:TextField;    
        private var mHome:Object;
        private var mLastLock:Object;
        
        static private const TIME_TWEEN:Number = 0.4;    
        
        public function Dragger(mcMaster:MovieClip, id:String, html:String, yPosition:Number) {            
            mMaster = mcMaster;
            content_mc = mMaster.parent as MovieClip;    
            // save the id
            mID = id;
            // create the dragger movie clip from library
			mMC = new Dragger_Style_01();
			mMC.x = mMaster.x;
			mMC.y = yPosition;
			mMC.gotoAndStop(1);
            content_mc.addChild(mMC);
			mMC.filters = mMaster.filters;    
            // put the correct text in the dragger
            mTF = mMC[MC_DRAGGER_TEXT];        
            mTF.type = "dynamic";
            mTF.embedFonts = true;
            mTF.autoSize = "left";
            mTF.selectable = false;
            mTF.multiline = true;
            mTF.wordWrap = true;
            mTF.htmlText = html;
            // center the text in the dragger
            var format:TextFormat = new TextFormat();
            format.align = "center";
            mTF.setTextFormat(format);
            // save the dragger's original position
            mHome = { x:mMC.x, y:mMC.y };                
        }
        
        public function getID():String { return mID; }
        public function getMC():MovieClip { return mMC; }
        
        public function addHandlers() {
            // set up the drag & drop event handlers
			mMC.buttonMode = true;
			mMC.useHandCursor = true;
			mMC.addEventListener(MouseEvent.MOUSE_DOWN, onPress, false, 0, true);
        }
        
        public function deleteHandlers() {
			mMC.buttonMode = false;
			mMC.useHandCursor = false;
            mMC.removeEventListener(MouseEvent.MOUSE_DOWN, onPress);
        }
        
        private function onPress(evt:MouseEvent) {
			Core.getStage().addEventListener(MouseEvent.MOUSE_UP, onRelease, false, 0, true);
			content_mc.swapChildrenAt(content_mc.getChildIndex(mMC), content_mc.numChildren - 1);     
			mMC.gotoAndStop("default");
            mMC.startDrag();
        }
        
        private function onRelease(evt:MouseEvent) {
			Core.getStage().removeEventListener(MouseEvent.MOUSE_UP, onRelease);
            mMC.stopDrag();
			dispatchEvent(new Event("onDraggerDrop"));
        }
        
        public function setPosition(xLoc:Number, yLoc:Number) {
			TweenLite.to(mMC, TIME_TWEEN, { x:xLoc, y:yLoc } );          
        }
    
        public function lockPosition(x:Number, y:Number) {
            mLastLock = { x:x, y:y };
            setPosition(x, y);
			//deleteHandlers();
        }
        
        public function relockPosition() {
			trace("mLastLock = " + mLastLock);
            if (mLastLock != null) {
                setPosition(mLastLock.x, mLastLock.y);
            } else {
                resetPosition();
            }
        }
        
        public function resetPosition() {
			trace("resetPosition");
            setPosition(mHome.x, mHome.y); 
        }      
		
		/**
		 * 
		 * @param	style "default", "placed", "correct", "incorrect", "corrected"
		 */
		public function setStyle(style:String = "default"):void 
		{
			switch(style) {
				case "default":
					mMC.gotoAndStop("default");
					break;
				case "placed":
					mMC.gotoAndStop("placed");
					break;
				case "correct":
					mMC.gotoAndStop("correct");
					break;
				case "incorrect":
					mMC.gotoAndStop("incorrect");
					break;
				case "corrected":
					mMC.gotoAndStop("corrected");
					break;
			}
		}
    }
}
