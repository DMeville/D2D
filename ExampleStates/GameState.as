package states {
	import D2D.components.D2DButton;
	import D2D.components.D2DCamera;
	import D2D.components.D2DComponent;
	import D2D.components.D2DMovieClip;
	import D2D.components.D2DParallax;
	import D2D.components.D2DPhysics;
	import D2D.components.D2DSkeletalAnimation;
	import D2D.components.D2DSprite;
	import D2D.components.D2DText;
	import D2D.components.D2DTiledSprite;
	import D2D.components.D2DTransform;
	import D2D.components.particles.D2DEmitter;
	import D2D.core.D2DCore;
	import D2D.core.D2DDebug;
	import D2D.core.D2DNode;
	import D2D.core.D2DState;
	import D2D.input.D2DInput;
	import D2D.textures.D2DTexture;
	import D2D.utils.D2DUtils;
	
	import com.genome2d.components.renderables.GTile;
	import com.genome2d.components.renderables.GTileMap;
	import com.genome2d.context.GBlendMode;
	
	import components.CharacterController;
	import components.CoinComponent;
	import components.KeyboardController;
	import components.ShadowComponent;
	
	import editors.Platform_Definition;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.flash_proxy;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.dynamics.CollisionArbiter;
	import nape.geom.Geom;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	import utils.PlatformFactory;
	
	public class GameState extends D2DState {

		public var toast:D2DNode;	
		private var controller:CharacterController;
		
		private var debug:ShapeDebug;
		
		private var platforms:Vector.<Vector.<D2DNode>> 
		
		public static const platformDX:Number = 100;
		public static const platformMinGap:Number = 100;
		public static const platformDY:Number = 0;
		public static const mindy:Number = 570;
		public static const maxdy:Number = 1200;
		public var platformLayer:D2DNode
		public var toastLayer:D2DNode
	
		

		private var sky:D2DSprite;

		private var mountainBlock:D2DSprite;

		private var bgParallax:Vector.<D2DSprite>;
		
		public function GameState(_node:D2DNode){
			super(_node);
//			D2DCore.camera.backgroundColor = 0xFFC495
//			D2DCore.camera.backgroundColor = 0xB6DBEC
			
			//initialize background
			SetupBackground();
			
			
		
			
			platformLayer  = D2DNode.getFromPool("platformLayer");
			toastLayer  = D2DNode.getFromPool("toastLayer");
			platforms = new Vector.<Vector.<D2DNode>>;
			platforms.push(new Vector.<D2DNode>());
			platforms.push(new Vector.<D2DNode>());
			platforms.push(new Vector.<D2DNode>());
	
			CreateToast();
			CreatePhysicsEmitter();
			initPhysicsListeners();
			
			Registry.seed = 8967442//Math.random()*0xFFFFFF
			trace("Seed: " +Registry.seed);
			StartLevelGeneration();
			addChild(platformLayer);
			addChild(toastLayer);
			addChild(Registry.physicsEmitter.node);
						
//			debug = new ShapeDebug(1024, 768);
//			D2DCore.stage.addChild(debug.display);
			D2DDebug.toggleVisible()
			D2DCore.physics = this.updatePhysics	
		}
		
		private function SetupBackground():void{
			D2DCore.camera.backgroundColor = 0x79AA96
			
			sky = D2DNode.createNodeWithComponent(D2DSprite, "sky_background") as D2DSprite;
			sky.setTexture(Assets.textures.getTexture("Sky"));
			sky.node.transform.scaleX = D2DCore.width/4
			
			addChild(sky.node);
			
			mountainBlock = D2DNode.createNodeWithComponent(D2DSprite, "mountain_block") as D2DSprite;
			mountainBlock.setTexture(Assets.textures.getTexture("SolidColor"));
			mountainBlock.node.transform.setHexColor(0x8289C3);
			addChild(mountainBlock.node);
			mountainBlock.node.transform.scaleY = 340/4;
			mountainBlock.node.transform.scaleX = D2DCore.width/4;
			
			D2DCore.camera.afterUpdate.push(alignBackground);
			
			bgParallax = new Vector.<D2DSprite>();
			var s:D2DSprite
			var p:D2DParallax;
			var lastPos:Number =0
			for(var i:int = 0; i < 5; i++){
				s = D2DNode.createNodeWithComponent(D2DSprite, "mountain") as D2DSprite;
				s.setTexture(Assets.textures.getTexture("Mountains_"+Math.floor(Math.random()*2)));
				if(i == 0) s.node.transform.x = -D2DCore.width/2 + lastPos
				else s.node.transform.x = lastPos + s.texture.region.width/2
				p = s.node.addComponent(D2DParallax) as D2DParallax;
				p.setParallax(-0.5,0);
				bgParallax.push(s);
				addChild(s.node);
				lastPos = s.node.transform.x + s.texture.region.width/2;
			}

		}
		
		private function alignBackground():void{
			sky.node.transform.x = -D2DCore.camera.node.transform.x + D2DCore.width/2;
			sky.node.transform.y = -D2DCore.camera.node.transform.y + D2DCore.height/2;
			
			mountainBlock.node.transform.x = -D2DCore.camera.node.transform.x + D2DCore.width/2 
			mountainBlock.node.transform.y = -D2DCore.camera.node.transform.y + D2DCore.height/2 + 350/2
		
			for(var i:int = 0; i < bgParallax.length; i++){
				bgParallax[i].node.transform.y = -D2DCore.camera.node.transform.y - 10 + D2DCore.height/2 - bgParallax[i].texture.region.height/2
			}
		}	
		
		private function updateParallax():void{
			var s:D2DParallax;
			
			for(var i:int = 0; i < bgParallax.length; i++){
				if(bgParallax[i].node.transform.x < -D2DCore.camera.node.transform.x - 300){
					s = bgParallax.shift().node.getComponent(D2DParallax) as D2DParallax;
					s.node.transform.x  = (bgParallax[bgParallax.length-1].node.getComponent(D2DParallax) as D2DParallax).realX + bgParallax[bgParallax.length-1].texture.region.width/2 + (s.node.getComponent(D2DSprite) as D2DSprite).texture.region.width/2
					s.setParallax(-0.5, 0);
					bgParallax.push(s.node.getComponent(D2DSprite));
				}
			}
		}
		
		
		private function CreatePhysicsEmitter():void{
			var e:D2DEmitter = D2DNode.createNodeWithComponent(D2DEmitter, "emitter") as D2DEmitter;
			e.velocityX = 500;
			e.velocityVarianceX = -200
			e.velocityY = -200
			e.velocityVarianceY = -200;
//			e.endScale = 0;
//			e.initialScale = 1;
			e.initialAlpha = 1;
			e.initialAlphaVariance = 0.2;
			e.endAlpha = 0;
			e.initialRed = 1;
			e.initialGreen = 1;
			e.initialBlue = 0;
			e.blendMode = GBlendMode.ADD
				
			
			e.useWorldSpace = true;
			e.setTexture(Assets.textures.getTexture("ParticleTexture"));
			e.collisionMask = 1;
			e.init(25, true, Registry.space);
			

			Registry.physicsEmitter = e;
		}		
		
		private function StartLevelGeneration():void{
			D2DUtils.setRandomSeed(Registry.seed);
			AddPlatformByName("Start_Platform",1);
			AddPlatformByName("Start_Platform",1, true);
			AddSplitter()			
		}
		
		private function AddSplitter():void{
			
			var p:D2DNode = AddPlatformByName("Horizontal_Small",1);
			AddPlatformByName("Start_Platform",1);

			
			var x:Number = p.transform.x
			var y:Number = p.transform.y
			
			var def:Platform_Definition = PlatformFactory.getDefByName("Small_Up")
			var platform:D2DNode = PlatformFactory.CreatePlatformFromDef(def, Registry.space, x, y - def.startY - 200);
			platformLayer.addChild(platform);
			platform.userData = new Object();
			platform.userData.def = PlatformFactory.getDefIndexByName("Small_Up")
			platform.userData.level = 2;
			platforms[2].push(platform);
			
			AddPlatformByName("Small_Up", 2);
			AddPlatformByName("Small_Up", 2);
			AddPlatformByName("Small_Up", 2);
			
			var def2:Platform_Definition = PlatformFactory.getDefByName("Small_Down")
			var platform2:D2DNode = PlatformFactory.CreatePlatformFromDef(def2, Registry.space, x, y - def.startY + 300);
			platformLayer.addChild(platform2);
			platform2.userData = new Object();
			platform2.userData.def = PlatformFactory.getDefIndexByName("Small_Down")
			platform2.userData.level = 0;
			platforms[0].push(platform2);
			AddPlatformByName("Small_Down", 0);
			AddPlatformByName("Small_Down", 0);
			AddPlatformByName("Small_Down", 0);
		}
		
		private function AddPlatformByName(name:String, level:int = 1, forceNoGap:Boolean = false):D2DNode{
			for(var i:int = 0; i < Registry.platforms.length; i++){
				if(Registry.platforms[i].name == name) break;
			}
			return AddPlatformByIndex(i, level, forceNoGap);
		}
		
		private function AddPlatformByIndex(i:int, level:int = 1, forceNoGap:Boolean = false):D2DNode{
			var x:int = 0;
			var y:int = 0;
			var lastP:D2DNode 
			var lastMiddle:D2DNode;
			var dy:Number
			var hasGap:Boolean;
			var gap:Number
			
			if(platforms[level].length > 0){
				lastP = platforms[level][platforms[level].length-1]
				if(platforms[1].length >0){
					lastMiddle = platforms[1][platforms[1].length-1];
					dy = Math.abs(lastMiddle.transform.y - lastP.transform.y);
				}
				if(level != 1){
					if(level > 1){
						if(dy < mindy){
							i = PlatformFactory.getDefIndexByDirection("UP");
						} else if(dy > maxdy){
							i = PlatformFactory.getDefIndexByDirection("DOWN");
						} else {
						}
					} else {// <1
						if(dy < mindy){
//							trace("too close");
							//too close;
							i = PlatformFactory.getDefIndexByDirection("DOWN");
						} else if(dy > maxdy){
							//too far
//							trace("too far");
							i = PlatformFactory.getDefIndexByDirection("UP");
						} else {
//							trace(mindy + " < " + dy + " < " + maxdy);

						}
					}
				}
				hasGap = D2DUtils.srandom() > 0.70?false:true;
				gap = 0;
				if(forceNoGap) hasGap = false;
				if(hasGap){
					gap +=  platformMinGap + D2DUtils.srandom()*platformDX	
				}
				x = lastP.transform.x + Math.abs(Registry.platforms[lastP.userData.def].endX) + Math.abs(Registry.platforms[i].startX) + gap
				y = lastP.transform.y + Registry.platforms[lastP.userData.def].endY - Registry.platforms[i].startY + (D2DUtils.srandom()*platformDY*2 - platformDY)
			}
			
			
			var platform:D2DNode = PlatformFactory.CreatePlatformFromDef(Registry.platforms[i], Registry.space, x, y, level);
			platformLayer.addChild(platform);
			platform.userData = new Object();
			platform.userData.def = i;
			platform.userData.level = level;
			platforms[level].push(platform);
			var def:Platform_Definition;
			
			var coinSprite:D2DSprite;
			var coinComp:CoinComponent;
			
			if(!hasGap){
				var s:D2DSprite = D2DNode.createNodeWithComponent(D2DSprite, "gapfix") as D2DSprite;
				s.setTexture(Assets.textures.getTexture("Platform"));
				platform.addChild(s.node);
				def = Registry.platforms[platform.userData.def]
				for(var i:int = 0; i < def.graphics.length; i++){
					if(def.graphics[i].scaleX < 0 && def.graphics[i].texture == "Platform_Edge"){
						s.node.transform.x = def.graphics[i].x - 42;
						s.node.transform.y = def.graphics[i].y - 2
					}
				}
				
				for(i = 0; i < def.collectables.length; i++){
					coinSprite = D2DNode.createNodeWithComponent(D2DSprite, "coin") as D2DSprite;
					coinSprite.setTexture(Assets.textures.getTexture("Coin"));
					coinSprite.node.transform.x = def.collectables[i].x;
					coinSprite.node.transform.y = def.collectables[i].y;
					coinComp = coinSprite.node.addComponent(CoinComponent) as CoinComponent;
					coinComp.setGraphic(coinSprite);
					platform.addChild(coinSprite.node);	
				}
				
			}
			return platform;
		}
		
		private function initPhysicsListeners():void{
			Registry.space.listeners.add(new PreListener(InteractionType.COLLISION, Registry.toastCb, Registry.platformCb, PlatformPrelistener));
			Registry.space.listeners.add(new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, Registry.toastCb, Registry.platformCb, ToastHitPlatform));
		}
		
		private function PlatformPrelistener(cb:PreCallback):PreFlag{
			var c:CollisionArbiter = cb.arbiter.collisionArbiter;
			if((c.normal.y < 0) != cb.swapped){
				return PreFlag.IGNORE;
			} else {
				return PreFlag.ACCEPT;
			}
		}
		
		private function ToastHitPlatform(cb:InteractionCallback):void{
			controller.cb = cb;
			
		}
		
		private function CreatePlatform(def:Platform_Definition, x:Number = 0, y:Number = 0):void{
			var platform:D2DNode = PlatformFactory.CreatePlatformFromDef(def, Registry.space, x, y);
			platformLayer.addChild(platform);
		}
		
		private function updatePlatforms():void{
			for(var i:int = 0; i < platforms.length;i++){
				for(var j:int = 0; j < platforms[i].length; j++){
					if(platforms[i][j].transform.x + D2DCore.camera.node.transform.x/D2DCore.camera.zoom + Registry.platforms[platforms[i][j].userData.def].endX + 400 < 0){
						platforms[i].splice(j,1)[0].dispose();
//						trace("Dispose");
						AddPlatformByIndex(Math.floor(Registry.platforms.length*D2DUtils.srandom()), i);
					}
				}
			}
		}

		
		override public function dispose():void{
			super.dispose();
			Registry.space.clear();
			D2DCore.physics = null;
//			debug.clear();
		}
		
		private function CreateToast():void{
//			var shadow:ShadowComponent = D2DNode.createNodeWithComponent(ShadowComponent, "toastShadow") as ShadowComponent;
			var polygon:Shape = new Circle(24);
			polygon.filter.collisionGroup = 2
			toast = D2DNode.getFromPool("toast");
			Registry.toast = toast;
			
			toast.transform.y -= 200;
			
			
			var g:D2DSkeletalAnimation = D2DNode.createNodeWithComponent(D2DSkeletalAnimation, "toast_skeletal") as D2DSkeletalAnimation;
			g.init(Assets.toastAnimationData);
			g.setBoneTexture("right_upper_leg", Assets.textures.getTexture("limb"));
			g.setBoneTexture("right_lower_leg", Assets.textures.getTexture("limb"));
			g.setBoneTexture("right_shoe", Assets.textures.getTexture("shoes_0"));
			g.setBoneTexture("left_upper_leg", Assets.textures.getTexture("limb"));
			g.setBoneTexture("left_lower_leg", Assets.textures.getTexture("limb"));
			g.setBoneTexture("left_shoe", Assets.textures.getTexture("shoes_0"));
			g.setBoneTexture("torso", Assets.textures.getTexture("Toast"));
			g.setBoneTexture("face", Assets.textures.getTexture("Toast_face_scared_1"));
			g.setBoneTexture("left_upper_arm", Assets.textures.getTexture("limb"));
			g.setBoneTexture("left_lower_arm", Assets.textures.getTexture("limb"));
			g.setBoneTexture("right_upper_arm", Assets.textures.getTexture("limb"));
			g.setBoneTexture("right_lower_arm", Assets.textures.getTexture("limb"));
			g.setBoneTexture("left_hand", Assets.textures.getTexture("glove_0"));
			g.setBoneTexture("right_hand", Assets.textures.getTexture("glove_0"));
			
			g.frameRate = 30
			g.frames = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
			toast.addChild(g.node);
			
			var hit:D2DSprite = D2DNode.createNodeWithComponent(D2DSprite, "toast_hit") as D2DSprite;
			hit.setTexture(Assets.textures.getTexture("SolidColor"));
			hit.node.transform.scaleX = hit.node.transform.scaleY = 35/4;
			hit.node.transform.visible = false;
			toast.addChild(hit.node);
			
			Registry.toastHitbox = hit
			var physics:D2DPhysics = toast.addComponent(D2DPhysics) as D2DPhysics;
			var body:Body = physics.init(Registry.space, polygon, BodyType.DYNAMIC);
			body.isBullet = true;
			
			body.cbTypes.add(Registry.toastCb);
			controller = toast.addComponent(CharacterController) as CharacterController
			controller.init(physics, g)
//			shadow.setTarget(toast)
			
//			toastLayer.addChild(shadow.node);
			toastLayer.addChild(toast);	
			D2DCore.camera.follow(toast, D2DCamera.STYLE_DELAY_FOLLOW);
			D2DCore.camera.followOffsetX = 200;
		}
		
		
		
		private function updatePhysics(deltaTime:int):void{
			 if(deltaTime > 0){
//				 debug.clear()
//				 debug.display.x = D2DCore.camera.node.transform.x;
//				 debug.display.y = D2DCore.camera.node.transform.y;
				 Registry.space.step(deltaTime/1000)
//				 debug.draw(Registry.space);
//				 debug.flush();
			 }
		}
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
//			trace(D2DComponent._count);
			updateParallax();
			updatePlatforms();		
		}
	}
}