package components {
	import com.greensock.TweenLite;
	import com.invision.client.Course;
	import com.invision.Core;
	import com.invision.client.ProgramConstants;
	import com.invision.interfaces.IPopup;
	import com.invision.ui.Popup;
	import flash.text.TextFieldAutoSize;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class BookmarkWindow extends Popup implements IPopup {

		public var bookmarkWindow:MovieClip;
		public var background_mc:MovieClip;
		
		public var mYesButton:BasicButton;
		public var mNoButton:BasicButton;
		
		public static const YES_BUTTON:String = "YES_BUTTON";
		public static const NO_BUTTON:String = "NO_BUTTON";
		
		/**
		 * Window appears at the start of course letting users know they can jump to where they left off last.
		 */
		
		public function BookmarkWindow() {
			trace("BookmarkWindow called");
			addEventListener(Event.REMOVED_FROM_STAGE, onMemoryCleanUp);
			Core.getStage().addEventListener(Event.RESIZE, resizeBackgroundCover, false, 0, true);
			resizeBackgroundCover();
			TweenLite.to(this, 0.5, { alpha: 1 } );
			mYesButton = new BasicButton("yes", bookmarkWindow.btnYes);
			mYesButton.addEventListener(MouseEvent.MOUSE_UP, onYesButton);
			mNoButton = new BasicButton("no", bookmarkWindow.btnNo);
			mNoButton.addEventListener(MouseEvent.MOUSE_UP, onNoButton);
			background_mc.useHandCursor = false;
			background_mc.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void { } );
			background_mc.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void { } );
		}
		
		public function initializeError(errorDescript:String):void 
		{
			bookmarkWindow.textbox.autoSize = TextFieldAutoSize.LEFT;
			bookmarkWindow.textbox.text = errorDescript;
			mNoButton.removeAllEventListeners();
			bookmarkWindow.btnNo.visible = false;
			bookmarkWindow.btnYes.y = bookmarkWindow.textbox.y + bookmarkWindow.textbox.height + 10;
			bookmarkWindow.background_sp.height = bookmarkWindow.btnYes.y + 40;
		}
		
		private function resizeBackgroundCover(event:Event = null):void {	
			if(!Core.CourseObject.getStubComplete()){
				var offset:Number = (Course.COURSE_WIDTH - Core.getStage().stageWidth)/2;
				background_mc.width = Core.getStage().stageWidth;
				background_mc.height = Core.getStage().stageHeight;
				background_mc.x = offset;
			}else{
				var currentWidth:Number = (Course.COURSE_WIDTH * Core.CourseObject.getScale());
				var currentHeight:Number = (Course.COURSE_HEIGHT * Core.CourseObject.getScale());
				var increment:Number = Course.COURSE_WIDTH / currentWidth;
				var incrementHeight:Number = Course.COURSE_HEIGHT / currentHeight;
				var offsetX:Number = (currentWidth - Core.getStage().stageWidth) / 2;
				var offsetY:Number = (currentHeight - Core.getStage().stageHeight) / 2;
				background_mc.x = increment * offsetX;
				background_mc.y = increment * offsetY;
				background_mc.width = Core.getStage().stageWidth * increment;
				background_mc.height = Core.getStage().stageHeight * incrementHeight;
			}
		}
		
		private function onYesButton(evt:MouseEvent):void {
			dispatchEvent(new Event(YES_BUTTON));
			
		}
		
		private function onNoButton(evt:MouseEvent):void {
			dispatchEvent(new Event(NO_BUTTON));
		}
		
		private function onMemoryCleanUp(evt:Event):void {
		
			trace("onMemoryCleanUp");
			Core.getStage().removeEventListener(Event.RESIZE, resizeBackgroundCover);
			mYesButton.removeAllEventListeners();
			mNoButton.removeAllEventListeners();
			background_mc.removeEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void { } );
			background_mc.removeEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void { } );
			
		}
		
	}
}