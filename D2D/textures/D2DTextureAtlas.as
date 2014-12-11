package D2D.textures {
	import D2D.core.D2DCore;
	import D2D.core.D2DRenderer;
	
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.GTextureBase;
	import com.genome2d.textures.factories.GTextureAtlasFactory;
	
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	use namespace g2d;

	public class D2DTextureAtlas {
		
		private var _textures:Dictionary
		private var atlas:BitmapData
		public var id:String;

		private var gTextureAtlas:GTextureAtlas;
		
		public function D2DTextureAtlas(_id:String, _atlas:BitmapData){
			id = _id;
			_textures = new Dictionary();
			atlas = _atlas
		}
		
		public function dispose():void{
			atlas.dispose();
			atlas = null;
			for(var s:String in _textures){
				_textures[s].dispose();
				_textures[s] = null;
			}
			_textures = null;
			if(gTextureAtlas) gTextureAtlas.dispose();
			gTextureAtlas = null;
		}
		
		public function getTexture(_id:String):D2DTexture{
			if(!_textures) return null;
			var t:D2DTexture = _textures[_id];
			return _textures[_id];
		}
		
		public function addSubTexture(_id:String, _region:Rectangle, frame:Rectangle):void{
			var t:D2DTexture = new D2DTexture(id+ "_"+_id, atlas, _region, this, null, frame)
			_textures[_id] = t;
		}
		
		public function addSubTextureFromTexture(_id:String, texture:GTexture, region:Rectangle, frame:Rectangle):void{
			var t:D2DTexture = new D2DTexture(id+"_"+_id, atlas, region, this, texture, frame);
			_textures[_id] = t;
		}
		
		public static function createFromBitmapDataAndXML(_id:String, _bitmapData:BitmapData, _xml:XML):D2DTextureAtlas{
			var ta:D2DTextureAtlas = new D2DTextureAtlas(_id, _bitmapData);
			var i:int = 0;
			var element:XML
			var region:Rectangle;
			var frame:Rectangle 
			if(D2DRenderer.currentRenderer == D2DRenderer.STAGE3D){
				ta.gTextureAtlas = GTextureAtlasFactory.createFromBitmapDataAndXML(_id, _bitmapData, _xml);
				while(i < _xml.children().length()){
					element = _xml.children()[i];
					region = new Rectangle(element.@x, element.@y, element.@width, element.@height);
					if(element.@frameX){
						frame = new Rectangle(element.@frameX, element.@frameY, element.@frameWidth, element.@frameHeight);
//						trace("Using a trimmed sprite!");
						//coudn't figure out how to get things working the same with trimmed textures...so I gave up :)
					} else {
						frame = new Rectangle(0,0, element.@width, element.@height);
					}
					ta.addSubTextureFromTexture(element.@name, ta.gTextureAtlas.getTexture(element.@name), region, frame);
					i++
				}
			} else if(D2DRenderer.currentRenderer == D2DRenderer.BLITTING){
				while(i < _xml.children().length()){
					element = _xml.children()[i];
					region = new Rectangle(element.@x, element.@y, element.@width, element.@height);
					if(element.@frameX){
						frame = new Rectangle(element.@frameX, element.@frameY, element.@frameWidth, element.@frameHeight);
//						trace("Using a trimmed sprite!");
					} else {
						frame = new Rectangle(0,0, element.@width, element.@height);
					}
					ta.addSubTexture(element.@name, region, frame);
					i++
				}
			}

			return ta;
		}
	}
}