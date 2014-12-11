package D2D.components {
	import D2D.core.D2DCore;
	import D2D.core.D2DNode;
	import D2D.input.D2DInput;
	
	public class D2DCamera extends D2DComponent {
		
		public static const STYLE_LOCK_ON:int = 0;
		public static const STYLE_LOCK_ON_X:int = 1; //doesn't move in the y direction;
		public static const STYLE_LOCK_ON_Y:int = 2 //doesn't move in the x direction
		public static const STYLE_DELAY_FOLLOW:int = 3; //springy like following;
		public static const STYLE_DELAY_FOLLOW_X:int = 4;
		public static const STYLE_DELAY_FOLLOW_Y:int = 5
		
		public var backgroundColor:uint = 0x000000;	
		
		private var _target:D2DNode;
		private var _style:int;
		public var followOffsetX:Number = 0
		public var followOffsetY:Number = 0
			
		private var _realX:Number = 0 //camera position (minus the stupid D2DCore.width/2 offset);
		private var _realY:Number = 0;
		
		public var afterUpdate:Vector.<Function> = new Vector.<Function>();
		
		
		public function D2DCamera(_node:D2DNode) {
			super(_node);
		}

		public function get zoom():Number{
			return this.node.transform.scaleX;
		}

		public function set zoom(value:Number):void{
			this.node.transform.scaleX = this.node.transform.scaleY = value;
		}
		
		public function follow(target:D2DNode, style:int = 0):void{
			if(target == null) throw new Error("D2DCamera::Folow() - Can not follow a null node");
			_target = target
			 _style = style
		}
		
		
		override public function dispose():void{
			super.dispose();
		}
		
		public function cameraUpdate(deltaTime:int):void{
			super.update(deltaTime);
			if(D2DInput.Keys.justReleased("MINUS")){
				zoom -= 0.1;
				trace(zoom);
			}
			if(D2DInput.Keys.justReleased("PLUS")){
				zoom += 0.1;
			}
			if(_target){
				switch(_style){
					case STYLE_LOCK_ON:
						this.node.transform.x = -_target.transform.x + D2DCore.width/2
						this.node.transform.y = -_target.transform.y + D2DCore.height/2
						break;
					case STYLE_DELAY_FOLLOW:
						var dx:Number = (-(this.node.transform.x/this.zoom - D2DCore.width/2/this.zoom)) - _target.transform.x- followOffsetX/this.zoom
						var dy:Number = (-(this.node.transform.y/this.zoom - D2DCore.height/2/this.zoom)) - _target.transform.y- followOffsetY/this.zoom
						var dt:Number = Math.min(1, deltaTime/1000);
						this.node.transform.x += dx*(1-dt)*0.5
						this.node.transform.y += dy*(1-dt)*0.5
						break;
				}
			}
			for(var i:int = 0; i <afterUpdate.length; i++){
				afterUpdate[i]();
			}
		}

	}
}