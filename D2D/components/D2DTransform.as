package D2D.components {
	import D2D.core.D2DCore;
	import D2D.core.D2DNode;
	import D2D.core.D2DRenderer;
	import D2D.utils.D2DUtils;
	
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.factories.GTextureAtlasFactory;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class D2DTransform extends D2DComponent {
		
		public static var _transformPool:Vector.<D2DTransform> = new Vector.<D2DTransform>();

		private static var helperMatrix:Matrix = new Matrix();
		private static var helperMatrix2:Matrix = new Matrix();
		private static var helperPoint:Point = new Point();
		private static var helperArray:Array = new Array();

		public var visible:Boolean = true;
		
		private var _matrix:Matrix = new Matrix();
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _rotation:Number = 0;
		private var _skewX:Number = 0;
		private var _skewY:Number = 0;
		private var _pivotX:Number = 0;
		private var _pivotY:Number = 0;
		
		private var orientationChanged:Boolean = false;
		
		private var _gBlendMode:int = GBlendMode.NORMAL;
		private var _fBlendMode:String = BlendMode.NORMAL;
		
		public var red:Number = 1
		public var green:Number = 1
		public var blue:Number = 1 
		public var alpha:Number = 1 
		private var _colorTransform:ColorTransform = new ColorTransform();	
		
		public var useWorldSpace:Boolean = false;
		
		public function D2DTransform(_node:D2DNode){
			super(_node);		
		}
		public function init(_node:D2DNode):void{
			this.node = _node;
			visible = true;
			_matrix.identity();
			_x = _y = 0;
			_scaleX = _scaleY = 1;
			_rotation = 0;
			_skewX = _skewY = 0;
			_pivotX = _pivotY = 0;
			orientationChanged = false;
			_gBlendMode = GBlendMode.NORMAL;
			_fBlendMode = BlendMode.NORMAL;
			red = green = blue = alpha = 1;
			useWorldSpace = false;
		}
		
	
		override public function dispose():void{
			super.dispose();
			returnToPool();
		}
		
		public function returnToPool():void{
			_transformPool.push(this);
		}
		
		public function get x():Number{ return _x; } 
		public function set x(value:Number):void{
			if(_x != value){
				_x = value
				orientationChanged = true;
			}
		}
		
		public function get y():Number{ return _y; }
 		public function set y(value:Number):void{
			if(_y != value){
				_y = value
				orientationChanged = true;
			}
		}
		
		public function get scaleX():Number{ return _scaleX; }
		public function set scaleX(value:Number):void{
			if(_scaleX != value){
				_scaleX = value
				orientationChanged = true;
			}
		}
		
		public function get scaleY():Number{ return _scaleY; }
		public function set scaleY(value:Number):void{
			if(_scaleY != value){
				_scaleY = value
				orientationChanged = true;
			}
		}
		
		public function get skewX():Number{ return _skewX; }
		public function set skewX(value:Number):void{
			if(_skewX != value){
				_skewX = value
				orientationChanged = true;
			}
		}
		
		public function get rotation():Number{ return _rotation; }
		public function set rotation(value:Number):void{
			value = normalizeAngle(value)
			if(_rotation != value){
				_rotation = value
				orientationChanged = true;
			}
		}
		
		public function get skewY():Number{ return _skewY; }
		public function set skewY(value:Number):void{
			value = normalizeAngle(value);
			if(_skewY != value){
				_skewY = value
				orientationChanged = true;
			}
		}
		
		public function get pivotX():Number{ return _pivotX; }
		public function set pivotX(value:Number):void{
			if(_pivotX != value){
				_pivotX = value
				orientationChanged = true;
			}
		}
		
		public function get pivotY():Number{ return _pivotY; }
		public function set pivotY(value:Number):void{
			if(_pivotY != value){
				_pivotY = value
				orientationChanged = true;
			}
		}
		
		public static function normalizeAngle(angle:Number):Number {
			// move into range [-180 deg, +180 deg]
			while (angle < -Math.PI) angle += Math.PI * 2.0;
			while (angle >  Math.PI) angle -= Math.PI * 2.0;
			return angle;
		}
		
		

		public function setPosition(_x:Number, _y:Number):void{
			x = _x;
			y = _y;
		}
		
		public function setColor(_red:Number, _green:Number, _blue:Number, _alpha:Number=1):void{
			red = _red;
			green = _green;
			blue = _blue;
			alpha = _alpha;
		}
		
		public function setHexColor(_color:uint, _alpha:Number = 1):void{
			red = (_color >> 16 & 0xFF)/255
			green = (_color >> 8 & 0xFF)/255
			blue = (_color & 0xFF)/255
			alpha = _alpha;
		}
		
	
		
		public function get colorTransform():ColorTransform{
			_colorTransform.redMultiplier = red;
			_colorTransform.greenMultiplier = green;
			_colorTransform.blueMultiplier = blue;
			_colorTransform.alphaMultiplier = alpha;
			return _colorTransform;
		}

		public function set blendMode(value:*):void{
			if(value == BlendMode.NORMAL ||
				value == BlendMode.ADD ||
				value == BlendMode.MULTIPLY ||
				value == BlendMode.SCREEN ||
				value == BlendMode.ERASE ||
				value == BlendMode.NORMAL){
		
				_fBlendMode = value;
				
				switch(value){
					case BlendMode.NORMAL:  _gBlendMode = GBlendMode.NORMAL; break;	
					case BlendMode.ADD: 	_gBlendMode = GBlendMode.ADD; break;	
					case BlendMode.MULTIPLY:_gBlendMode = GBlendMode.MULTIPLY; break;	
					case BlendMode.SCREEN:  _gBlendMode = GBlendMode.SCREEN; break;	
					case BlendMode.ERASE:  _gBlendMode = GBlendMode.ERASE; break;	
					default:  _gBlendMode = GBlendMode.NORMAL; break;	
					
				}
			} else {
				_gBlendMode = value;
				switch(value){
					case 1: _fBlendMode = BlendMode.NORMAL; break;
					case 2: _fBlendMode = BlendMode.ADD; break;
					case 3: _fBlendMode = BlendMode.MULTIPLY; break;
					case 4: _fBlendMode = BlendMode.SCREEN; break;
					case 5: _fBlendMode = BlendMode.ERASE; break;
					default: _fBlendMode = BlendMode.NORMAL; break;
				}
			
			}
		}
		
		public function get blendMode():*{
			switch(D2DRenderer.currentRenderer){
				case D2DRenderer.STAGE3D:
					return _gBlendMode;
					break;
				case D2DRenderer.BLITTING:
					return _fBlendMode;
					break;
			}
		}
		
		public function get matrix():Matrix{
			if(orientationChanged){
				orientationChanged = false;
				_matrix.identity();
				
				if(_scaleX != 1 || _scaleY != 1)	_matrix.scale(_scaleX, _scaleY);
				if(_skewX != 0 || _skewY !=0) 		skew(_skewX, _skewY, _matrix);
				if(_rotation != 0) 					_matrix.rotate(_rotation);
				if(_x != 0 || _y != 0)				_matrix.translate(_x, _y);
				if(_pivotX != 0 || pivotY !=0){
					_matrix.tx = _x - _matrix.a * _pivotX - _matrix.c * _pivotY;
					_matrix.ty = _y - _matrix.b * _pivotX - _matrix.d * _pivotY;
				}
			}
			return _matrix;
		}
		
		public function getTransformationMatrix(targetSpace:D2DNode, values:Array = null):Matrix{
			var resultMatrix:Matrix = new Matrix();
			resultMatrix.identity();
			
			var current:D2DNode = this.node;
			
			if(values != null){
				values[0] = 0//rotation
				values[1] = 1//scaleX
				values[2] = 1//scaleY
				values[3] = 0//skewX
				values[4] = 0//skewY
					
				values[5] = 1; //red
				values[6] = 1; //green
				values[7] = 1; //blue
				values[8] = 1; //alpha
			}
						
			while(current){
				resultMatrix.concat(current.transform.matrix);
				if(values != null){
					values[0] += current.transform.rotation; //rotation
					values[1] *= current.transform.scaleX; //scaleX
					values[2] *= current.transform.scaleY; //scaleY
					values[3] += current.transform.skewX; //skewX
					values[4] += current.transform.skewY; //skewY
					
					values[5] *= current.transform.red;
					values[6] *= current.transform.green;
					values[7] *= current.transform.blue;
					values[8] *= current.transform.alpha;
				}
				
				if(current == targetSpace) break;
				if(useWorldSpace){
					resultMatrix.concat(targetSpace.transform.matrix);
					return resultMatrix;
				}
				current = current.parent;
			}
			
			if(current == null) throw new Error("D2DTransform::getTransformationMatrix - returned null before it reached the target space...perhaps it's not on the render graph?");
			
			return resultMatrix;
		}
		
		
		
		private function skew(skewX:Number, skewY:Number, matrix:Matrix):void{
			var sinX:Number = Math.sin(skewX);
			var cosX:Number = Math.cos(skewX);
			var sinY:Number = Math.sin(skewY);
			var cosY:Number = Math.cos(skewY);
			
			matrix.setTo(matrix.a  * cosY - matrix.b  * sinX,
				matrix.a  * sinY + matrix.b  * cosX,
				matrix.c  * cosY - matrix.d  * sinX,
				matrix.c  * sinY + matrix.d  * cosX,
				matrix.tx * cosY - matrix.ty * sinX,
				matrix.tx * sinY + matrix.ty * cosX);
		}
	
		public static function transformPoint(_x:Number, _y:Number, _matrix:Matrix):Point {
			helperPoint.x = 0;
			helperPoint.y = 0;
		
			var _m:Matrix = _matrix;
			
			helperPoint.x = _m.a*_x + _m.c*_y + _m.tx;
			helperPoint.y = _m.b*_x + _m.d*_y + _m.ty;
			
//			p = _m.transformPoint(new Point(_x, _y));
	
			return helperPoint;
		}
		
		/**
		 * 
		 * @param _localPoint Point in local space you want to convert to world space
		 * @param matrix Optional.  If using multiple localToWorld calls in succession, you can precalculate the matrix (getTransformationMatrix()) and pass it in.
		 * Otherwise it is recalculated on every call.
		 * @return the local point transformed to world coordinates
		 * 
		 */
		public function localToWorld(_localPoint:Point, matrix:Matrix = null):Point{
			if(matrix == null)  helperMatrix = getTransformationMatrix(D2DCore.camera.node);
			else helperMatrix = matrix;
			var p:Point = transformPoint(_localPoint.x, _localPoint.y, helperMatrix);
			p.offset(-D2DCore.width/2, -D2DCore.height/2);
			return p;
		}
		
		public function worldToLocal(_worldPoint:Point):Point{	
			
			helperArray.length = 0;
			var current:D2DNode = this.node;
			while(current){
				helperArray.push(current);
				current = current.parent;
			}
			
			var i:int = 0;
			helperMatrix.identity()
			var p:Point = _worldPoint;
			var n:D2DNode;
			
			n = helperArray.pop();
			helperMatrix = n.transform.matrix.clone();
			helperMatrix.invert();
			p.offset(D2DCore.width/2, D2DCore.height/2);
			p = transformPoint(p.x, p.y, helperMatrix);
			i++
			
			while(helperArray.length > 0){
				n = helperArray.pop();
				helperMatrix = n.transform.matrix.clone();
				helperMatrix.invert();
				p = transformPoint(p.x, p.y, helperMatrix);
				i++
			}
			
			return p;
		}
		public static function getFromPool(_node:D2DNode):D2DTransform{
			var t:D2DTransform;
			if(_transformPool.length > 0){
				t = _transformPool.shift();
				t.init(_node);
				return t;
			} else {
				t = new D2DTransform(_node);
				return t;
			}
		}
	}
}