package D2D.core {
	import D2D.components.D2DCamera;
	import D2D.components.D2DTransform;
	import D2D.textures.D2DTexture;
	import D2D.utils.D2DUtils;
	
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.Genome2D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class D2DRenderer {
		
		public static const STAGE3D:String = "stage3D";
		public static const BLITTING:String = "blitting";
		
		public static var GCore:Genome2D
		public static var blittingBuffer:BitmapData;
		private static var _currentRenderer:String;
		
		private static var _tempMatrix:Matrix;
		
		private static var helperPoint:Point = new Point();
		private static var helperRect:Rectangle = new Rectangle();
		private static var helperArray:Array = new Array();
		private static var helperColorTransform:ColorTransform = new ColorTransform();
		
		public static function get currentRenderer():String{
			_currentRenderer = D2DCore.currentRenderer;
			return _currentRenderer;
		}
		
		public static function draw(texture:D2DTexture, transform:D2DTransform):void{
			var worldTransform:Matrix = transform.getTransformationMatrix(D2DCore.root, helperArray);
			helperColorTransform.redMultiplier = helperArray[5];
			helperColorTransform.greenMultiplier = helperArray[6];
			helperColorTransform.blueMultiplier = helperArray[7];
			helperColorTransform.alphaMultiplier = helperArray[8];
			D2DCore._iRenderCount++
			
			switch(D2DCore.currentRenderer){
				case STAGE3D:
					if(helperArray[3] == 0 && helperArray[4] == 0){
						if(helperArray[0] == 0 && helperArray[5] == 1 && helperArray[6] == 1 && helperArray[7] == 1 && helperArray[8] == 1){
//							trace("Stage3D::blit()")
							GCore.context.blit(texture.texture, worldTransform.tx, worldTransform.ty, helperArray[1], helperArray[2], transform.blendMode);
						} else {
//							trace("Stage3D::draw()")
							GCore.context.draw(texture.texture, worldTransform.tx, worldTransform.ty, helperArray[1], helperArray[2], helperArray[0],
								helperColorTransform.redMultiplier, helperColorTransform.greenMultiplier, helperColorTransform.blueMultiplier, helperColorTransform.alphaMultiplier, 
								transform.blendMode, null, null)
						}
					} else {
//						trace("Stage3D::draw2()");
						GCore.context.draw2(texture.texture, worldTransform, helperColorTransform.redMultiplier, helperColorTransform.greenMultiplier, helperColorTransform.blueMultiplier, helperColorTransform.alphaMultiplier, transform.blendMode);
					}
					
				break;
				case BLITTING:	
					if(helperArray[0] == 0 && helperArray[1] == 1 && helperArray[2] == 1 && helperArray[3] == 0 && helperArray[4] == 0
					&& helperArray[5] == 1 && helperArray[6] == 1 && helperArray[7] == 1 && helperArray[8] == 1 && transform.blendMode == BlendMode.NORMAL){
//						trace("Blitting::copyPixels()");
						helperPoint.x = worldTransform.tx;
						helperPoint.y = worldTransform.ty;
						
						helperRect.x = 0;
						helperRect.y = 0;
						helperRect.width = texture.region.width;
						helperRect.height = texture.region.height;
						
						blittingBuffer.copyPixels(texture.bitmapData, helperRect, helperPoint);
					} else {
//						trace("Blitting::draw()");
						blittingBuffer.draw(texture.bitmapData, worldTransform, helperColorTransform, transform.blendMode);
					}
				break;
			}
		}
		
		public static function render(camera:D2DCamera):void{
			if(D2DCore.currentRenderer == STAGE3D){
				GCore.beginRender();
				var a:Array = D2DUtils.HexToRGBArray(D2DCore.camera.backgroundColor);
				helperRect.setEmpty()
				helperRect.x = 0;
				helperRect.y = 0;
				helperRect.width = D2DCore.width;
				helperRect.height = D2DCore.height;
				GCore.config.backgroundColor = D2DCore.camera.backgroundColor
			} else if(D2DCore.currentRenderer == BLITTING){
				blittingBuffer.lock();
				blittingBuffer.fillRect(blittingBuffer.rect, D2DCore.camera.backgroundColor);
			}
			
			D2DCore.camera.node.render();
			
			if(D2DCore.currentRenderer == STAGE3D){
				GCore.endRender()
			} else if(D2DCore.currentRenderer == BLITTING){
				blittingBuffer.unlock();
			}
		}
	}
}