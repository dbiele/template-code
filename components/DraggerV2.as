package components {
	import com.greensock.TweenLite;
	import com.invision.Core;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
   	import flash.text.TextField;
    
	
    
    public class DraggerV2 extends EventDispatcher {

        private var MC_DRAGGER_ICON:String = "icon_mc"
        private var MC_DRAGGER_TEXT:String = "textbox";
		
		static private const TIME_TWEEN:Number = 0.4; 
        
        private var content_mc:MovieClip;
        private var mMaster:MovieClip;
        
        private var mID:String;
        private var mMC:MovieClip;
        private var mTF:TextField;    
        private var mHome:Object;
        private var mLastLock:Object;
        
        public function DraggerV2(mcMaster:MovieClip, id:String, html:String, yPosition:Number, id2:String) {          
            mMaster = mcMaster;
            content_mc = mMaster.parent as MovieClip;  
            // save the id
            mID = id;
			mMC = new drag_letter_wrapper();
			
			mMC.x = mMaster.x;
			mMC.y = yPosition;
            //mMC = mMaster.duplicateMovieClip(mID, content_mc.getNextHighestDepth(), { _x:mMaster._x, _y:yPosition });
            mMC.filters = mMaster.filters;    
            // put the correct text in the dragger
            mTF = mMC.icon_mc.textbox;
            mTF.htmlText = id2;
			mMC.mouseChildren = false;
			content_mc.addChild(mMC);
            // save the dragger's original position
            mHome = { x:mMC.x, y:mMC.y };
			addHandlers();
        }
        
        public function getID():String { return mID; }
        public function getMC():MovieClip { return mMC; }
        
        public function addHandlers():void {
			trace("addHandlers");
            // set up the drag & drop event handlers
            mMC.buttonMode = true;
			mMC.useHandCursor = true;
			mMC.addEventListener(MouseEvent.MOUSE_DOWN, onPress, false, 0, true);   
        }
        
        public function deleteHandlers():void  {
			trace("deleteHandlers");
			mMC.buttonMode = false;
			mMC.useHandCursor = false;
            mMC.removeEventListener(MouseEvent.MOUSE_DOWN, onPress);
        }
        
        private function onPress(evt:MouseEvent) {
			trace("called press");
            mMC.filters = mMaster.filters;
			Core.getStage().addEventListener(MouseEvent.MOUSE_UP, onRelease, false, 0, true);
			content_mc.swapChildrenAt(content_mc.getChildIndex(mMC), content_mc.numChildren - 1);     
			//mMC.gotoAndStop("default");
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
            if (mLastLock != null) {
                setPosition(mLastLock.x, mLastLock.y);
            } else {
                resetPosition();
            }
        }
        
        public function highlightDragger():void {

            var myFilters:Array = new Array();
            myFilters.push(new GlowFilter(0xffff00,100,10,10,250,1,false,false));    
            mMC.filters = myFilters
        }
        
        public function resetPosition() { setPosition(mHome.x, mHome.y); }   
    }
}
