package renderers  {
	import com.invision.assessment.CustomQuestion;
	import com.invision.client.BasicRenderer;
	import com.invision.interfaces.IInteractive;
	import com.invision.interfaces.ISceneRenderer;
    import com.invision.ui.TextContainer;
    import com.invision.ui.ImageContainer;
    import com.invision.data.XMLUtility;
    import com.invision.Core;
	import flash.events.Event;
    
    
    public class CustomContentQuiz extends BasicRenderer implements ISceneRenderer, IInteractive{

        private var mQuestion:CustomQuestion;
		private var questionSelectionType:String;
		private var mHandlersEnabled:Boolean;
		
		public static const ON_SCENE_DISABLED:String = "OnSceneDisabled";
		public static const ON_SCENE_START:String = "OnSceneStart";
		
        public function CustomContent() { }
        
        override public function startScene():void {
            super.startScene();
            mQuestion = CustomQuestion(Core.Modules.getQuestion(mScene.getID()) );
			questionSelectionType = mQuestion.getSelectionType();
			dispatchEvent(new Event(ON_SCENE_START));
		}
		
		override public function endScene():void {
            super.endScene();
		}
		
		public function repositionFlagButton(yPosition:Number):void {
			updateFlagReview(yPosition);
		}
		
		public function repositionCheckAnswerButton(posY:int) {
			repositionCheckAnswer(posY);
		}
		
		private function addHandlers() {
			mHandlersEnabled = true;
		}
		
		private function deleteHandlers() {
			mHandlersEnabled = false;
			dispatchEvent(new Event(ON_SCENE_DISABLED));
		}
		
        public function enableListeners():void { addHandlers(); }
        public function disableListeners():void { deleteHandlers(); }
        public function isListening():Boolean { return mHandlersEnabled; }
    }
}
