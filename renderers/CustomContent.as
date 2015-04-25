package renderers  {
	import com.invision.client.BasicRenderer;
	import com.invision.interfaces.ISceneRenderer;
    import com.invision.ui.TextContainer;
    import com.invision.ui.ImageContainer;
    import com.invision.data.XMLUtility;
    import com.invision.Core;
	import flash.media.Sound;
    
    
    public class CustomContent extends BasicRenderer implements ISceneRenderer{

        
        public function CustomContent() { }
        
        override public function startScene():void {
            super.startScene();
            var theDoc:XML = mScene.getXML();
            var theCompletionNode:XMLList = theDoc.desc.desctext;
            var completionString:String = theCompletionNode.@["completiontype"];
            // values supported are auto and custom
			trace("startScene custom");
            if (completionString == "auto") {
                trace("set visited");
                Core.Modules.updateCompletionBookmark();
                Core.getInstance().getScene().setVisited();
            }
			
			var audioAutoComplete:String = theCompletionNode.@["audiocompletiontype"];
			
			if (audioAutoComplete == "custom") {
				// prevent the scene audio file from auto completing the page.
				// var audioNode:XMLList = theDoc.audio.audiofile;
				// var sFilename:String = audioNode.@["audio"];
				//var currentSound:Sound = Core.AudioObject.getSoundObject(sFilename);
				//Core.AudioObject.updateSoundAsnyc(currentSound,true);
				mScene.setAsynchronous(true);
			}
            //if it is a custom screen set the pause button automatically to pause state.
        }
    } 
}
