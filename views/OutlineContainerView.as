package views 
{
	import com.invision.client.controllers.OutlineController;
	import com.invision.client.events.OutlineEvent;
	import com.invision.client.interfaces.IOutline;	
	import com.invision.client.model.OutlineModel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class OutlineContainerView extends CompositeView 
	{
		public var background_mc:MovieClip;
		private var _outlineModel:OutlineModel;
		private var _outlineController:OutlineController;
		
		private var _setSequenceID:String;
		
		public static const STATUS_WIDTH:Number = 90;
		public static const OFFSET_WIDTH:Number = 60;
		
		public function OutlineContainerView() 
		{
			super();
		}
		
		override public function initialize(aModel:IOutline, aController:OutlineController = null):void {
			super.initialize(aModel, aController);
			_mModel.addEventListener(OutlineEvent.INITIALIZE_OUTLINE, onBuildInitialized, false, 0, true);
		}
		
		override public function update(event:Event = null):void {
			trace("outlinecontainerview updated called");
		}
		
		private function onBuildInitialized(event:Event):void {
			//updateBackground();
		}
		
		public function updateBackground():void {
			trace("outline container view updateBackground");
			var maxWidth:Number = _mModel.getMaxWidth() + OutlineView.OFFSET_WIDTH;
			background_mc.background_cover.width = maxWidth;
			background_mc.background_cover.height = this.height;
			background_mc.side_cover.height = this.height;
			trace("this.height = " + height);
		}
		
		public function setID(sequenceID:String):void {
			_setSequenceID = sequenceID;
		}
		
		public function getID():String {
			return _setSequenceID;
		}
		
	}

}