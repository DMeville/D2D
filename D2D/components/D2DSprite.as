package D2D.components {
	import D2D.core.D2DNode;
	import D2D.core.D2DRenderer;
	import D2D.textures.D2DTexture;

	public class D2DSprite extends D2DRenderable {
		public var texture:D2DTexture;
		
		public static var _spritePool:Vector.<D2DSprite> = new Vector.<D2DSprite>();
		
		public function D2DSprite(_node:D2DNode) {
			super(_node);
		}
		
		public function init(_node:D2DNode):void{
			this.node = _node;
			texture = null;
		}
		
		public function setTexture(_texture:D2DTexture):void{
			if(!_texture) throw new Error("D2DSprite::setTexture() - Texture can not be null");
			texture = _texture
			this._texture = texture;
			if(D2DRenderer.currentRenderer == D2DRenderer.BLITTING){
				this.node.transform.pivotX = _texture.bitmapData.width/2
				this.node.transform.pivotY = _texture.bitmapData.height/2
			}
		}
		
		override public function render():void{
			if(!texture) return;
			D2DRenderer.draw(texture, this.node.transform);
		}
		
		override public function dispose():void{
			super.dispose();
			texture = null;
			returnToPool();
		}
		
		private function returnToPool():void{
			_spritePool.push(this);
		}
		public static function getFromPool(_node:D2DNode):D2DSprite {
			var s:D2DSprite;
			if(_spritePool.length >0){
				s = _spritePool.shift();
				s.init(_node);
				return s;
			} else {
				s = new D2DSprite(_node);
				return s;
			}
		}
	}
}