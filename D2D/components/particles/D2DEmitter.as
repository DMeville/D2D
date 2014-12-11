package D2D.components.particles {
	import D2D.components.D2DComponent;
	import D2D.components.D2DRenderable;
	import D2D.components.D2DSprite;
	import D2D.core.D2DNode;
	import D2D.core.D2DRenderer;
	import D2D.textures.D2DTexture;
	
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GConfig;
	
	import nape.callbacks.CbTypeList;
	import nape.space.Space;

		
	public class D2DEmitter extends D2DRenderable {
		
		public var emit:Boolean = false;
		public var emissionDelayVariance:int = 0;
		private var _emissionDelay:int = 100;
		public var lifespan:int = 1000;
		public var lifespaceVariance:int = 0;
		public var blendMode:* = GBlendMode.NORMAL
		
		public var initialRed:Number = 1;
		public var endRed:Number = 1;
		public var initialRedVariance:Number = 0;
		public var endRedVariance:Number = 0;
		
		public var initialGreen:Number = 1;
		public var endGreen:Number = 1;
		public var initialGreenVariance:Number = 0;
		public var endGreenVariance:Number = 0;
		
		public var initialBlue:Number = 1;
		public var endBlue:Number = 1;
		public var initialBlueVariance:Number = 0;
		public var endBlueVariance:Number = 0;
		
		public var initialAlpha:Number = 1;
		public var endAlpha:Number = 1;
		public var initialAlphaVariance:Number = 0
		public var endAlphaVariance:Number = 0;
		
		public var initialScale:Number = 1;
		public var endScale:Number = 1
		public var initialScaleVariance:Number = 0
		public var endScaleVariance:Number = 0
			
		public var anglularVelocity:Number = 0
		public var angularVelocityVariance:Number = 0
			
		public var velocityX:Number = 0;
		public var velocityY:Number = 0;
		
		public var velocityVarianceX:Number = 0;
		public var velocityVarianceY:Number = 0;
		
		public var dispersionX:Number = 0;
		public var dispersionY:Number = 0;
		
		public var texture:D2DTexture;
		public var _particlePool:Vector.<D2DParticle> = new Vector.<D2DParticle>();
		public var particles:Vector.<D2DParticle> = new Vector.<D2DParticle>();
		private var _elapsed:Number = 0;
		private var _maxParticles:int = 0
		private var _initialized:Boolean = false;
		
		public var useWorldSpace:Boolean = false;
		
		public var usePhysics:Boolean = false;
		public var space:Space = null
		public var collisionMask:int = -1
			
		public function D2DEmitter(_node:D2DNode) {
			super(_node);
		}
		
		override public function dispose():void{
			//clear vects, space ref if physics, etc
			super.dispose();
		}
		
		public function set emissionDelay(value:int):void {
			_emissionDelay = value;
		}
	

		public function init(_numParticles:int = 0, _usePhysics:Boolean = false, _space:Space = null):void{
			if(!_initialized){
				_initialized = true;
				_maxParticles = _numParticles;
				usePhysics = _usePhysics;
				space = _space;
				trace(_maxParticles, _numParticles);
				for(var i:int = 0; i < _numParticles; i++){
					var p:D2DParticle = D2DNode.createNodeWithComponent(D2DParticle, "particle") as D2DParticle;
					if(usePhysics) p.precachePhysics(space);
					p.node.active = false;
					p.node.transform.visible = false;
					_particlePool.push(p);
					this.node.addChild(p.node);					
				}
			}
		}
		
		
		
		private function getParticle():D2DParticle{
			var p:D2DParticle;
			if(_particlePool.length > 0){
				return _particlePool.shift();
			} else if(_particlePool.length == 0) {
				if(_maxParticles == -1){
					p = D2DNode.createNodeWithComponent(D2DParticle, "particle") as D2DParticle;
					return p;
				} else {
					return null;
				}
			} else {
				return null;
			}
		
		}
		
		public function setTexture(_texture:D2DTexture):void{
			if(_texture) {
				texture = _texture;
				if(D2DRenderer.currentRenderer == D2DRenderer.BLITTING){
					this.node.transform.pivotX = _texture.bitmapData.width/2
					this.node.transform.pivotY = _texture.bitmapData.height/2
				}
			}
		}
		
		
		override public function update(deltaTime:int):void{
//			trace("Active: " + particles.length, " | Pool: " + _particlePool.length);
			super.update(deltaTime);
			if(emit){
				_elapsed += deltaTime;
				while(_elapsed > _emissionDelay){
					_elapsed -= _emissionDelay;
					emitParticle();
//					_emissionDelay = emissionDelay + emissionDelayVariance*Math.random();
				}
			}
		}
		
		public function burst(_num:int = int.MAX_VALUE):void{
//			trace("Bursting!");
//			trace("Active: " + particles.length, " | Pool: " + _particlePool.length);
			var num:int = _num;
			if(num <=0) num = 0;
			if(num >= _particlePool.length) num = _particlePool.length;
//			trace("Bursting: " + num);
			while (num >0){
				emitParticle();
				num--;
			}

		}
		
		private function emitParticle():void{
//			trace("emit");
			var particle:D2DParticle = getParticle();
			if(particle == null) return;
			particles.push(particle);
			particle.init(this);
		}
	}
}