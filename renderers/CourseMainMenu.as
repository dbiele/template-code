package renderers {
	import com.invision.client.BasicRenderer;
    import com.invision.interfaces.ISequence;
    import flash.display.MovieClip;
    
    import com.invision.client.ProgramConstants;
    
    import flash.filters.DropShadowFilter;
    
    import com.invision.Core;
    import com.invision.CoreConstants;
    import com.invision.Scene;
    import com.invision.client.components.NavButton;
    import com.invision.client.components.CourseMenuButton;
    import com.invision.ui.PopupManager;
    import com.invision.interfaces.IPopup;
    
    import com.invision.data.Hashtable;
    import com.invision.data.XMLUtility;
    
    import flash.external.*;
    
    // XML code for just video
    // <video z-index="4" url="media/video1.flv" y="150" x="150" id="video2" frame="none" onstart="auto" />
    // XML code for video, caption and image placeholder
    // <video z-index="3" url="media/video1.flv" y="50" x="50" id="video1" frame="none" caption="In this lesson, you can learn more about SalesMaker." cy="50" cx="50" ctype="bottom" onstart="pause" imageid="image1"/>
    
    
    public class CourseMainMenu extends BasicRenderer implements ISceneRenderer{

        //-------------VERSION
        private var MAX_LESSONS_WITHOUT_ANIMATION:Number = 6;
        
        private var mSections:Hashtable;
        private var mButtons:Array;
        
        private var mActiveButtonID:String = CoreConstants.UNDEFINED;
        private var mDefaultButtonID:String = CoreConstants.UNDEFINED;
        
        private var mcContainer:MovieClip; 
        private var mActiveItem:CourseMenuButton;
        
        private var totalLessons:Number;
        
        private var activeButton:CourseMenuButton
        private var mItems:Array;
        private var mLessons:Hashtable
        
        private var ordinal:Number = 0;
        
        public function startScene() {
            super.startScene();
            trace("Course Main menu startscene");
            mcContainer = content_mc;
            mLessons = new Hashtable();
            mLessons.add("lesson1", { _x:mcContainer["exit"+1+"_mc"]._x, _y:mcContainer["exit"+1+"_mc"]._y, mMC:"mmenu_exit1_wrapper" } );        
            mLessons.add("lesson2", { _x:mcContainer["exit"+2+"_mc"]._x, _y:mcContainer["exit"+2+"_mc"]._y, mMC:"mmenu_exit2_wrapper" } );
            mLessons.add("lesson3", { _x:mcContainer["exit"+3+"_mc"]._x, _y:mcContainer["exit"+3+"_mc"]._y, mMC:"mmenu_exit3_wrapper" } );
            mLessons.add("lesson4", { _x:mcContainer["exit"+4+"_mc"]._x, _y:mcContainer["exit"+4+"_mc"]._y, mMC:"mmenu_exit4_wrapper" } );        
            mLessons.add("lesson5", { _x:mcContainer["exit"+5+"_mc"]._x, _y:mcContainer["exit"+5+"_mc"]._y, mMC:"mmenu_exit5_wrapper" } );    
            mLessons.add("lesson6", { _x:mcContainer["exit"+6+"_mc"]._x, _y:mcContainer["exit"+6+"_mc"]._y, mMC:"mmenu_exit6_wrapper" } );    
            mLessons.add("lesson7", { _x:mcContainer["exit"+7+"_mc"]._x, _y:mcContainer["exit"+7+"_mc"]._y, mMC:"mmenu_exit7_wrapper" } );    
            mLessons.add("lesson8", { _x:mcContainer["exit" + 8 + "_mc"]._x, _y:mcContainer["exit" + 8 + "_mc"]._y, mMC:"mmenu_exit8_wrapper" } );        
            mLessons.add("lesson9", { _x:mcContainer["exit" + 9 + "_mc"]._x, _y:mcContainer["exit" + 9 + "_mc"]._y, mMC:"mmenu_exit9_wrapper" } );    
            mLessons.add("lesson10", { _x:mcContainer["exit"+10+"_mc"]._x, _y:mcContainer["exit"+10+"_mc"]._y, mMC:"mmenu_exit10_wrapper" } );    
            updateAfterEvent();
            mItems = new Array();
            addInstructions();
            addSections();
        }
        
        private function addInstructions() {
            var theDoc:XML = mScene.getXML();
            var theTextNode:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "menus", "course");
            var iString:String = theTextNode.attributes["coursedescription"];
            //mcContainer.instruction_mc.textbox.text = iString;
            var initObj:Object = new Object();
            initObj._x = 690;
            initObj._y = 50;
            var mInstruction:MovieClip = mcContainer.attachMovie("instructbubble_wrapper", "instruction", 1, initObj);
            //var id:String = Core.Popups.showDialog("instructbubble", PopupManager.MODE_ALWAYS_ON_TOP, initObj);
            //var mPop:IPopup = Core.Popups.getPopup(id);
            mInstruction.content_mc.textbox.htmlText = iString;
        }
        
        private function addSections() {
            mButtons = new Array();
            mSections = new Hashtable();
            // get the number of sections in the lesson
            var sectionArray:Array = XMLUtility.getMatchingNodes(mScene.getXML(), "scene", "coursemenus", "lesson");
            totalLessons = sectionArray.length
            trace("totalLessons = "+totalLessons);
            for (var i:Number = 0; i < totalLessons; i++) {
                var sectionNum:Number = i;
                var sectionNode:XMLNode = XMLNode(sectionArray[i]);
                // get the sequenceid from the frame number
    
                var currentFrame:String = "scene" + sectionNode.attributes["frame"];
                var theScene:Scene = Core.Module.getScene(currentFrame);
                
                var id:String = theScene.getSequenceID();
                mSections.add(id, sectionNode);
                addButton(id);
            }
            // get the current sequence and sub sequence
            
            //------------
            //var sceneID:String = Core.getInstance().getScene().getID();
            //nLesson = Core.Module.getSequenceList().getIndex(theSequence.getID());
            var sequenceID:String = Core.getInstance().getScene().getSequenceID();        
            var currentSequence:ISequence = Core.Module.getSequence(sequenceID);
            var sequenceID:String = currentSequence.getSequenceList().getFirst();
            //---------------------
            while (sequenceID != CoreConstants.UNDEFINED) {
                trace("entering sequence id");
                if(currentSequence.getSequence(sequenceID).getType != CoreConstants.SEQUENCE_TYPE_MENU){
                    
                    if (mDefaultButtonID == CoreConstants.UNDEFINED) {
                        mActiveButtonID = sequenceID;
                        mDefaultButtonID = sequenceID;
                    }                
                }
                sequenceID = currentSequence.getSequenceList().getNext(sequenceID);
            }
            
            // get last active lesson
            var nLastActiveLesson:Number = getLastActiveLesson();
            if(nLastActiveLesson == totalLessons || nLastActiveLesson == 0) {
                nLastActiveLesson = 1;
                mActiveButtonID = Core.Module.getSequenceList().getItem(nLastActiveLesson);
            } else {
                mActiveButtonID = Core.Module.getSequenceList().getItem(nLastActiveLesson + 1);
            }
            // 
        }
    
        public static function getLastActiveLesson(){
            var bookMarkString:String = Core.Module.getBookmark()
            var a:Array = bookMarkString.split(CoreConstants.BOOKMARK_SEPARATOR1);
            var aa:Array = a[0].split(CoreConstants.BOOKMARK_SEPARATOR2);
            var nLesson:Number = parseInt(aa[0]);
            return nLesson;
        }    
        
        private function addButton(sequenceID:String) {
            
            // find the status of is sequence - complete, incomplete or next?
            var theSequence:ISequence = Core.Module.getSequence(sequenceID);
            var type:String = theSequence.getType();
            var status:String = theSequence.getStatus();
            
            if(Core.Module.AdminData.getMenuNavigationType() == CoreConstants.MENUNAVIGATION_MODE_NOLESSON){
                if (type == CoreConstants.SEQUENCE_TYPE_ASSESSMENT && status == CoreConstants.SEQUENCE_STATUS_INCOMPLETE) {
                    status = CoreConstants.SEQUENCE_STATUS_NEXT;
                }
            }
            
            /*
            // the test should never be displayed as complete, even if it's been marked complete.
            if (type == CoreConstants.SEQUENCE_TYPE_ASSESSMENT && status == CoreConstants.SEQUENCE_STATUS_COMPLETE) {
                status = CoreConstants.SEQUENCE_STATUS_NEXT;
            }
            if (mButtons.length == 0 && status == CoreConstants.SEQUENCE_STATUS_INCOMPLETE) {
                //theSequence.setStatus(CoreConstants.SEQUENCE_STATUS_NEXT);
                status = theSequence.getStatus();
            }
            
            // HACK to enable debugging
            trace("Core.getInstance().isDebugEnabled() = " + Core.getInstance().isDebugEnabled());
            if(Core.getInstance().isDebugEnabled()){
                //status = CoreConstants.SEQUENCE_STATUS_COMPLETE;
                status = CoreConstants.SEQUENCE_STATUS_NEXT;
            }
            */
            
            ordinal++
            // draw it
            trace("addd buttton to layer = " + mcContainer);
            
            var mcObject:Object = mLessons.getValue("lesson" + getID(sequenceID));
            trace("------------------------------");
            trace("get id = " + getID(sequenceID));
            trace("mmc = "+mcObject.mMC);
            trace("x = "+mcObject._x);
            trace("y = " + mcObject._y);
            trace("ordinal = " + ordinal);
            trace("status = " + status);
            trace("type = " + type);
            trace("title = " + getTitle(sequenceID));
            trace("link = " + getLinkSceneID(sequenceID));
            trace("------------------------------");
            var bActive:CourseMenuButton = new CourseMenuButton(theSequence, mcContainer, mcObject.mMC, ordinal, mcObject._x, mcObject._y, status, ordinal, getType(sequenceID), getTitle(sequenceID), getLinkSceneID(sequenceID));
            bActive.addEventListener("onMainItemSelected", this);    
            mItems.push(bActive);
            mButtons.push({id:mcContainer[sequenceID]});        
        }
        
        public function setActiveButtonID(s:String) { 
            mActiveButtonID = (s != CoreConstants.UNDEFINED) ? s : mDefaultButtonID; 
            for (var i:Number = 0; i < mButtons.length; i++) {
                var theButton:Object = mButtons[i];
                var mc:MovieClip = theButton.id;
                if (mc._name != s) {
                    mc.reset();
                }
            }
        }
        
        private function onMainItemSelected(evt:Object) {
            mActiveItem = evt.target;
            trace("mActiveItem = "+mActiveItem);
            mActiveItem.activate();
            // calculate the scene based upon the frame number
            // jump to the scene
            Core.CourseObject.Nav.resetPauseButton();
            Core.getInstance().setScene(mActiveItem.getLinkID());
        }
        
        private function update():void{

            for (var i:Number = 0; i < mItems.length; i++) {
                
                var thisItem:CourseMenuButton = mItems[i];
                if (thisItem.getIndex() == mActiveItem.getIndex()) {
                    if (!thisItem.isActivated()) {
                        thisItem.activate();
                    }
                } else if (thisItem.isEnabled()) {
                    thisItem.deactivate();
                }
            }            
        }
        
        public function getActiveButtonID():String { return mActiveButtonID; }
        
        public function getID(buttonID:String):String {
            var sectionNode:XMLNode = XMLNode(mSections.getValue(buttonID));
            var s:String = unescape(sectionNode.attributes["id"]);
            return s;        
        }
        
        public function getTitle(buttonID:String):String {
            var sectionNode:XMLNode = XMLNode(mSections.getValue(buttonID));
            var s:String = unescape(sectionNode.attributes["lessonname"]);
            return s;
        }
        
        public function getType(buttonID:String):String {
            var sectionNode:XMLNode = XMLNode(mSections.getValue(buttonID));
            var s:String = unescape(sectionNode.attributes["type"]);
            return s;
        }    
        
        public function getLinkSceneID(buttonID:String):String {
            var sectionNode:XMLNode = XMLNode(mSections.getValue(buttonID));
            var s:String = "scene" + sectionNode.attributes["frame"];
            return s;
        }
        
        public function getStatus(buttonID:String):String {
            return Core.Module.getSequence(buttonID).getStatus();        
        }
        
    }
}
