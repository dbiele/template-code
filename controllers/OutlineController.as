package controllers 
{
	import com.invision.client.events.OutlineEvent;
	import com.invision.client.interfaces.IOutline;
	import com.invision.client.controllers.OutlineController;
	import com.invision.client.views.CompositeView;
	import com.invision.client.views.OutlineContainerView;
	import com.invision.Core;
	import com.invision.interfaces.ISequence;
	import com.invision.Scene;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class OutlineController extends EventDispatcher {
		
		private var _openItem:CompositeView;
		private var _dropDown:Boolean;
		private var _isOpen:Boolean;
		private var _mModel:IOutline;
		
		private var containerArray:Dictionary = new Dictionary();
		
		public function OutlineController(aModel:IOutline) {
			_mModel = aModel;
			Core.getInstance().addEventListener(Core.ON_SCENE_START, onSceneStartHandler, false, 0, true);
			Core.getInstance().addEventListener(Scene.ON_SCENE_COMPLETED, onSceneCompleted, false, 0, true);
		}
		
		
		private function onSceneStartHandler(event:Event):void {
			checkStatus();
		}
		
		private function onSceneCompleted(event:Event):void {
			checkStatus();
		}
		
		private function checkStatus():void {
			trace("id = " + Core.getInstance().getScene().getSequenceID());
			trace("id = " + Core.getInstance().getScene().getSubSequenceID());
			trace("onSceneStartHandler called");			
			var activeID:String;
			if (Core.getInstance().getScene().getSubSequenceID() != "undefined") {
				activeID = Core.getInstance().getScene().getSubSequenceID();
			}else {
				activeID = Core.getInstance().getScene().getSequenceID();
			}
			trace("activeID = " + activeID);
			_mModel.setActiveID(activeID);
			dispatchEvent(new Event(OutlineEvent.UPDATE));			
		}
		/**
		 * sets the active sequence
		 * move the play head to the now active scene
		 * @param	activeID
		 */
		public function setActiveID(activeID:String):void {
			trace("activeID = " + activeID);
			//trace("OutlineController activeID= " + Core.Modules.getSequence());
			_mModel.setActiveID(activeID);
			dispatchEvent(new Event(OutlineEvent.UPDATE));
			var seq:ISequence = containerArray[activeID].sequence;
			if (_mModel.getReviewMode()) {
				Core.getInstance().reviewLesson(seq.getID());
			}else{
				Core.getInstance().setScene(seq.getFirst());
			}
			if (_mModel.getAutoClose()) {
				_mModel.setAutoClose(false);
				Core.CourseObject.Nav.closeMenuOutline();
			}
		}
		

		public function set openButton(value:CompositeView):void{
			if (_openItem === value) return;
			removeOpenHandlers();
			_openItem = value;
			addOpenHandlers();
		}
		
		public function addContainerItem(containerView:OutlineContainerView, itemID:String, aSequence:ISequence):void {
			trace("itemID = " + itemID);
			containerArray[itemID] = { "type":1, "view":containerView, "sequence":aSequence };
		}
		
		public function addContainerSubItem(containerView:OutlineContainerView, subitemID:String, aSequence:ISequence) {
			containerArray[subitemID] = {"type":2, "view":containerView, "sequence":aSequence };
		}
		
		public function updateContainer(itemID:String):void {
			trace("updateContainer called");
			if (itemID != null) {
				var containerObject:Object =  containerArray[itemID];
				trace("container objects");
				trace(containerObject.type);
				trace(containerObject.view);
				var currentOutline:OutlineContainerView = containerObject.view as OutlineContainerView;
				currentOutline.updateBackground();
			}
		}
		
		/**
		 *  gets the open item
		 */
		public function get openButton():CompositeView{
			return _openItem;
		}		
		
		private function addOpenHandlers():void {
			
		}
		
		private function removeOpenHandlers():void {
			
		}
		
		private function addCloseHandlers():void {
			
		}
		
		private function removeCloseHandlers():void {
			
		}
		
		
		private function openDropDown():void {
			
		}
		
		private function closeDropDown():void {
			
		}
		
		private function controller_MouseDownHandler():void {
			// move if not the target
		}
		
	}

}