package D2D.components {
	import D2D.core.D2DNode;
	import D2D.input.D2DInput;
	
	public class D2DFollowMouse extends D2DComponent {
		
		public var enabled:Boolean = true;
		
		public function D2DFollowMouse(_node:D2DNode) {
			super(_node);
		}
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			
			this.node.transform.x = D2DInput.Mouse.x;
			this.node.transform.y = D2DInput.Mouse.y;
			
		}
	}
}