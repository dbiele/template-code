package views 
{
	import com.greensock.TweenLite;
	import com.invision.client.components.BasicButton;
	import com.invision.client.controllers.OutlineController;
	import com.invision.client.events.OutlineEvent;
	import com.invision.client.interfaces.IOutline;
	import com.invision.client.model.OutlineModel;
	import com.invision.Core;
	import com.invision.CoreConstants;
	import com.invision.interfaces.ISequence;
	import com.invision.module.Lesson;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class OutlineItemView extends CompositeView 
	{
		public var title_tfield:TextField;
		public var status_mc:MovieClip;
		public var highlight_mc:MovieClip;
		public var hitarea_mc:Sprite;
		public var footer_mc:Sprite;
		public var begin_btn:MovieClip;
		public var lesson_time:TextField;
		public var lesson_num:TextField;
		
		public static const MAX_WIDTH:Number = 300;
		public static const STATUS_WIDTH:Number = 26;
		public static const OFFSET_WIDTH:Number = 60;
		public static const OFFSET_STATUS_BEGIN_WIDTH:int = 29;
		public static const LESSON_TIME_SPACER_WIDTH:int = 20;
		
		private var _mActiveID:String;
		private var _mWidth:Number;
		private var _mSequence:ISequence;
		private var _setSelected:Boolean = false;
		private var _status:String = "";
		private var _beginBasicButton:BasicButton;
		
		public function OutlineItemView() 
		{
			super();
			stop();
		}
		
		override public function initialize(aModel:IOutline, aController:OutlineController = null):void {
			super.initialize(aModel, aController);
			_mModel.addEventListener(OutlineEvent.INITIALIZE_OUTLINE, onBuildInitialized, false, 0, true);
			_mController.addEventListener(OutlineEvent.UPDATE, onControllUpdate, false, 0, true);
		}	
		
		public function setID(aSetID:String):void {
			trace("aSetID = " + aSetID);
			_mActiveID = aSetID;
		}
		
		public function getID():String {
			return _mActiveID;
		}
		
		public function setSequence(aSequence:ISequence):void {
			trace("outlineitemview setSequence aSequence id = "+aSequence.getID());
			_mSequence = aSequence;
			_mSequence.addEventListener(Lesson.ON_SEQUENCE_STATUS_CHANGE, onStatusChangeHandler, false, 0, true);
			_mSequence.addEventListener(Lesson.ON_SEQUENCE_ACTIVATE, onSequenceActivateHandler, false, 0, true);
		}
		
		private function onSequenceActivateHandler(event:Event):void {
			trace("outlineitemview onSequenceActivateHandler");
			updateStatus();
		}
		
		private function onStatusChangeHandler(event:Event):void {
			trace("outlineitemview onStatusChangeHandler");
			updateStatus();
		}
		
		public function setTitle(aTitle:String):void {
			trace("setTitle");
			title_tfield.autoSize = TextFieldAutoSize.LEFT;
			title_tfield.wordWrap = false;
			title_tfield.multiline = false;
			title_tfield.htmlText = aTitle;
			trace("set title = " + title_tfield.width);
			if (title_tfield.width > OutlineView.MAX_TEXT_WIDTH) {
				trace("wrap text");
				title_tfield.width = OutlineView.MAX_TEXT_WIDTH;
				title_tfield.wordWrap = true;
				title_tfield.multiline = true;
			}
			setWidth(title_tfield.width);
		}
		
		public function onBuildInitialized(event:Event):void {
			updateLabel();
			_mController.updateContainer(getID());
			updateStatus();
			initializeButton();
		}
		
		private function initializeButton():void 
		{
			trace("initializeButton called");
			//_beginBasicButton = new BasicButton("beginlesson", begin_btn);
			//_beginBasicButton.addEventListener(MouseEvent.MOUSE_UP, onBeginLessonHandler, false, 0, true);
		}
		
		private function onBeginLessonHandler(e:MouseEvent):void {
			trace("onBeginLessonHandler");
		}
		
		public function onControllUpdate(event:Event):void {
			trace("onControllUpdate called");
			if (_mModel.getActiveID() != getID() && _setSelected) {
				trace("onControllUpdate called");
				_setSelected = false;
				gotoAndPlay("normal");
				TweenLite.to(highlight_mc, 0.5, { alpha:0 } );
			}
			
			setSelectedHighlight();
		}
		
		public function setLessonNumber(lessonCount:int):void 
		{
			// add additional space between num and title.
			lesson_num.x = 15;
			lesson_num.width = 27;
			lesson_num.text = lessonCount.toString();
		}
		
		public function setTime(time:String):void 
		{
			if(time.length >0){
				lesson_time.text = "(" + time + ":00)";
			}else {
				lesson_time.text = "";
			}
		}
		

		private function enableHitAreaHandlers():void {
			if(!hitarea_mc.hasEventListener(MouseEvent.MOUSE_UP)){
				hitarea_mc.useHandCursor = true;
				hitarea_mc.buttonMode = true;
				hitarea_mc.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler, false, 0, true);
				hitarea_mc.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver, false, 0, true);
				hitarea_mc.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut, false, 0, true);
			}
		}
		
		private function disableHitAreaHandlers():void {
			hitarea_mc.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			//hitArea_mc.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			hitarea_mc.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			hitarea_mc.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
		}
		
		
		
		private function onMouseUpHandler(evt:MouseEvent):void {
			if (begin_btn.hitTestPoint(stage.mouseX, stage.mouseY, true)) {
				// open if begin button is hit.
				if (_mModel.getActiveID() != getID()) {
					_mController.setActiveID(getID());
				}		
			}
		}
		
		private function onMouseDownHandler(evt:MouseEvent):void {
			
		}
		
		private function onMouseRollOver(evt:MouseEvent):void {
			trace("_mModel.getActiveID() = " + _mModel.getActiveID());
			trace("getID() = " + getID());
			trace("this = " + this);
			if (_mModel.getActiveID() != getID()) {
				trace("gotoAndPlay go to rollover");
				this.gotoAndPlay("rollover");
				TweenLite.to(highlight_mc, 0.5, { alpha:1 } );
			}
		}
		
		private function onMouseRollOut(evt:MouseEvent):void {
			if (_mModel.getActiveID() != getID()) {
				trace("gotoAndPlay go to rollout");
				gotoAndPlay("rollout");
				TweenLite.to(highlight_mc, 0.5, { alpha:0 } );
			}
		}
		
		private function setWidth(numWidth:Number):void {
			
			_mWidth = numWidth;
			_mModel.setMaxWidth(_mWidth);
		}
		
		private function getWidth():Number {
			return _mWidth;
		}
		
		
		/**
		 * show the highlight
		 * set the active id in the controller
		 */
		
		private function setSelectedHighlight():void {
			trace("setSelectedHighlight");
			trace("_mModel.getActiveID() = " + _mModel.getActiveID());
			trace("getID() = " + getID());
			if (_mModel.getActiveID() == getID()) {
				_setSelected = true;
				trace("gotoAndPlay setSelected");
				gotoAndPlay("selected");
				TweenLite.to(highlight_mc, 0.5, { alpha:1 } );
			}
		}
		
		private function updateStatus():void {
			setStatus(_mSequence.getStatus());
		}
		
		private function setStatus(statusString:String):void {
			trace("statusString a = " + statusString + " sequence id = "+_mSequence.getID()+" status = "+_mSequence.getStatus());
			if(statusString != getStatus()){
				switch(statusString) {
					case CoreConstants.SEQUENCE_STATUS_NEXT:
						status_mc.gotoAndStop("incomplete");
						enableHitAreaHandlers();
						break;
					case CoreConstants.SEQUENCE_STATUS_NOT_ATTEMPTED:
						status_mc.gotoAndStop("not_started");
						if (Core.Modules.AdminDataModule.getNavigationType() == CoreConstants.NAVIGATION_MODE_OPEN) {
							enableHitAreaHandlers();
						}else {
							disableHitAreaHandlers();
						}
						break;
					case CoreConstants.SEQUENCE_STATUS_INCOMPLETE:
						status_mc.gotoAndStop("incomplete");
						enableHitAreaHandlers();
						break;
					case CoreConstants.SEQUENCE_STATUS_COMPLETE:
						status_mc.gotoAndStop("complete");
						//disableHitAreaHandlers();
						enableHitAreaHandlers();
						break;
					default:
						break;
				}
				_status = statusString;
			}
		}
		
		private function getStatus():String {
			return _status;
		}
		
		/**
		 * check the size of the text field
		 * 
		 * measure the size of the text field
		 * make sure it doesn't exceed the max width
		 * wrap the text and set the size if it does
		 */
		private function measure():void {
			OutlineView.MAX_TEXT_WIDTH;
		}
		
		/**
		 * change the size of the text field.
		 */
		private function updateLabel():void {
			trace("updateLabel called");
			
			// update the text width
			if (title_tfield.width > _mModel.getMaxWidth()) {
				title_tfield.wordWrap = true;
				title_tfield.multiline = true;
			}
			lesson_time.x = _mModel.getMaxWidth() + OFFSET_WIDTH;
			
			// update the background and lines
			var startPosition:int = _mModel.getMaxWidth() + OutlineView.OFFSET_WIDTH - OutlineView.OFFSET_STATUS_WIDTH
			
			status_mc.x = startPosition + STATUS_WIDTH;
			begin_btn.x = Math.ceil(status_mc.x +status_mc.width + OFFSET_STATUS_BEGIN_WIDTH);
			var maxWidth:Number = _mModel.getMaxWidth() + STATUS_WIDTH + OFFSET_WIDTH;
			highlight_mc.width = _mModel.getMaxWidth() + OutlineView.OFFSET_WIDTH;
			highlight_mc.height = this.height;
			
			// set the width
			hitarea_mc.width = _mModel.getMaxWidth() + OutlineView.OFFSET_WIDTH;
		}
		
	}

}