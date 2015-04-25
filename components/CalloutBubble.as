package components {
	import com.greensock.easing.Bounce;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	import com.invision.Core;
	import com.invision.Audio;
	import com.invision.client.ProgramConstants;
	import com.invision.ui.Popup;

	import com.invision.interfaces.IPopup;

	public class CalloutBubble extends Popup implements IPopup {

		private var SOUND_POP:String = "media/pop.mp3";
		
		private var title_mc:MovieClip;
		private var text_mc:MovieClip;
		private var mVisible:Boolean;
		private var mDragging:Boolean;
		private var mOffset:Object;
		private var mFeedbackMode:Number;
		
		public function CalloutBubble() {
			scaleX = 0;
			scaleY = 0;
			alpha = 0;
			mVisible = false;
			mDragging = false;
			Core.getStage().addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		public function init(mode:Number, title:String, text:String):void {
			mFeedbackMode = mode;
			gotoAndStop(mFeedbackMode);
			var titleMC:TextField = title_mc.textbox;
			var contentMC:TextField = text_mc.textbox;
			titleMC.antiAliasType = "normal";
			titleMC.autoSize = TextFieldAutoSize.LEFT;
			titleMC.text = title;
			contentMC.antiAliasType = "normal";
			contentMC.autoSize = TextFieldAutoSize.LEFT;
			contentMC.htmlText = text;
		}
		
		override public function show():void {
			var aAudio:Audio = new Audio();
			aAudio.play(SOUND_POP,false);
			alpha = 1;
			mVisible = true;
			Core.setVariable(ProgramConstants.PROMPT_VISIBLE, true);
			TweenLite.to(this, ProgramConstants.PROMPT_EXPLODE_SECONDS, { scaleX:1, scaleY:1,ease:Bounce.easeOut } );
			//var xTween:Object = new Tween(this, "_xscale", Back.easeOut, 0, 100, ProgramConstants.PROMPT_EXPLODE_SECONDS, true);
			//var yTween:Object = new Tween(this, "_yscale", Back.easeOut, 0, 100, ProgramConstants.PROMPT_EXPLODE_SECONDS, true);		
		}
		
		override public function hide():void {
			mVisible = false;			
			TweenLite.to(this, ProgramConstants.PROMPT_EXPLODE_SECONDS, { scaleX:0, scaleY:0, ease:Bounce.easeIn, onComplete:onShrinkFinished } );
			//var xTween:Object = new Tween(this, "_xscale", Back.easeIn, 100, 0, ProgramConstants.PROMPT_EXPLODE_SECONDS, true);
			//var yTween:Object = new Tween(this, "_yscale", Back.easeIn, 100, 0, ProgramConstants.PROMPT_EXPLODE_SECONDS, true);							
			//yTween.onMotionFinished = Delegate.create(this, onShrinkFinished);		
		}
		
		private function onShrinkFinished():void {
			//Mouse.removeListener(this);
			Core.Popups.closeDialog(this.getID());
			Core.setVariable(ProgramConstants.PROMPT_VISIBLE, false);	
			delete this;
		}
		
		public function isVisible():Boolean { return mVisible; }
		
		private function onMouseDown(evt:MouseEvent = null):void { 
			//Mouse.removeListener(this);		
			hide(); 
		}
		
		private function onKeyDownHandler(evt:KeyboardEvent):void {
			Core.getStage().removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			hide(); 
		}
		
		private function getFeedbackMode():Number { return mFeedbackMode; }
	}
}