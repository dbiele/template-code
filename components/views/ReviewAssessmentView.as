package components.views {
	import com.greensock.TweenLite;
	import com.invision.client.components.BasicButton;
	import com.invision.client.components.ReviewAssessmentWindow;
	import com.invision.client.Course;
	import com.invision.data.List;
	import com.invision.interfaces.ISequence;
	import com.invision.ui.MovieClipEventProxy;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
    
    import com.invision.Core;
    import com.invision.client.ProgramConstants;
    import com.invision.client.components.NavButton;
    import com.invision.client.components.PreferencesWindow;
    import com.invision.ui.Popup;
    
    import com.invision.interfaces.IPopup;
	import flash.display.MovieClip;
    
    
    public class ReviewAssessmentView extends MovieClip {
		public var background_mc:Sprite;
		public var btnClose:MovieClip;
        private var mCloseButton:BasicButton;
		private var _model:ReviewAssessmentWindow;
		private var _displayContentMC:MovieClip;
		private var _lessonCount:int = 0;
        
        public function ReviewAssessmentView() {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage, false, 0, true);
        }
		
		private function onRemovedStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage);
			
		}
		
		public function initialize(model:ReviewAssessmentWindow):void {
			_model = model;
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			mCloseButton = new BasicButton("close", btnClose);
			mCloseButton.addEventListener(MouseEvent.MOUSE_UP, onCloseButton, false, 0, true);
			addContentMC();
			buildLessonItems();
			resizeBackgroundWindow(_displayContentMC.width,_displayContentMC.height);
		}
		
		private function buildLessonItems():void {
			var sequenceList:List = Core.Modules.getSequenceList();
			var sequenceCount:Number = sequenceList.getCount();
			for (var i:Number = 0; i < sequenceCount; i++) {
				var id:String = sequenceList.getItem(i);
				var theSequence:ISequence = Core.Modules.getSequence(id);
				createLesson(theSequence, _displayContentMC);
			}
		}
		
		private function createLesson(aSequence:ISequence, aContainer:MovieClip):void {
			trace("createLesson called");
			_lessonCount ++;
			var lessonItem:ReviewItemView = new review_lesson_item() as ReviewItemView;
			lessonItem.x = 0;
			lessonItem.y = 0;
			lessonItem.name = aSequence.getID();
			lessonItem.setID(aSequence.getID());
			lessonItem.setSequence(aSequence);
			lessonItem.setTitle(aSequence.getName());
			lessonItem.setLessonNumber(_lessonCount);
			aContainer.addChild(lessonItem);
			lessonItem.initialize(this);
		}
		
		private function addContentMC():void {
			_displayContentMC = new MovieClip();
			_displayContentMC.x = 26;
			_displayContentMC.y = 80;
			_displayContentMC.width = 660;
			_displayContentMC.height = 370;
			addChild(_displayContentMC);
			
			var lessonMask:Sprite = new Sprite();
			lessonMask.x = 26;
			lessonMask.y = 80;
			lessonMask.width = 660;
			lessonMask.height = 370;
			addChild(lessonMask);
			
			_displayContentMC.mask(lessonMask);
		}
		
        private function onCloseButton(evt:MouseEvent) {
			_model.hide();
			//Core.CourseObject.Nav.hideOverlay();
        }
		
		private function resizeBackgroundWindow(aWidth:int, aHeight:int):void {
			var startX:int = 195;
			var startY:int = 83;
			var offsetHeight:int = 85;
			var minimumHeight:int = 255;
			var offsetWidth:int = 40;
			var minimumWidth:int = 658;
			
			var currentHeight:int = ((aHeight + startY + offsetHeight) > (minimumHeight + offsetHeight))? aHeight + startY + offsetHeight: minimumHeight +offsetHeight;
			var currentWidth:int = ((aWidth +startX + offsetWidth) > (minimumWidth +offsetWidth))? aWidth +startX + offsetWidth: minimumWidth +offsetWidth;
			
			// move the close button
			TweenLite.to(btnClose, 0.5, { y:currentHeight - 33 } );
			TweenLite.to(background_mc, 0.5, { height:currentHeight, width:currentWidth } );
		}
		
    }
}