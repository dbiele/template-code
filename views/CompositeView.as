package views 
{
	import flash.events.Event;
	
	import com.invision.client.controllers.OutlineController;
	import com.invision.client.interfaces.IOutline;	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class CompositeView extends ComponentView {
		
		private var aChildren:Array;
		
		public function CompositeView() {
			super();
			aChildren = new Array();
		}
		
		override public function initialize(aModel:IOutline, aController:OutlineController = null):void {
			super.initialize(aModel, aController);
		}
		
		override public function add(cView:ComponentView):void {
			trace("add cView = " + cView);
			aChildren.push(cView);
		}
		
		override public function update(event:Event = null):void {
			trace("update called");
			for each(var cView:ComponentView in aChildren) {
				trace("cView called = " + cView);
				cView.update(event);
			}
		}
		
	}

}