package D2D.components {
	import D2D.core.D2DNode;
	import D2D.textures.D2DTexture;
	

	public class D2DTiledSprite extends D2DComponent{
		
		private var tiles:Vector.<D2DNode> = new Vector.<D2DNode>()
		private var _texture:D2DTexture
			
		public function D2DTiledSprite(_node:D2DNode){
			super(_node);
		}
		
		public function setTexture(texture:D2DTexture):void{
			_texture = texture;
		}
		
		public function fill():void{
			
		}
	}
}