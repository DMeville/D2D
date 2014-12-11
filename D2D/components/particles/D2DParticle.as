package D2D.components.particles {
	import D2D.components.D2DRenderable;
	import D2D.core.D2DNode;
	import D2D.core.D2DRenderer;
	
	import com.genome2d.context.GBlendMode;
	
	import flash.geom.Point;
	
	import nape.callbacks.CbType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.space.Space;


	public class D2DParticle extends D2DRenderable  {
		
		private var lifespan:int = 0;
		private var emitter:D2DEmitter;
		private var dRed:Number = 0;
		private var dGreen:Number = 0;
		private var dBlue:Number = 0;
		private var dAlpha:Number = 0;
		private var dScale:Number;
		
		public var velocityX:Number = 0
		public var velocityY:Number = 0;
		public var angularVelocity:Number = 0;
		
		private static var p:Point = new Point();
		
		public var body:Body = null
		public var hasPhysics:Boolean = false;
		
		public function D2DParticle(_node:D2DNode){
			super(_node);
		}
		
		public function init(_emitter:D2DEmitter):void{
			
			emitter = _emitter;
			this.node.active = true;
			this.node.transform.visible = true;
			this.node.transform.pivotX = emitter.node.transform.pivotX
			this.node.transform.pivotY = emitter.node.transform.pivotY
			
			if(emitter.useWorldSpace){
				this.node.transform.x = emitter.node.transform.x;
				this.node.transform.y = emitter.node.transform.y;
			} else {
				this.node.transform.x = 0;
				this.node.transform.y = 0;
			}
			
			this.node.transform.useWorldSpace = emitter.useWorldSpace;
			
			this.node.transform.blendMode = emitter.node.transform.blendMode;
			lifespan = emitter.lifespan + Math.random()*emitter.lifespaceVariance
			
			dRed = ((emitter.initialRed + emitter.initialRedVariance*Math.random()) - (emitter.endRed + emitter.endRedVariance*Math.random()))/lifespan
			dGreen = ((emitter.initialGreen + emitter.initialGreenVariance*Math.random()) - (emitter.endGreen + emitter.endGreenVariance*Math.random()))/lifespan
			dBlue = ((emitter.initialBlue + emitter.initialBlueVariance*Math.random()) - (emitter.endBlue + emitter.endBlueVariance*Math.random()))/lifespan
			dAlpha = ((emitter.initialAlpha + emitter.initialAlphaVariance*Math.random()) - (emitter.endAlpha + emitter.endAlphaVariance*Math.random()))/lifespan
				
			dScale = ((emitter.initialScale + emitter.initialScaleVariance*Math.random()) - (emitter.endScale + emitter.endScaleVariance*Math.random()))/lifespan;
			
			velocityX = emitter.velocityX + emitter.velocityVarianceX*Math.random();
			velocityY = emitter.velocityY + emitter.velocityVarianceY*Math.random();
			angularVelocity = emitter.anglularVelocity + emitter.angularVelocityVariance*Math.random();
			
			this.node.transform.scaleX = this.node.transform.scaleY = emitter.initialScale //+ scaleVariance
			this.node.transform.red = emitter.initialRed
			this.node.transform.green = emitter.initialGreen
			this.node.transform.blue = emitter.initialBlue
			this.node.transform.alpha = emitter.initialAlpha
			//do this for colours too, and any other transform properties that have an initial value
		
			this.node.transform.blendMode = emitter.blendMode	
			if(hasPhysics){
				body.position.x = this.node.transform.x;
				body.position.y = this.node.transform.y;
				body.velocity.x = velocityX
				body.velocity.y = velocityY
				body.angularVel = angularVelocity
				body.space = emitter.space;
				body.shapes.at(0).filter.collisionMask = emitter.collisionMask;
//				body.shapes.at(0).filter.collisionGroup = ~emitter.collisionMask;
			}
			
		}
		
	
		 
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			lifespan -= deltaTime;

			node.transform.red -= dRed*deltaTime;
			node.transform.green -= dGreen*deltaTime;
			node.transform.blue -= dBlue*deltaTime;
			node.transform.alpha -= dAlpha*deltaTime;
			node.transform.scaleX -= dScale*deltaTime;
			node.transform.scaleY -= dScale*deltaTime;
			if(!hasPhysics){
				node.transform.rotation += angularVelocity*deltaTime
				node.transform.x += velocityX*deltaTime/1000
				node.transform.y += velocityY*deltaTime/1000	
			} else {
				node.transform.rotation = body.rotation;
				node.transform.x = body.position.x;
				node.transform.y = body.position.y;
			}
			
			if(lifespan <=0){
				returnToPool()
			}
		}
		override public function render():void{
			super.render();
			if(!emitter.texture) return;
			D2DRenderer.draw(emitter.texture, this.node.transform);
		}
		
		 public function returnToPool():void{
//			trace("returned to pool");
			emitter.particles.splice(emitter.particles.indexOf(this),1);
			emitter._particlePool.push(this);
			this.node.active = false;
			this.node.transform.visible = false;
			if(hasPhysics){
				emitter.space.bodies.remove(body);
			}
		}
		 
		 
		public function precachePhysics(space:Space):void{
			hasPhysics = true;
			body = new Body(BodyType.DYNAMIC, Vec2.get(this.node.transform.x, this.node.transform.y));
			body.shapes.add(new Circle(5));
			body.shapes.at(0).material.elasticity = 1
		}
	}
}