package D2D.components {
	import D2D.core.D2DCore;
	import D2D.core.D2DNode;
	import D2D.textures.D2DTexture;
	import D2D.utils.D2DUtils;
	
	import com.genome2d.context.GBlendMode;
	
	import flash.display.BlendMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import nape.geom.Vec2;

	public class D2DRenderable extends D2DComponent {
				
		internal var _texture:D2DTexture;
		internal static var p:Point = new Point();

		internal static var ax:Vector.<Number> = new Vector.<Number>();
		internal static var ay:Vector.<Number> = new Vector.<Number>();
		internal static var bx:Vector.<Number> = new Vector.<Number>();
		internal static var by:Vector.<Number> = new Vector.<Number>();
	
		public function D2DRenderable(_node:D2DNode)  {
			super(_node);
		}
		
		public function render():void{
			
		}
		
		public function containsPoint(x:Number, y:Number):Boolean{
			if(_texture == null) return false;
			if(x < _texture.region.width/2 + this.node.transform.pivotX &&
				x > -_texture.region.width/2 + this.node.transform.pivotX &&
				y < _texture.region.height/2 + this.node.transform.pivotY &&
				y > -_texture.region.height/2 + this.node.transform.pivotY){
				return true;
			}
			return false;
		}
		
		public function hitTestPoint(x:Number, y:Number):Boolean{
			return containsPoint(x, y);
		}
		
		public function hitTestObject(_object:D2DRenderable):Boolean{
			//shape one world verts
			
			//since we're constantly using the same node to world matrix, we could pre-compute it for 
			//a bit more speed
			
			if(_texture == null || _object._texture == null) return false;
			
			ax.length = 0;
			ay.length = 0;
			bx.length = 0;
			by.length = 0;
			
			var m:Matrix = this.node.transform.getTransformationMatrix(D2DCore.camera.node);
			
			p.x = _texture.region.width/2 + this.node.transform.pivotX;
			p.y = _texture.region.height/2 + this.node.transform.pivotY;
			p = this.node.transform.localToWorld(p,m);
			ax.push(p.x);
			ay.push(p.y);
			
			p.x = -_texture.region.width/2 + this.node.transform.pivotX;
			p.y = _texture.region.height/2 + this.node.transform.pivotY;
			p = this.node.transform.localToWorld(p,m);
			ax.push(p.x);
			ay.push(p.y);
			
			p.x = -_texture.region.width/2 + this.node.transform.pivotX;
			p.y = -_texture.region.height/2 + this.node.transform.pivotY;
			p = this.node.transform.localToWorld(p,m);
			ax.push(p.x);
			ay.push(p.y);
			
			p.x = _texture.region.width/2 + this.node.transform.pivotX;
			p.y = -_texture.region.height/2 + this.node.transform.pivotY;
			p = this.node.transform.localToWorld(p,m);
			ax.push(p.x);
			ay.push(p.y);
			
			//shape 2 world verts
			m = _object.node.transform.getTransformationMatrix(D2DCore.camera.node);
			p.x = _object._texture.region.width/2 + _object.node.transform.pivotX;
			p.y = _object._texture.region.height/2 + _object.node.transform.pivotY;
			p = _object.node.transform.localToWorld(p,m);
			bx.push(p.x);
			by.push(p.y);
			
			p.x = -_object._texture.region.width/2 + _object.node.transform.pivotX;
			p.y = _object._texture.region.height/2 + _object.node.transform.pivotY;
			p = _object.node.transform.localToWorld(p,m);
			bx.push(p.x);
			by.push(p.y);
			
			p.x = -_object._texture.region.width/2 + _object.node.transform.pivotX;
			p.y = -_object._texture.region.height/2 + _object.node.transform.pivotY;
			p = _object.node.transform.localToWorld(p,m);
			bx.push(p.x);
			by.push(p.y);
			
			p.x = _object._texture.region.width/2 + _object.node.transform.pivotX;
			p.y = -_object._texture.region.height/2 + _object.node.transform.pivotY;
			p = _object.node.transform.localToWorld(p,m);
			bx.push(p.x);
			by.push(p.y);
			
			for(var i:int = 0; i < ax.length; i++){
				for(var j:int = 0; j < bx.length; j++){
					if(D2DUtils.intersect(ax[i], ay[i], ax[(i+1)>3?0:i+1], ay[(i+1)>3?0:i+1],
										  bx[j], by[j], bx[(j+1)>3?0:j+1], by[(j+1)>3?0:j+1]) == true){
						return true;
					}
				}
			}
			
			
			return false;
		}
	}
}