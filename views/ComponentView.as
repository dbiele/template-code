package views 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.errors.IllegalOperationError;
	
	import com.invision.client.controllers.OutlineController;
	import com.invision.client.interfaces.IOutline;	
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class ComponentView extends MovieClip {
		
		public static var _mModel:IOutline;
		public static var _mController:OutlineController;
		
		public function ComponentView() {

		}
		
		public function initialize(aModel:IOutline, aController:OutlineController = null):void {
			_mModel = aModel;
			_mController = aController;			
		}
		
		public function add(cView:ComponentView):void {
			throw new IllegalOperationError("add operation not supported");
		}
		
		public function remove(cView:ComponentView):void {
			throw new IllegalOperationError("remove operation not supported");
		}
		
		public function getChild(nVal:int):ComponentView {
			throw new IllegalOperationError("getchild operation not supported");
			return null;
		}
		
		public function update(event:Event = null):void { }
		
	}

}