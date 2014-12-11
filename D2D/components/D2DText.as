package D2D.components {
	import D2D.core.D2DNode;
	import D2D.textures.D2DTexture;
	import D2D.textures.D2DTextureAtlas;
	
	import com.genome2d.components.GComponent;
	import com.genome2d.components.renderables.GRenderable;
	import com.genome2d.core.GNode;
	
	public class D2DText extends D2DComponent {
		
		private var _text:String = ""
		private var nodes:Vector.<D2DNode>;
		
		private var fontPrefix:String;
		private var atlas:D2DTextureAtlas;
		private var width:Number = 0;
		
		public function D2DText(_node:D2DNode) {
			super(_node);
			nodes = new Vector.<D2DNode>();
		}
				
		public function get text():String{
			return _text;
		}

		public function set text(value:String):void{
			_text = value;
			invalidate();
		}
		
		public function setFont(_font:String):void{
			this.fontPrefix = _font
			if(_font.length>0)  _font = _font + "_";
			invalidate();
		}
		
		public function setTextureAtlas(_atlas:D2DTextureAtlas):void{
			this.atlas = _atlas;
			invalidate();
		}
		
		private function invalidate():void{
			if(atlas != null && _text.length>0){
				ClearCharacters();
				for(var i:int = 0; i < _text.length; i++){
					createCharacter(_text.charCodeAt(i), i);
				}	
				
				for(i = 0; i < nodes.length;i++){
					nodes[i].transform.x -= width/2
				}
			}
		}
		
		private function ClearCharacters():void{
			while(nodes.length > 0){
				nodes.pop().dispose();
			}
			width = 0;
		}
		
		private function createCharacter(charCode:Number, i:int):void{
			var _node:D2DNode = D2DNode.getFromPool("character");
			var t:D2DTexture = atlas.getTexture(String(fontPrefix+charCode))
			var sprite:D2DSprite = _node.addComponent(D2DSprite) as D2DSprite;
			sprite.setTexture(t);
			this.node.addChild(sprite.node);
			_node.transform.x = width + t.region.width/2;
			nodes.push(_node);
			width += t.region.width
		}
	}
}