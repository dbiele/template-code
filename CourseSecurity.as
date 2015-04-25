package {
	
	import flash.system.Security;
	/**
	 * ..
	 * @author Dean Biele
	 */
	public class CourseSecurity {
		
		public function CourseSecurity():void {
			Security.allowDomain("*");
		}
		
	}
	
}