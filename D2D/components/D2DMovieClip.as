package D2D.components {
	import D2D.core.D2DNode;
	import D2D.core.D2DRenderer;
	import D2D.textures.D2DTexture;
	import D2D.textures.D2DTextureAtlas;
	
	public class D2DMovieClip extends D2DRenderable {
		
		public var _frames:Array 
		public var frameRate:int = 60;
		public var currentFrame:int = 0;
		public var repeatable:Boolean = true;
		
		private var playing:Boolean = false;
		private var elapsed:Number = 0;
		
		private var textureAtlas:D2DTextureAtlas;
		
		public function D2DMovieClip(_node:D2DNode){
			super(_node);
		}
		
		public function stop():void{
			playing = false;
		}
		
		public function play():void {
			playing = true;
		}
		
		public function gotoFrame(frame:int):void{
			if(frame < 0 || frame > frames.length-1){
				throw new Error(String("D2DMovieClip::gotoFrame() - Frame " +frame + " is out of the range {0-"+(frames.length-1)+"}"));
			} else {
				currentFrame = frame;
			}
		}
		
		public function set frames(value:Array):void{
			_frames = value;
			currentFrame = 0;
			elapsed = 0;
		}
		public function get frames():Array{
			return _frames;
		}
		
		public function setTextureAtlas(atlas:D2DTextureAtlas):void{
			textureAtlas = atlas;			
		}
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			
			if(playing){
				elapsed += deltaTime;
				while(elapsed > 1000/frameRate){
					elapsed -= 1000/frameRate;
					currentFrame++
					if(currentFrame >= frames.length){
						if(repeatable) currentFrame = 0;
						else currentFrame = frames.length-1
					}
				}
			}
			
		}
		
		override public function render():void{
			if(!textureAtlas) return;
			var t:D2DTexture = textureAtlas.getTexture(frames[currentFrame])
			if(!t) return;
			this._texture = t;
			if(D2DRenderer.currentRenderer == D2DRenderer.BLITTING){
				this.node.transform.pivotX = t.bitmapData.width/2
				this.node.transform.pivotY = t.bitmapData.height/2
			}
		
			D2DRenderer.draw(t, this.node.transform);
		}
		
		override public function dispose():void{
			super.dispose();
			frames = null;
			textureAtlas = null;
		}
	}
}