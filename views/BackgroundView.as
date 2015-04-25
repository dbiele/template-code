package views 
{
	import com.invision.client.Course;
	import com.invision.Core;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class BackgroundView extends MovieClip 
	{
		private var _course:Course;
		
		public function BackgroundView() 
		{

		}
		
		public function initialize(course:Course):void 
		{
			_course = course;
			if (stage) {
				onInitResizeHandler();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, onInitResizeHandler, false, 0, true);
			}
		}
		
		private function onInitResizeHandler(event:Event = null):void {
			stage.addEventListener(Event.RESIZE, onResizeHandler, false, 0, true);
			onResizeHandler(null);
		}
		
		private function onResizeHandler(event:Event):void {
			trace("core = " + _course);
			trace("Core.CourseObject.getScale() = " + _course.getScale());

			var currentWidth:Number = (Course.COURSE_WIDTH * _course.getScale());
			var increment:Number = Course.COURSE_WIDTH / currentWidth;
			var offsetX:Number = (currentWidth - stage.stageWidth) / 2;
			this.x = increment * offsetX;
			this.width = stage.stageWidth * increment;
			
			
			var currentHeight:Number = (Course.COURSE_HEIGHT * _course.getScale());
			var heightIncrement:Number = Course.COURSE_HEIGHT / currentHeight;
			var offsetY:Number = (currentHeight - stage.stageHeight) / 2;
			this.y = heightIncrement * offsetY;
			this.height = stage.stageHeight * heightIncrement;
		}		
		
	}

}