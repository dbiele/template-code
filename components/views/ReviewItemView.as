package components.views 
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
	public class ReviewItemView extends MovieClip 
	{
		public var title_tfield:TextField;
		public var highlight_mc:MovieClip;
		public var hitarea_mc:Sprite;
		public var lesson_num:TextField;
		
		private var _mActiveID:String;
		private var _mWidth:Number;
		private var _mSequence:ISequence;
		private var _setSelected:Boolean = false;
		private var _status:String = "";
		private var _beginBasicButton:BasicButton;
		private var _model:ReviewAssessmentView;
		
		public function ReviewItemView() 
		{
			super();
			stop();
		}
		
		public function initialize(model:ReviewAssessmentView):void {
			_model = model;
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
		}
		
		public function setTitle(aTitle:String):void {
			title_tfield.autoSize = TextFieldAutoSize.LEFT;
			title_tfield.htmlText = aTitle;
			setWidth(title_tfield.width);
		}
		
		public function onBuildInitialized(event:Event):void {
			updateLabel();
			initializeButton();
		}
		
		private function initializeButton():void 
		{
			trace("initializeButton called");
		}
		
		private function onBeginLessonHandler(e:MouseEvent):void {
			trace("onBeginLessonHandler");
		}
		
		public function setLessonNumber(lessonCount:int):void 
		{
			lesson_num.text = lessonCount.toString();
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
			hitarea_mc.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			hitarea_mc.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
		}
		
		
		
		private function onMouseUpHandler(evt:MouseEvent):void {
			// go to the scene
		}
		
		private function onMouseDownHandler(evt:MouseEvent):void {
			
		}
		
		private function onMouseRollOver(evt:MouseEvent):void {

		}
		
		private function onMouseRollOut(evt:MouseEvent):void {

		}
		
		private function setWidth(numWidth:Number):void {
			_mWidth = numWidth;
		}
		
		private function getWidth():Number {
			return _mWidth;
		}
		
		private function getStatus():String {
			return _status;
		}
		
		/**
		 * change the size of the text field.
		 */
		private function updateLabel():void {
			trace("updateLabel called");
			// update the text width
			// update the background and lines
			//highlight_mc.width = _mModel.getMaxWidth() + OutlineView.OFFSET_WIDTH;
			//highlight_mc.height = this.height;
			
			// set the width
			//hitarea_mc.width = _mModel.getMaxWidth() + OutlineView.OFFSET_WIDTH;
		}
		
	}

}