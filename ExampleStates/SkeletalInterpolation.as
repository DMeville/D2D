package states {
	import D2D.components.D2DSkeletalAnimation;
	import D2D.components.D2DSprite;
	import D2D.core.D2DCore;
	import D2D.core.D2DDebug;
	import D2D.core.D2DNode;
	import D2D.core.D2DState;
	import D2D.input.D2DInput;
	
	public class SkeletalInterpolation extends D2DState {
		
		private var frameRate:Number = 30;
		private var elapsed:Number = 0;
		private var frame:int = 0;
		
		private var frames:Array
		

		private var s:D2DSkeletalAnimation;

		private var t:D2DSkeletalAnimation;

		public function SkeletalInterpolation(_node:D2DNode) {
			super(_node);
			D2DCore.camera.backgroundColor = 0x999999;
			Assets.init()
			s = D2DNode.createNodeWithComponent(D2DSkeletalAnimation, "skeletal") as D2DSkeletalAnimation;
			s.init(Assets.dinoAnimationData);
			s.setBoneTexture("jaw", Assets.textures.getTexture("dino_jaw"));
			s.setBoneTexture("head", Assets.textures.getTexture("dino_head"));
			s.setBoneTexture("torso", Assets.textures.getTexture("dino_torso"));
			addChild(s.node);
			s.frameRate = 1;
			//trace
			
			s.frames = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
			
			t = D2DNode.createNodeWithComponent(D2DSkeletalAnimation, "toast_skeletal") as D2DSkeletalAnimation;
			t.init(Assets.toastAnimationData);
			t.setBoneTexture("right_upper_leg", Assets.textures.getTexture("limb"));
			t.setBoneTexture("right_lower_leg", Assets.textures.getTexture("limb"));
			t.setBoneTexture("right_shoe", Assets.textures.getTexture("shoes_0"));
			t.setBoneTexture("left_upper_leg", Assets.textures.getTexture("limb"));
			t.setBoneTexture("left_lower_leg", Assets.textures.getTexture("limb"));
			t.setBoneTexture("left_shoe", Assets.textures.getTexture("shoes_0"));
			t.setBoneTexture("torso", Assets.textures.getTexture("Toast"));
			t.setBoneTexture("face", Assets.textures.getTexture("Toast_face_scared_1"));
			t.setBoneTexture("left_upper_arm", Assets.textures.getTexture("limb"));
			t.setBoneTexture("left_lower_arm", Assets.textures.getTexture("limb"));
			t.setBoneTexture("right_upper_arm", Assets.textures.getTexture("limb"));
			t.setBoneTexture("right_lower_arm", Assets.textures.getTexture("limb"));
			t.setBoneTexture("left_hand", Assets.textures.getTexture("glove_0"));
			t.setBoneTexture("right_hand", Assets.textures.getTexture("glove_0"));
			
			t.frameRate = 1;
			t.frames = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
			addChild(t.node);
			
			s.node.transform.x -= 400;
		}
		
	
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			
			
			if(D2DInput.Keys.UP){
				frameRate +=1
				if(frameRate > 200)  frameRate = 200;
			}
			if(D2DInput.Keys.DOWN){
				frameRate -= 1
				if(frameRate <1) frameRate = 1;
			}
			
			if(D2DInput.Keys.justReleased("SPACE")){
				if(s.frames.length !=1){
					s.frames = [0];
				} else {
					s.frames = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
				}
			}
			
			D2DDebug.text = String(frameRate);
			s.frameRate = Math.max(1,frameRate);
			t.frameRate = Math.max(1, frameRate);
			
		}
		
		
	}
}