package D2D.components {
	import D2D.core.D2DCore;
	import D2D.core.D2DNode;
	
	public class D2DParallax extends D2DComponent {
		
		private var offsetX:Number = 0;
		private var offsetY:Number = 0;
		
		public var parallaxX:Number = 1;
		public var parallaxY:Number = 1;
		
		public var realX:Number = 0;
		public var realY:Number = 0;
		
		public function D2DParallax(_node:D2DNode) {
			super(_node);
		}
		
		public function setParallax(_parallaxX:Number, _parallaxY:Number):void{
			parallaxX = _parallaxX;
			parallaxY = _parallaxY;
			
			realX = this.node.transform.x;
			realY = this.node.transform.y;
		}
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			
			this.node.transform.x = realX + (D2DCore.camera.node.transform.x - D2DCore.width/2)*parallaxX
			this.node.transform.y = realY + (D2DCore.camera.node.transform.y - D2DCore.height/2)*parallaxY
		
		}
	}
}