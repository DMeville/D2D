package D2D.components {
	import D2D.core.D2DNode;
	import D2D.input.D2DInput;
	import D2D.textures.D2DTexture;
	import D2D.utils.PositionData;
	
	import flash.utils.Dictionary;
	
	public class D2DSkeletalAnimation extends D2DComponent {
	
		private var data:Dictionary
		private var parts:Dictionary 
		private var partsList:Array
		
		private var elapsed:Number = 0;
		public var frameRate:Number = 60
		
		private var currentFrame:int = 0;
		private var nextFrame:int = 1
		private var _frames:Array 
		private var _blendFrames:Array
		private var requestedFrameChange:Boolean = false;
		
		private var paused:Boolean = false;
		private var repeatable:Boolean = false;
		
		public function D2DSkeletalAnimation(_node:D2DNode) {
			super(_node);
		}
		
		public function get frames():Array{
			return _frames;
		}

		public function set frames(value:Array):void{
			if(_frames == null){
				_frames = value;
			} else {
				_blendFrames = value;
				nextFrame = 0;
				requestedFrameChange = true
			}
		}

		public function init(xml:XML):void{
			
			data = new Dictionary();
			parts = new Dictionary();
			partsList = new Array();
			
			var frames:XMLList = xml.frame;
			var bones:XMLList
			var o:PositionData

			for(var i:int = 0; i < frames.length(); i++){
				bones = frames[i].bone;
				for(var j:int = 0; j < bones.length(); j++){
					if(i == 0) {
						data[bones[j].@name.toString()] = new Vector.<PositionData>();	
						partsList.push(bones[j].@name.toString());
					}
					
					o = new PositionData();
					o.x = bones[j].@x;
					o.y = bones[j].@y;
					o.rotation = bones[j].@rotation;
					o.scaleX = bones[j].@scaleX;
					o.scaleY = bones[j].@scaleY;
					data[bones[j].@name.toString()].push(o);
				}	
			}
			
			for(var k:String in data){
				parts[k] = D2DNode.createNodeWithComponent(D2DSprite, "skeletal_"+k);
				parts[k].node.transform.x = data[k][0].x;
				parts[k].node.transform.y = data[k][0].y;
				parts[k].node.transform.rotation = data[k][0].rotation;
				parts[k].node.transform.scaleX = data[k][0].scaleX;
				parts[k].node.transform.scaleY = data[k][0].scaleY;
			}
			
			for(i = 0; i <partsList.length;i++){
				this.node.addChild(parts[partsList[i]].node);
			}
			
		}
		
		override public function update(deltaTime:int):void{
			super.update(deltaTime);
			elapsed += deltaTime;
			while(elapsed > 1000/frameRate) {
				elapsed -= 1000/frameRate;
				currentFrame++;
				if(currentFrame >= frames.length){
					currentFrame = 0
				}
				nextFrame = currentFrame+1;
				if(nextFrame >= frames.length){
					nextFrame = 0
				}
				
				if(requestedFrameChange){
					requestedFrameChange = false;
					_frames = _blendFrames;
					_blendFrames = null;
					currentFrame = 0;
					nextFrame = 1;
					if(nextFrame >= frames.length) nextFrame = 0;
				}
			}
			
			var interpolation:Number = (elapsed*frameRate)/1000
			updatePositions(interpolation);
			
		}
		
		private function updatePositions(interpolation:Number = 0):void{
			for(var k:String in parts){
				updatePart(k, interpolation);
			}
		}
		
		private function updatePart(k:String, interpolation:Number = 0):void{
//			trace("Interpolation position: " + interpolation);
			if(D2DInput.Keys.I){
				interpolation = 0;
			}
			if(requestedFrameChange){
				parts[k].node.transform.x = data[k][frames[currentFrame]].x  + (data[k][_blendFrames[nextFrame]].x - data[k][frames[currentFrame]].x)*interpolation;
				parts[k].node.transform..y = data[k][frames[currentFrame]].y + (data[k][_blendFrames[nextFrame]].y - data[k][frames[currentFrame]].y)*interpolation;
				parts[k].node.transform..rotation = data[k][frames[currentFrame]].rotation + (data[k][_blendFrames[nextFrame]].rotation - data[k][frames[currentFrame]].rotation)*interpolation;
				parts[k].node.transform..scaleX = data[k][frames[currentFrame]].scaleX + (data[k][_blendFrames[nextFrame]].scaleX - data[k][frames[currentFrame]].scaleX)*interpolation;
				parts[k].node.transform..scaleY = data[k][frames[currentFrame]].scaleY + (data[k][_blendFrames[nextFrame]].scaleY - data[k][frames[currentFrame]].scaleY)*interpolation;
			} else {
				parts[k].node.transform.x = data[k][frames[currentFrame]].x  + (data[k][frames[nextFrame]].x - data[k][frames[currentFrame]].x)*interpolation;
				parts[k].node.transform..y = data[k][frames[currentFrame]].y + (data[k][frames[nextFrame]].y - data[k][frames[currentFrame]].y)*interpolation;
				parts[k].node.transform..rotation = data[k][frames[currentFrame]].rotation + (data[k][frames[nextFrame]].rotation - data[k][frames[currentFrame]].rotation)*interpolation;
				parts[k].node.transform..scaleX = data[k][frames[currentFrame]].scaleX + (data[k][frames[nextFrame]].scaleX - data[k][frames[currentFrame]].scaleX)*interpolation;
				parts[k].node.transform..scaleY = data[k][frames[currentFrame]].scaleY + (data[k][frames[nextFrame]].scaleY - data[k][frames[currentFrame]].scaleY)*interpolation;
			}
		}
		
		public function setBoneTexture(bone:String, texture:D2DTexture):void{
			parts[bone].setTexture(texture);
		}
	}
}

