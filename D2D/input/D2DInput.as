package D2D.input{
	import D2D.input.D2DKeyboard;
	import D2D.components.D2DTransform;
	import D2D.core.D2DCore;
	
	import com.genome2d.components.GComponent;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class D2DInput{
		
		
		//Mouse;
		public static var Mouse:D2DMouse = new D2DMouse();
		public static var Mouse3D:Vector3D = new Vector3D(0,0,0,0); //V3D mouse is here and just duplicates D2DMouse's position.  We need this because Genome2D's hitTestPoint only accepts a V3D
		public static var Keys:D2DKeyboard = new D2DKeyboard();
		public static var Touch:D2DTouch = new D2DTouch();
		public static var Touch3D:Vector3D = new Vector3D(0,0,0,0);
		public static var touchpoints:Number = 0;
		
		public static var helperPoint:Point = new Point();
		
		public static var initialized:Boolean = false;
		
		//public static var
		
		public static function init():void{
			if(!initialized){
				initialized = true;
				D2DCore.stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
				D2DCore.stage.addEventListener(KeyboardEvent.KEY_UP, KeyUp);
				D2DCore.stage.addEventListener(MouseEvent.MOUSE_DOWN, HandleMouseDown);
				D2DCore.stage.addEventListener(MouseEvent.MOUSE_UP, HandleMouseUp);
				
				D2DCore.stage.addEventListener(TouchEvent.TOUCH_BEGIN, HandleTouchBegin);
				D2DCore.stage.addEventListener(TouchEvent.TOUCH_END, HandleTouchEnd);
				D2DCore.stage.addEventListener(TouchEvent.TOUCH_MOVE, HandleTouchMove);
			}
			
			//D2DCore.stage.addEventListener(TouchEvent.TOUCH_TAP, HandleTap);
		}
		
		protected static function HandleTouchMove(event:TouchEvent):void{
			Touch.handleTouchMove(event);
		}		
		
		protected static function HandleTouchEnd(event:TouchEvent):void{
			Touch.handleTouchEnd(event);
		}
		
		protected static function HandleTouchBegin(event:TouchEvent):void{
			Touch.handleTouchBegin(event);
		}
		
		//Keyboard events
		protected static function KeyUp(event:KeyboardEvent):void{
			Keys.handleKeyUp(event);
		}
		
		protected static function KeyDown(event:KeyboardEvent):void{
			Keys.handleKeyDown(event);
		}			
			
			
		//Mouse events
		public static function HandleMouseUp(event:MouseEvent = null):void{
			Mouse.handleMouseUp(event);
		}
		
		public static function HandleMouseDown(event:MouseEvent = null):void{
			Mouse.handleMouseDown(event);
			
		}
		
		public static function update(deltaTime:Number):void{
			if(!initialized) init();
			Keys.update();
			Mouse.update()
			Touch.update();
			Mouse3D.x = Mouse.x;
			Mouse3D.y = Mouse.y;
			Touch3D.x = Touch.x;
			Touch3D.y = Touch.y;
		}
	}
}