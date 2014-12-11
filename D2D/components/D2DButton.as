package D2D.components {
	import D2D.core.D2DNode;
	import D2D.input.D2DInput;
	
	import flash.geom.Point;
	
	public class D2DButton extends D2DComponent {
		
		public var clicked:Function = null;
		public var over:Function = null;
		public var out:Function = null;
		public var down:Function = null;
		public var up:Function = null;
		private var hitbox:D2DSprite;
		private var width:Number;
		private var height:Number
		private static var helperPoint:Point = new Point();
		
		private var _over:Boolean = false;
		private var _down:Boolean = false;
		
		
		public function D2DButton(_node:D2DNode) {
			super(_node);
		}
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			if(!hitbox) return;
			
			helperPoint.x = D2DInput.Mouse.x;
			helperPoint.y = D2DInput.Mouse.y;
			
			var local:Point = this.node.transform.worldToLocal(helperPoint);
			if(local.x > -width/2
				&& local.x < width/2
				&& local.y > -height/2
				&& local.y < height/2){
				_over = true;
				if(over!= null) over(this);
				
				
				if(D2DInput.Mouse.pressed()){
					_down = true;
					if(down != null) down(this);
				} else {
					if(_down) {
						_down = false;
						if(up != null) up(this);
					}
				}
				
				if(D2DInput.Mouse.justReleased()){
					if(clicked != null) clicked(this);
				}
			} else {
				if(_over){
					_over = false;
					if(out != null) out(this);
				}
			}
		}
		
		public function setHitbox(_hitbox:D2DSprite):void{
			hitbox = _hitbox;
			width = hitbox.texture.region.width;
			height = hitbox.texture.region.height;
		}
	}
}