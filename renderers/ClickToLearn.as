package renderers {
	import com.invision.client.BasicRenderer;
    import com.invision.Core;
    import com.invision.CoreConstants;
	import com.invision.interfaces.ISceneRenderer;
    import com.invision.ui.Image;
    import com.invision.ui.TextContainer;
    import com.invision.ui.ImageContainer;
    import com.invision.ui.Shape;
    import com.invision.data.XMLUtility;
	import flash.events.Event;
    
    import com.invision.data.Hashtable;
    
    
    public class ClickToLearn extends BasicRenderer implements ISceneRenderer {

        
        private var mAreas:Hashtable;
        private var disabled:Boolean = false;
        
        private var startTrigger:Number
        private var startTriggerTransition:Number
        private var stopTrigger:Number
        private var stopTriggerTransition:Number
        private var shapes:Hashtable;
        private var exploredShapes:Hashtable;
        
        private var mShapeActivation:Hashtable;
        
        public function ClickToLearn() { }
        
        override public function startScene():void {
            super.startScene();
            //---------------------
            mAreas = new Hashtable();
            exploredShapes = new Hashtable;
			var prop:XML;
			var sceneXML:XML = mScene.getXML();
			var resultsXML:XMLList = sceneXML.highlights.highlight;
			for each(prop in resultsXML) {
				var targetNode:XML = prop;
				var areaTitle:String = targetNode.@["title"];
				var id:String = targetNode.@["id"];
				mAreas.add(id, { explored:false, title:areaTitle } );
			}
			
			var desctextXML:XMLList = sceneXML.desc.desctext;
			for each(prop in desctextXML) {
				var targetDescNode:XML = prop;
				var theText:String = targetDescNode.@["instructiontext"];
			}
			trace("instruction text = " + theText);
			var bulletNode:XML = new XML();
			bulletNode.@["id"] = "bullet1";
            bulletNode.@["time"] = "0";
            bulletNode.@["textformat"] = "";
            bulletNode.@["marker"] = "false";
			bulletNode.appendChild(theText);
			mTextContainer.addBullet(bulletNode, false);
			/*
            //---------------------
            var theTextNode:XMLNode = XMLUtility.getMatchingNode(theDoc, "scene", "desc", "desctext");
            var theText = theTextNode.attributes["instructiontext"];
            // SceneRenderer's addBullet() function expects  text information in a different format, so we have to translate it here.
            var bulletNode:XMLNode = theDoc.createElement("bullet");
            bulletNode.attributes["id"] = "bullet1";
            bulletNode.attributes["time"] = "0";
            bulletNode.attributes["textformat"] = "";
            bulletNode.attributes["marker"] = "false";
            var textNode:XMLNode = theDoc.createTextNode(theText);
            bulletNode.appendChild(textNode);
            mTextContainer.addBullet(bulletNode);
			*/
            addEventListeners();
        }
        
        private function addEventListeners() {
            shapes = mImageContainer.getShapes();
            var keys:Array = mAreas.getKeys();
            mShapeActivation = new Hashtable();
            for (var i:Number = 0; i < keys.length; i++) {
                var theKey:String = keys[i];
				trace("theKey = " + theKey);
                var theShape:Shape = shapes.getValue(theKey) as Shape;
				trace("theShape = " + theShape);
                theShape.addEventListener("onShapeRelease", onShapeRelease, false, 0, true);
                theShape.addEventListener("onShapeRollOver", onShapeRollOver, false, 0, true);
                theShape.addEventListener("onShapeRollOut", onShapeRollOut, false, 0, true);
                theShape.addEventListener("onShapePress", onShapePress, false, 0, true);
                // mark this image as not being activated as yet
				trace("add the key = " + theKey);
                mShapeActivation.add(theKey, false);
            }
        }
        
        public function deactivateShape(id:String) {
            mShapeActivation.add(id, false);
        }
        
        public function closeCallouts() {
            var shapeArray:Array = mShapeActivation.getKeys();
            var shapeLength:Number = shapeArray.length;
            for (var i:Number = 0; i < shapeLength; i++) {
                if (mShapeActivation.getValue(shapeArray[i]) == true) {
                    
                    var theKey:String = shapeArray[i];
                    var theShape:Shape = shapes.getValue(theKey) as Shape;
                    var popStringID:String = getShapePopUp(theShape.getID());
					trace("popStringID = " + popStringID);
                    Core.Popups.getPopup(popStringID).close();
                    mShapeActivation.add(theKey, false);
                }
            }
        }
        
        public function onShapeRelease(evt:Event) {
			var currentShape:Shape = evt.currentTarget as Shape;
			var currentID:String = currentShape.getID();
			trace("id = " + currentID);
			trace("onShapeRelease");
            // if this shape is not already marked as activated, show the callout
			trace("mShapeActivation = " + mShapeActivation);
            var shapeActive:Boolean = mShapeActivation.getValue(currentID);
            exploredShapes.add(currentID, true);
            closeCallouts();
            checkCompletionStatus();
			trace("onShapeRelease 1");
            if (!shapeActive) {
                // mark this shape as activated.  if the callout window is closed, it will call the deactivateShape() method to 
                // reverse the marking so that the callout window can be shown again.
                mShapeActivation.add(currentID, true);            
                super.onShapeActivate(evt);
            }
        }    
        
        private function checkCompletionStatus() {
            if (exploredShapes.getCount() == mAreas.getCount()) {
                trace("all area selected");
                Core.Modules.updateCompletionBookmark();
                Core.getInstance().getScene().setVisited();            
            }
        }
        
        private function onShapeRollOver(evt:Object){
        }
        
        private function onShapeRollOut(evt:Object){
        }
        
        public function onShapePress(evt:Object){
        }
	}
}
