package D2D.components {
	import D2D.core.D2DNode;
	import D2D.textures.D2DTexture;

	public class D2DComponent {
		
		public var node:D2DNode
		public static var _count:int = 0;
		
		
		public function D2DComponent(_node:D2DNode) {
			node = _node;
			_count++
		}
		
		public function update(deltaTime:int):void{

		}
		
		public function dispose():void{
			node.removeComponent(this);
			node = null;
			_count--;
		}
	}
}