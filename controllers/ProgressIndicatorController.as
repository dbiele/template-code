package controllers 
{
	import com.invision.client.model.ProgressIndicatorModel;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Dean Biele
	 */
	public class ProgressIndicatorController extends EventDispatcher 
	{
		
		private var mProgressIndicatorModel:ProgressIndicatorModel;
		
		public function ProgressIndicatorController(target:IEventDispatcher = null) {
			super(target);
			mProgressIndicatorModel = target as ProgressIndicatorModel;
		}
		
	}

}