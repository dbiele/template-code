package  {
    
    public class ProgramConstants {

        
        public static function get SCENE_FADE_SECONDS():Number { return 0.3; }
        
        public static function get CENTER():Number { return -1; }
        
        public static function get PROMPT_EXPLODE_SECONDS():Number { return 0.4; }
        public static function get PROMPT_MODE_ARROW_BOTTOM():Number { return 2; }
        public static function get PROMPT_MODE_ARROW_LEFT():Number { return 3; }
        public static function get PROMPT_MODE_ARROW_RIGHT():Number { return 4; }
        public static function get PROMPT_VISIBLE():String { return "PROMPT_VISIBLE"; }
        
        public static function get FEEDBACK_EXPLODE_SECONDS():Number { return 0.4; }    
        public static function get FEEDBACK_MODE_INCORRECT():Number { return 1; }
        public static function get FEEDBACK_MODE_CORRECT():Number { return 2; }
        public static function get FEEDBACK_VISIBLE():String { return "FEEDBACK_VISIBLE"; }
        public static function get FEEDBACK_TRIES():String { return "FEEDBACK_TRIES"; }
        
        public static function get SECTION_IMAGE_DEFAULT():String { return "default"; }
        public static function get NOTEPAD_TEXT():String { return "NOTEPAD_TEXT"; }
        
        public static function get VERTICAL_SPACING_DEFAULT():Number { return 20; }
        
        public static function get PDA_FRAME_PROMPT():Number { return 1; }
        public static function get PDA_FRAME_CORRECT():Number { return 2; }    
        public static function get PDA_FRAME_INCORRECT1():Number { return 3; }
        public static function get PDA_FRAME_INCORRECT2():Number { return 4; }    
        public static function get PDA_FRAME_INCORRECT3():Number { return 5; }  
		public static function get PDA_FRAME_REVIEW():Number { return 6; }
        
        public static function get PDA_DEFAULT_TEXT_PROMPT():String { return "Choose the correct answer(s) and then continue."; }    
        public static function get PDA_DEFAULT_TEXT_CORRECT():String { return "That's correct!"; }
        public static function get PDA_DEFAULT_TEXT_INCORRECT1():String { return "That was an incorrect answer."; }    
        public static function get PDA_DEFAULT_TEXT_INCORRECT2():String { return "That was an incorrect answer."; }    
        public static function get PDA_DEFAULT_TEXT_INCORRECT3():String { return "That was an incorrect answer.\n\nThe correct answer is shown."; }    
        
        public static function get PARAMETER_RESULTS():String { return "results"; }
        public static function get PARAMETER_BOOKMARK():String { return "bookmark"; }
        
        public static function get TIME_PROGRESS_BAR_UPDATE():Number { return 0.2; }    
    }
}
