package D2D.input{
	
	import D2D.core.D2DCore;
	
	import flash.events.TouchEvent;
	import flash.geom.Point;

	public class D2DTouch extends Point{
	
		private var _current:int;
		private var _last:int
		private var touches:Array = new Array();
		private var touchPoint:Point = new Point();
		
		/*This is a mess
		The touchPoint implimentation doesn't work well with the D2DDragScroll component,
		Which is what I was trying to work with, only allowing drag with two finger scrolling.
		The problem is that whenever you put a new finger on the device, stage.mouseX/Y jumps to that NEW position.  
		Which registers as a really quick movement if the two fingers are far apart.
		
		Try the pan gesture.
		*/
		
		public function D2DTouch(){
			super(0,0);
			
			_current = 0;
			_last = 0;
		}
		
		public function handleTouchBegin(event:TouchEvent):void{
			D2DInput.touchpoints++
			if(_current > 0) _current = 1;
			else _current = 2;
			touches.push(event);	
		}
		public function handleTouchMove(event:TouchEvent):void{
			if(event.touchPointID == touches[0].touchPointID && D2DInput.touchpoints == 2){
				touchPoint.x = event.stageX;
				touchPoint.y = event.stageY;
			}
		}
		public function handleTouchEnd(event:TouchEvent):void{
			D2DInput.touchpoints--
			if(_current > 0) _current = -1;
			else _current = 0;
			
			for(var i:int = 0; i<touches.length;i++){
				if(touches[i].touchPointID == event.touchPointID){
					touches.splice(i,1);
				}
			}
			
		}
		
		public function update():void{
			if((_last == -1) && (_current == -1))
				_current = 0;
			else if((_last == 2) && (_current == 2))
				_current = 1;
			_last = _current;
			if(pressed()){
				x = touchPoint.x + (D2DCore.camera.node.transform.x - D2DCore.width/2);
				y = touchPoint.y + (D2DCore.camera.node.transform.y - D2DCore.height/2);
			}
		}
		
		
		public function reset():void {
			_current = 0;
			_last = 0;
		}
		
		
		public function pressed():Boolean { return _current > 0; }
		
		public function justPressed():Boolean { return _current == 2;}
		
		public function justReleased():Boolean { return _current == -1;}
		
		
	}
}