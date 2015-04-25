package renderers{
	import com.invision.client.BasicRenderer;
	import com.invision.client.components.DropTarget;
    import com.invision.client.ProgramConstants;
    import com.invision.client.components.Dragger;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
    
    import com.invision.Core;
    import com.invision.data.Hashtable;
    
    import com.invision.assessment.DragDropQuestion;
    
    import com.invision.interfaces.ISceneRenderer;
    import com.invision.interfaces.IInteractive;
	import flash.display.MovieClip;
    
    
    public class DragDrop extends BasicRenderer implements ISceneRenderer, IInteractive {

        
        private var MC_DROPTARGET:String = "droptarget_mc";
        
        private var mTargetMaster:MovieClip;
        
        private var mTargets:Hashtable;
        private var mDraggers:Hashtable;
        
        private var mQuestion:DragDropQuestion;
        private var mListening:Boolean;
        
        public function DragDrop() { }
        
        override public function startScene():void {
            super.startScene();
            mQuestion = DragDropQuestion( Core.Modules.getQuestion(mScene.getID()) );
            addQuestionText();
			initializePositionDragger()
            addDropTargets();
            addDraggers();
            // previous answers should only be prepopulated in a final assessment.
            if (Core.Modules.AssessmentModule.isInProgress()) {
                getSavedDraggers();
            } else {
                mQuestion.reset();
            }
            enableListeners();
        }
		
		private function initializePositionDragger():void 
		{
			var currentPosition:Number = content_mc.question_mc.y + content_mc.question_mc.textbox.height + 60;
			content_mc.drag1_mc.y = currentPosition;
		}
        
        public function addQuestionText() {
            content_mc.question_mc.textbox.multiline = true;
            content_mc.question_mc.textbox.wordWrap = true;
            content_mc.question_mc.textbox.htmlText = mQuestion.getPrompt();
			content_mc.question_mc.textbox.autoSize = TextFieldAutoSize.LEFT;
			
			var currentPosition:Number = content_mc.question_mc.y + content_mc.question_mc.textbox.height + 20;
			updateFlagReview(currentPosition);
			repositionCheckAnswer(currentPosition);
        }
        
        public function addDropTargets() {
            mTargetMaster = getClip("droptarget_mc");
            mTargetMaster.visible = false;
            var yPosition:Number = mTargetMaster.y;
            // get the target descriptors from the xml
            mTargets = new Hashtable();        
            var targetIDs:Array = mQuestion.getTargets();
            for (var i:Number = 0; i < targetIDs.length; i++) {
                var id:String = targetIDs[i];
				//mTargetMaster, id, mQuestion.getTargetHTML(id), yPosition
                var dropTarget:DropTarget = new DropTarget(mTargetMaster, id, mQuestion.getTargetHTML(id), yPosition);
                yPosition += dropTarget.getMC().height + ProgramConstants.VERTICAL_SPACING_DEFAULT;
                mTargets.add(id, dropTarget);
            }
        }
         
        public function addDraggers() {
            var masters:Array = new Array();
            for (var i:Number = 0; i < DragDropQuestion.MAX_DRAGGERS; i++) {
                var index:Number = i + 1;
                var mc:MovieClip = getClip("drag" + index + "_mc");
				if(mc !=null){
					mc.visible = false;
					masters.push(mc);
				}
            }
            var yPosition:Number = masters[0].y;
            mDraggers = new Hashtable();
            // get the dragger descriptors from the xml
            var draggerIDs:Array = randomize(mQuestion.getDraggers());
            for (var ii:Number = 0; ii < draggerIDs.length && ii < DragDropQuestion.MAX_DRAGGERS; ii++) {
                var mcMaster:MovieClip = masters[ii];
                var id:String = draggerIDs[ii];
                var theDragger:Dragger = new Dragger(mcMaster, id, mQuestion.getDraggerHTML(id), yPosition);
                yPosition += theDragger.getMC().height + ProgramConstants.VERTICAL_SPACING_DEFAULT;
				theDragger.addEventListener("onDraggerDrop", onDraggerDrop);
                mDraggers.add(id, theDragger);
            }
        }
        
        private function getSavedDraggers(){
            var draggerIDs:Array = mQuestion.getDraggers();
            for (var i:Number = 0; i < draggerIDs.length && i < DragDropQuestion.MAX_DRAGGERS; i++) {
                var id:String = draggerIDs[i];
                var savedDraggerID:String = mQuestion.getDraggerLocation(id)
                if(savedDraggerID !=  DragDropQuestion.DRAGGER_NOT_PLACED){
                    //  If a saved dragger id is found, reposition the dragger.
                    var theDragger:Dragger = mDraggers.getValue(id) as Dragger;
                    var theTempTarget:DropTarget = mTargets.getValue(savedDraggerID) as DropTarget;
                    theTempTarget.addDragger(theDragger);
                    mQuestion.setDraggerLocation(theDragger.getID(), savedDraggerID);    
                }
            }
            redraw();
        }    
        
        private function onDraggerDrop(evt:Event) {
            Core.inspect(evt);
            var theDragger:Dragger = evt.target as Dragger;
            var theTarget:DropTarget = getDropTarget(theDragger);
            var previousTargetID:String = mQuestion.getDraggerLocation(theDragger.getID());
            if (theTarget != null) {
                // where was the dragger marked as being before it was picked up?
                switch(previousTargetID) {
                    case DragDropQuestion.DRAGGER_NOT_PLACED:
                        // the dragger was not previously placed in a drop target.  
                        // - if the drop target has only one drop trough and it's not empty, we need to:
                        //         * add one.
                        //        * update the y position of everything below that drop trough in the scene.
                        //        * lock the dragger in place.
                        // - update our results so that the dragger is shown to be in its current location.
                        theDragger.setStyle("placed");
						theTarget.addDragger(theDragger);                    
                        mQuestion.setDraggerLocation(theDragger.getID(), theTarget.getID());                    
                        break;
                    case theTarget.getID():
                        // the dragger was already placed in this drop target. just lock it back where it was when it was picked up.
                        // nothing else needs to be changed.
						theDragger.setStyle("placed");
                        theTarget.relockDragger(theDragger);
                        break;
                    default:
                        // the dragger was in a different drop target when it was picked up.  here's what we do:
                        // - if the original drop target has more than one 1 drop trough showing, we need to:
                        //        * delete one.
                        //        * update the y position of everything below that drop trough in the scene.
                        //        * update the locked positions of any draggers that remain in that drop trough.
                        // - proceed exactly as if the dragger was not placed in a drop target.
                        var thePreviousTarget:DropTarget = mTargets.getValue(previousTargetID) as DropTarget;
                        thePreviousTarget.removeDragger(theDragger);
						theDragger.setStyle("placed");
                        theTarget.addDragger(theDragger);                    
                        mQuestion.setDraggerLocation(theDragger.getID(), theTarget.getID());                                        
                }
            } else {
                // if the dragger wasn't dragged to a valid drop target, snap it back to its original position and mark it as unplaced.
                if (previousTargetID != DragDropQuestion.DRAGGER_NOT_PLACED) {
                    // if the dragger was dragged OUT of a valid drop target, update that target.
					theDragger.setStyle("default");
                    var thePreviousDropTarget:DropTarget = mTargets.getValue(previousTargetID) as DropTarget;
                    thePreviousDropTarget.removeDragger(theDragger);
                }
                theDragger.resetPosition();
                mQuestion.setDraggerLocation(theDragger.getID(), DragDropQuestion.DRAGGER_NOT_PLACED);
            }
            redraw();
        }
        
        private function getDropTarget(theDragger:Dragger):DropTarget {
            var left:Number = theDragger.getMC().x;
            var top:Number = theDragger.getMC().y;
            var right:Number = theDragger.getMC().x + theDragger.getMC().width;
            var bottom:Number = theDragger.getMC().y + theDragger.getMC().height;
            var keys:Array = mTargets.getKeys();
			var theTarget:DropTarget;
			var selectedTarget:DropTarget
            for (var i:Number = 0; i < keys.length; i++) {
                var id:String = keys[i];
                theTarget = mTargets.getValue(id) as DropTarget;            
                // is the dragger "touching" this drop area at any of its four corners?
                if (theTarget.getMC().hitTestPoint(left, top, true) ||
                    theTarget.getMC().hitTestPoint(left, bottom, true) ||
                    theTarget.getMC().hitTestPoint(right, top, true) ||
                    theTarget.getMC().hitTestPoint(right, bottom, true)) {
					// stop and use thetarget as return value.
					selectedTarget = theTarget;
                    break;
                }
            }
			return selectedTarget;
        }
        
        private function redraw() {
            var keys:Array = mTargets.getKeys();
            var yPosition:Number = mTargetMaster.y;
            for (var i:Number = 0; i < keys.length; i++) {
                var theKey:String = keys[i];
                var theTarget:DropTarget = mTargets.getValue(theKey) as DropTarget;
                theTarget.getMC().y = yPosition;
                yPosition += theTarget.getMC().height + ProgramConstants.VERTICAL_SPACING_DEFAULT;
                theTarget.redraw();
            }
        }
        
        override public function endScene():void {
            super.endScene();
            reset();
        }        
        
        override public function reset():void {
            super.reset();
            //----------------------------
            var keys:Array = mTargets.getKeys();
            for (var i:Number = 0; i < keys.length; i++) {
                var theKey:String = keys[i];
                var theTarget:DropTarget = mTargets.getValue(theKey) as DropTarget;
				theTarget.getMC().parent.removeChild(theTarget.getMC());
            }
            mTargets = null;
            //----------------------------
            var keysDragger:Array = mDraggers.getKeys();
            for (var ii:Number = 0; ii < keysDragger.length; ii++) {
                var theDraggerKey:String = keysDragger[ii];
                var theDragger:Dragger = mDraggers.getValue(theDraggerKey) as Dragger;
				theDragger.getMC().parent.removeChild(theDragger.getMC());
            }
            mDraggers = null;          
        }
        
        public function enableListeners():void { 
            // get the dragger descriptors from the xml
            var draggerIDs:Array = mQuestion.getDraggers();
            for (var i:Number = 0; i < draggerIDs.length && i < DragDropQuestion.MAX_DRAGGERS; i++) {
                var id:String = draggerIDs[i];
                var theDragger:Dragger = mDraggers.getValue(id) as Dragger;
                theDragger.addHandlers();
            }    
            mListening = true;
        }
        
        public function disableListeners():void {
            // get the dragger descriptors from the xml
            var draggerIDs:Array = mQuestion.getDraggers();
            for (var i:Number = 0; i < draggerIDs.length && i < DragDropQuestion.MAX_DRAGGERS; i++) {
                var id:String = draggerIDs[i];
                var theDragger:Dragger = mDraggers.getValue(id) as Dragger;
                theDragger.deleteHandlers();
            }                
            mListening = false;
        }
        
        public function showHints():void {

            // will show highlight with <hint hinttype="highlight" />
        }
        
        public function showCorrectAnswer() {
            var draggerKeys:Array = mDraggers.getKeys();
            for (var i:Number = 0; i < draggerKeys.length; i++) {
                var draggerID:String = draggerKeys[i];
                var theDragger:Dragger = mDraggers.getValue(draggerID) as Dragger;
                var oldTargetID:String = mQuestion.getDraggerLocation(draggerID);
                if (mQuestion.getDraggerCorrectLocation(draggerID) != "C_DRAGGER_NO_TARGET") {
                    if (oldTargetID != DragDropQuestion.DRAGGER_NOT_PLACED) {
                        var oldTarget:DropTarget = mTargets.getValue(oldTargetID) as DropTarget;
                        oldTarget.removeDragger(theDragger);
                    }
                    var newTargetID:String = mQuestion.getDraggerCorrectLocation(draggerID);
                    var newTarget:DropTarget = mTargets.getValue(newTargetID) as DropTarget;
                    newTarget.addDragger(theDragger);
                    mQuestion.setDraggerLocation(draggerID, newTargetID);
                }else {
                    var oldDropTarget:DropTarget = mTargets.getValue(oldTargetID) as DropTarget;
                    oldDropTarget.removeDragger(theDragger);
                }
            }
            redraw();
        }
        
        public function isListening():Boolean { return mListening; }
    }
}
