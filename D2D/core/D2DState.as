package D2D.core {
	import D2D.components.D2DComponent;
	
	public class D2DState extends D2DComponent {
		public function D2DState(_node:D2DNode)
		{
			super(_node);
		}
		
		public function addChild(_node:D2DNode):void{
			this.node.addChild(_node);
		}
		
		public function removeChild(_node:D2DNode):void{
			this.node.removeChild(_node);
		}
	}
}