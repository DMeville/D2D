package D2D.utils {
	import flash.geom.Matrix;

	public class D2DUtils {
		
		/** Creates an Array to make the animation frame assignment process quicker
		 *  GetFrameSequence("a_", 1, 4) //outputs ["a_1", "a_2", "a_3", "a_4"]
		 *  
		 * @param prefix  The animation prefix name (as outlined in the textures XML file)
		 * @param start   The start frame (inclusive)
		 * @param end     The end frame (inclusive);
		 * @return   	  An Array of the animation sequence
		 * 
		 */		
		public static function GetFrameSequence(prefix:String, start:int, end:int):Array{
			var sequence:Array = new Array();
			for(var i:int = start; i<=end;i++){
				if(i < 10){
					sequence.push(String(prefix+"000"+i));
				} else if (i>=10 && i<100){
					sequence.push(String(prefix+"00"+i));
				} else if(i >=100 && i<1000){
					sequence.push(String(prefix+"0"+i));
				} else {
					sequence.push(String(prefix+i));
				}
			}
			return sequence;
		}
		
		public static function HexToRGBArray(hex:uint):Array{
			var red:Number = hex >> 16 & 0xFF;
			var green:Number = hex >> 8 & 0xFF;
			var blue:Number = hex & 0xFF;
			
			red /=255
			green /=255
			blue /=255
			
			return new Array([red, green, blue]);
		}
		
		
		public static function DegreesToRadians(_degrees:Number):Number{
			return (_degrees%360)*(Math.PI/180)
		}
		
		public static function RadiansToDegrees(_radians:Number):Number{
			return _radians*(180/Math.PI);
		}
		
		public static function skew(matrix:Matrix, skewX:Number, skewY:Number):void{
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
		public static function intersect(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number):Boolean{
			var cp:Number = (bx - ax)*(cy - by) - (by - ay)*(cx - bx); //c on [ab]
			var dp:Number = (bx - ax)*(dy - by) - (by - ay)*(dx - bx); //d on [ab]
			var ap:Number = (dx - cx)*(ay - dy) - (dy - cy)*(ax - dx); //a on [cd]
			var bp:Number = (dx - cx)*(by - dy) - (dy - cy)*(bx - dx); //b on [cd]
			
			if(((ap > 0 && bp < 0) || (ap <0 && bp >0)) && ((cp > 0 && dp < 0) || (cp <0 && dp >0))) return true;
			return false;
		}
		
		
		public static function setRandomSeed(seed:uint):void{
			PRandom.seed = seed;
		}
		
		public static function srandom():Number{
			return PRandom.random()
		}
	}
}