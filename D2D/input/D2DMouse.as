package D2D.input{
	import D2D.core.D2DCore;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class D2DMouse extends Point{
	
		private var _current:int;
		private var _last:int
		private var _lastPressed:Boolean = false;
	
		
		//Courtesy of Flixel
		public function D2DMouse(){
			super(0,0);
			
			_current = 0;
			_last = 0;
		}
		public function update():void{
			if((_last == -1) && (_current == -1))
				_current = 0;
			else if((_last == 2) && (_current == 2))
				_current = 1;
			_last = _current;
			
			this.x = D2DCore.stage.mouseX - D2DCore.width/2
			this.y = D2DCore.stage.mouseY - D2DCore.height/2
		}
		
		public function reset():void {
			_current = 0;
			_last = 0;
		}
		
		public function pressed():Boolean { 
			return _current > 0; 
		}
	
		public function justPressed():Boolean { 
			return _current == 2; 
		}
	
		public function justReleased():Boolean { 
			return _current == -1; 
		}
		
		public function handleMouseDown(FlashEvent:MouseEvent):void {
			if(_current > 0) _current = 1;
			else _current = 2;
		}
		
		public function handleMouseUp(FlashEvent:MouseEvent):void {
			if(_current > 0) _current = -1;
			else _current = 0;
		}
					
	}
}