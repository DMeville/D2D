package D2D.components {
	import D2D.core.D2DCore;
	import D2D.core.D2DNode;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class D2DCulling extends D2DComponent {
		
		public var width:Number = 0;
		public var height:Number = 0;
		public static var helperPoint:Point = new Point(0,0);
		public static var edge:Number = 100
		
			//this is inaccurate with the blitting renderer, something to do with the pivot I presume
		public function D2DCulling(_node:D2DNode) {
			super(_node);
		}
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			var m:Matrix = this.node.transform.getTransformationMatrix(D2DCore.camera.node); 
			var result:Boolean = checkPoint(0,0,m);
			
			if(result == true){
				this.node.transform.visible = true;
//				this.node.onScreen = true;
			} else {
				this.node.transform.visible = false;
//				this.node.onScreen = false;
			}

		}
		
		private function checkPoint(x:Number, y:Number, m:Matrix):Boolean{
			helperPoint = D2DTransform.transformPoint(x, y, m);
			helperPoint.offset(-D2DCore.width/2, -D2DCore.height/2);
			if(helperPoint.x <= D2DCore.width/2 + edge
				&& helperPoint.x >= -D2DCore.width/2 - edge
				&& helperPoint.y <= D2DCore.height/2 + edge
				&& helperPoint.y >= -D2DCore.height/2 - edge){ 
				return true;
			} else {
				return false;
			}
		}
		
		public function setSize(_width:Number, _height:Number):void{
			width = _width;
			height = _height;
		}
	}
}