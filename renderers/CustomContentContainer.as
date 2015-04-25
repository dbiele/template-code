package renderers 
{
	import com.invision.Core;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.System;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class CustomContentContainer extends MovieClip 
	{
		private var mParentFrame:int;
		
		public function CustomContentContainer() 
		{
			addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
			if (Core.Renderer == null) {
				addEventListener(Event.ENTER_FRAME, onEnterFrameCall, false, 0, true);
			}else{
				addEventListener(Event.RENDER, onFrameRenderHandler, false, 0, true);
			}
			if (stage) {
				prepScene();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, prepScene, false, 0, true);
			}			
		}
		
		private function prepScene(evt:Event = null):void {
			trace("prepScene");
			if (hasEventListener(Event.ADDED_TO_STAGE)) {
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}
		}		
		
		private function onFrameRenderHandler(e:Event):void 
		{
			init();
		}
		
		public function onEnterFrameCall(evt:Event = null):void {
			var currentParent:MovieClip = this.parent as MovieClip;
			if (currentParent.currentFrame != mParentFrame) {
				init();
			}
		}
		
		private function init(evt:Event = null):void {
			trace("init called***");
			// initialise class here.
			// 1. manage any child components
			// 2. add any event listeners
			// 3. initialise any intervals
			// 4. initialise any Timers			
			// 5. redraw state if neccessary
			
			var parentMC:MovieClip = parent as MovieClip;
			mParentFrame = parentMC.currentFrame;
			if (Core.CourseObject != null) {
				if (Core.CourseObject.isBegun()) {
					visible = true;
					//render();
				} else {
					// compensates for template on first frame of timeline.  
					// only applies to movieclip templates on the timeline. 
					//addEventListener(Event.ENTER_FRAME, onContainerFrameEnter, false, 0, true);
				}
			}else {
				// wait for the course to begin
				visible = false;
				//addEventListener(Event.ENTER_FRAME, onContainerFrameEnter, false, 0, true);
			}
		}
		
		private function cleanUp(evt:Event):void {
			trace("custom container clean up");
			// suspend component here.		
			// 1. manage any child components			
			// 2. remove all listeners				
			// 3. stop all sounds
			// 4. release all references to cameras and microphones.
			// 5. call clearInterval() on any currently running intervals
			// 6. call stop() on any running Timer objects						
			// 7. Close any connected network objects, such as instances of:
			//		Loader, URLLoader, Socket, XMLSocket, LocalConnection, NetConnections, and NetStream.			
			
			removeEventListeners();	
			var currentNumChildren:int = numChildren;
			for (var i:int = 0; i < currentNumChildren; i++) {
				if (this.getChildAt(i) is MovieClip) {
					var contentObject:MovieClip = this.getChildAt(i) as MovieClip;
					contentObject.stop();
					contentObject = null;
				}
			}
			
			//content_mc.stop();
			//content_mc = null;
			
					
			this.stop();
			delete(this);
			System.gc();
			System.gc();			
		}
		
		private function removeEventListeners(): void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrameCall);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			if(hasEventListener(Event.ENTER_FRAME)){
				//removeEventListener(Event.ENTER_FRAME, onContainerFrameEnter);
			}
		}
		
	}

}