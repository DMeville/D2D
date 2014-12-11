package D2D.core {
	import D2D.Stats;
	
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class D2DDebug {
		
		private static var debugText:TextField = new TextField();
		private static var subText:TextField = new TextField();
		private static var stats:Stats
		
		public static function init():void{
			
			debugText.defaultTextFormat = new TextFormat("courier", 12, 0x0);
			debugText.width = 1024;
			debugText.height = 200;
			debugText.selectable = false;
			
			D2DCore.stage.addChild(debugText);
			
			subText.defaultTextFormat = new TextFormat("courier", 12, 0x0);
			subText.width = 512;
			subText.height = 200;
			subText.x = 512;
			subText.selectable = false;			
			D2DCore.stage.addChild(subText);
			
			stats = new Stats();
			stats.x = D2DCore.width - 70;
			D2DCore.stage.addChild(stats);
			
			toggleVisible();
		}
		
		public static function appendText(_text:String):void{
			debugText.appendText(_text)
		}
		
		public static function set text(value:String):void{
			debugText.text = value;
		}
		
		public static function get text():String{
			return debugText.text;
		}
		
		public static function appendSubtext(_text:String):void{
			subText.appendText(_text)
		}
		
		public static function prependSubtext(_text:String):void{
			subText.text = _text + subText.text;
		}
		
		public static function set subtext(value:String):void{
			subText.text = value;
		}
		
		public static function get subtext():String{
			return subText.text;
		}
		
		public static function toggleVisible():void{
			debugText.visible = !debugText.visible;
			subText.visible = !subText.visible;
			stats.visible = debugText.visible;
		}
	}
}