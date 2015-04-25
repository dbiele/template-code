package renderers {
    import com.invision.data.Hashtable;
    
    import com.invision.Core;
    import com.invision.CoreConstants;
    import com.invision.data.XMLUtility;
	import flash.display.MovieClip;
    
    
    public class AssessmentReview extends MovieClip {
		/*
        private var mSections:Hashtable
        private var lSections:Hashtable
        private var mAnswerMaster:MovieClip;
        private var keys:Array
        private var maxButtonSpace:Number = 20
        private var maxButtonArea:Number = 315
        private var mcSpacer:Number
        private var MC_ANSWERMASTER:String = "lessonLink";
        private var MC_LESSONSTART:String = "Lesson ";
        private var MC_MENUWINDOW:String = "menuWindow";
        private var mAnswerOffsetX:Number
        
        
        public function AssessmentReview() { 
            mAnswerMaster = getClip(MC_ANSWERMASTER);
            mAnswerMaster._visible = false;
            mAnswerOffsetX = mAnswerMaster._x
            
            mSections = new Hashtable();
            lSections = new Hashtable();
            
            var sceneID:String = Core.Modules.getMenuSceneID();
            var mScene = Core.Modules.getScene(sceneID);
			var theDoc:XML = mScene.getXML();
            var sectionArray:Array = XMLUtility.getMatchingNodes(theDoc, "scene", "menus", "lesson");
            for (var i:Number = 0; i < sectionArray.length; i++) {
                var sectionNode:XMLNode = XMLNode(sectionArray[i]);
                var id:String = sectionNode.attributes["sequence"];
                mSections.add(id, sectionNode);
                if (Core.Modules.getSequence(id).getType() != CoreConstants.SEQUENCE_TYPE_MENU) {
                        var theSequence = Core.Modules.getSequence(id);
                        var type:String = theSequence.getType();
                        if (type != CoreConstants.SEQUENCE_TYPE_ASSESSMENT){
                            var buttonObject:Object = new Object();
                            buttonObject = {title:getTitle(id),SceneID:getLinkSceneID(id)}
                            lSections.add(id,buttonObject);
                        }
                }
            }
            keys = lSections.getKeys();
            mcSpacer = calcSpacing();
            var mDepth:Number = this.numChildren-1;
            for (var ii:Number = 0; ii < keys.length; ii++) {
                var theKey:String = keys[ii];
                var newObject:Object = lSections.getValue(theKey);
                var answerClip:MovieClip = mAnswerMaster.duplicateMovieClip("lessonLink"+(ii+1), mDepth+ii, { _x:mAnswerOffsetX, _y:calcPosition(ii), lessonName: MC_LESSONSTART+(ii+1), textName:" "+newObject["title"],lessonNum:newObject["SceneID"]});
                answerClip.l1Button.onRelease = function() {
                    // assessment review        
                    Core.CourseObject.Nav.setFinalTestReviewTarget(Core.getInstance().getScene().getID());
                    Core.getInstance().setScene(this.parent.lessonNum);
                    this.removeChild(answerClip);
                };
                answerClip.l1Button.onRollOver = function() {
                    _parent.gotoAndStop("l1Over");
                };
                answerClip.l1Button.onRollOut = function() {
                    _parent.gotoAndStop("l1Out");
                };            
            }
            var mcWindow:MovieClip = getClip(MC_MENUWINDOW);
            mcWindow.exitButton.onRelease = function(){
                trace("close window");
                if (!Core.AudioObject.isPlaying()) {
                    Core.AudioObject.pause();
                }
				this.parent.parent.removeChild(mcWindow);
                //_parent._parent.removeMovieClip();
            }
        }
        private function getTitle(buttonID:String):String {
            var sectionNode:XMLNode = XMLNode(mSections.getValue(buttonID));
            var s:String = unescape(sectionNode.attributes["lessonname"]);
            return s;
        }
        private function getLinkSceneID(buttonID:String):String {
            var sectionNode:XMLNode = XMLNode(mSections.getValue(buttonID));
            var s:String = "scene" + sectionNode.attributes["frame"];
            return s;
        }    
        private function calcSpacing():Number{
            var mcHeight:Number = mAnswerMaster._height
            var mcCurrentSpace = (maxButtonArea - (mcHeight * (keys.length)))/ keys.length - 1
            if(mcCurrentSpace > maxButtonSpace){
                mcCurrentSpace = maxButtonSpace
            }
            return mcCurrentSpace;
        }
        private function calcPosition(mcNum:Number){
            var mcHeight:Number = mAnswerMaster._height
            var startPos:Number = mAnswerMaster._y;
            return startPos+ (mcSpacer * mcNum) + (mcHeight * mcNum);
        }
        private function getClip(s:String):MovieClip {
            var mc:MovieClip = this[s];
            if (mc == null) {
                Core.log("ERROR in SceneRenderer.getClip(): '" + s + "' not found.");
            }
            return mc;
        }
		*/
    }
}
