package D2D.textures {
	import D2D.core.D2DRenderer;
	
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class D2DTexture {
		
		public var texture:GTexture;
		public var bitmapData:BitmapData
		
		public var subId:String 
		public var id:String;
		private var parent:D2DTextureAtlas;
		public var region:Rectangle
		private static var _p:Point = new Point();
		public var frame:Rectangle 
		
		public function D2DTexture(_id:String, _bitmapData:BitmapData, _region:Rectangle, _parent:D2DTextureAtlas = null, _texture:GTexture = null, _frame:Rectangle = null) { 
			parent = _parent;
			id = _id;
			if(_parent){
				//if we passed in a texture atlas as a parent, we need to create a new bmd to store the subtexture for blitting
				if(D2DRenderer.currentRenderer == D2DRenderer.BLITTING){
					bitmapData = new BitmapData(_region.width, _region.height, true, 0xFFFFFF);
					bitmapData.copyPixels(_bitmapData, _region, _p);
				} else {
					bitmapData = _bitmapData;
					texture = _texture;
				}
			} else {
				//if there is no parent, the entire 'atlas' is the entire 'subtexture'
				bitmapData = _bitmapData;
			}
			this.frame = _frame;	
			region = _region;
		}
		
		public function dispose():void{
			region = null;
			parent = null;
			if(bitmapData) bitmapData.dispose();
			bitmapData = null;
			if(texture) texture.dispose();
			texture = null;
		}
		
		public static function createFromBitmapData(id:String, bitmapData:BitmapData, transparent:Boolean = false):D2DTexture {
			var t:D2DTexture = new D2DTexture(id, bitmapData, bitmapData.rect, null); 
			switch(D2DRenderer.currentRenderer){
				case D2DRenderer.STAGE3D:
					t.texture = GTextureFactory.createFromBitmapData(id, bitmapData);
					break;
				case D2DRenderer.BLITTING:
					t.bitmapData = bitmapData;
					break;
			}
			
			t.frame = new Rectangle(0,0,bitmapData.width, bitmapData.height);
			return t;
		}
		
		public static function createFromAsset(id:String, asset:Class, transparent:Boolean = false):D2DTexture{
			var bitmapdata:BitmapData = (new asset() as Bitmap).bitmapData;
			var t:D2DTexture = new D2DTexture(id, bitmapdata, bitmapdata.rect , null);
			switch(D2DRenderer.currentRenderer){
				case D2DRenderer.STAGE3D:
					t.texture = GTextureFactory.createFromAsset(id, asset)
					break;
				case D2DRenderer.BLITTING:
					//The D2DTexture constructor does this...
					break;
			}
			t.frame = new Rectangle(0,0,bitmapdata.width, bitmapdata.height);
			return t;
		}	
		
		public static function createFromColor(id:String, color:uint, width:int, height:int):D2DTexture{
			var bitmapdata:BitmapData = new BitmapData(width, height, false, color);
			var t:D2DTexture = new D2DTexture(id, bitmapdata, bitmapdata.rect, null);
			
			switch(D2DRenderer.currentRenderer){
				case D2DRenderer.STAGE3D: 
					t.texture = GTextureFactory.createFromColor(id, color, width, height)
					break;
				case D2DRenderer.BLITTING:
					t.bitmapData = new BitmapData(width, height, false, color);
					break;
			}
			t.frame = new Rectangle(0,0,bitmapdata.width, bitmapdata.height);
			return t;
		}
	}
}