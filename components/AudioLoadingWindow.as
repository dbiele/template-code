package components 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import fl.motion.MatrixTransformer;
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class AudioLoadingWindow extends MovieClip
	{
		private var _testPoint:Point;
		public var whitecircle_sprite:Sprite;
		public var iconmask_mc:Sprite;
		
		private var _vr:Number = Math.PI / 180;
		private var _centerPoint:Point;
		
		private var _externalCenterPoint:Point;
		private var _whiteCircleMatrix:Matrix;
		private var _currentDegree:Number = 0;

		
		public function AudioLoadingWindow() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedStageHandler, false, 0, true);
		}
		
		private function onAddedStageHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedStageHandler, false, 0, true);
			_externalCenterPoint = new Point(20, 18);
			_whiteCircleMatrix = whitecircle_sprite.transform.matrix.clone();
			
			addEventListener(Event.ENTER_FRAME, rotateImages, false, 0, true);
		}
		
		private function onRemovedStageHandler(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedStageHandler);
			removeEventListener(Event.ENTER_FRAME, rotateImages);
		}
		
		private function rotateImages(e:Event):void 
		{
			_currentDegree = (_currentDegree + 10) % 360;
			var moveMatix:Matrix = rotateAroundCenter(_currentDegree);
			whitecircle_sprite.transform.matrix = moveMatix;
			iconmask_mc.transform.matrix = moveMatix;
		}
		
		private function rotateAroundCenter(degree:Number):Matrix {
			var mat:Matrix = _whiteCircleMatrix.clone();
			MatrixTransformer.rotateAroundExternalPoint(mat,_externalCenterPoint.x,_externalCenterPoint.y,degree);
			return mat;
		}
		
	}

}