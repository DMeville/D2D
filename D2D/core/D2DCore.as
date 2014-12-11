package D2D.core{
	
	import D2D.Stats;
	import D2D.components.D2DCamera;
	import D2D.components.D2DMovieClip;
	import D2D.components.D2DSprite;
	import D2D.components.particles.D2DEmitter;
	import D2D.input.D2DInput;
	import D2D.textures.D2DTexture;
	import D2D.textures.D2DTextureAtlas;
	import D2D.utils.D2DUtils;
	
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNode;
	import com.genome2d.core.Genome2D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import nape.geom.Vec2;
	import nape.space.Space;

	public class D2DCore{
		
		
		public static var stage:Stage;
		public static var width:Number;
		public static var height:Number;
		private static var _currentRenderer:String
		public static var onInitialized:Function;
		public static var paused:Boolean = false;
		public static var platform:String
		public static var device:String = ""
		public static var os:String
		public static var screenZoomFactor:Number = 1;
		
		private var _prevTime:int = 0;
		private var elapsed:Number = 0;
		private var _ignore:Boolean = true;
		
		public static var root:D2DNode;
		public static var camera:D2DCamera;

		public static var debugText:TextField;
		public static var _iRenderCount:int = 0;
		public static var _iUpdateCount:int = 0;

		private var _initialStateClass:Class;
		private var _currentState:D2DState;

		private var container:D2DNode;
		
		private var startupText:String = ""

		private static var _requestedState:Class;
		private static var _requestedStateChange:Boolean = false;
		public var currentState:D2DState;
		
		public static var physics:Function
		
		public function D2DCore(_stage:Stage, _initState:Class, _width:Number = 1024, _height:Number=768, _renderer:String = "stage3D"){//, launchImage:Bitmap) {
			stage = _stage;
			width = _width;
			height = _height;
			currentRenderer = _renderer
			_initialStateClass = _initState;
			
			setPlatform();
			trace(platform + " | " + device + " | " + os);
			if(platform == "desktop"){
				initD2D();
			} else {
				waitForResize();
			}

		}
		
		private function waitForResize():void{
			stage.addEventListener(Event.RESIZE, resized);
		}
		
		protected function resized(event:Event):void{
			trace("Stage size: " + stage.width, stage.height);
			height = stage.fullScreenHeight
			width = stage.fullScreenWidth;
			trace("Stage resized to: " + width, height);
			stage.removeEventListener(Event.RESIZE, resized);
			initD2D();
		}
		
		private function setPlatform():void{
			var _os:String = Capabilities.os.toLowerCase()
			startupText += os + "\n";
			if(_os.indexOf("mac") != -1){
				platform = "desktop";
				os = "mac";
			} else if(_os.indexOf("windows") != -1){
				if(_os.indexOf("windows mobile") != -1){
					platform = "mobile"
				} else {
					platform = "desktop";
				}
				os = "windows";
			} else if(_os.indexOf("linux") != -1){
				platform = "desktop";
				os = "linux";
			} else if(_os.indexOf("ipad1") != -1){
				platform = "mobile";
				device = "iPad1";
				os = _os;
			} else if(_os.indexOf("ipad2") != -1){
				platform = "mobile";
				device = "iPad2";
				os = _os;
			} else if(_os.indexOf("ipad3") != -1){
				platform = "mobile";
				device = "iPad3";
				os = _os;
			} else if(_os.indexOf("iphone1") != -1){
				platform = "mobile";
				device = "iPhone3G";
				os = _os;
			} else if(_os.indexOf("iphone2") != -1){
				platform = "mobile";
				device = "iPhone3GS";
				os = _os;
			} else if(_os.indexOf("iphone3") != -1){
				platform = "mobile";
				device = "iPhone4";
				screenZoomFactor = 0.5
				os = _os;
			} else if(_os.indexOf("iphone4") != -1){
				platform = "mobile";
				device = "iPhone4S";
				os = _os
			} else if(_os.indexOf("iphone5") != -1){
				platform = "mobile";
				device = "iPhone5";
				os = _os;
			} else if(_os.indexOf("ipd3") != -1){
				platform = "mobile";
				device = "iPod3";
				os = _os;
			} else if(_os.indexOf("ipod4") != -1){
				platform = "mobile";
				device = "iPod4";
				os = _os;
			} else if(_os.indexOf("ipod5") != -1){
				platform = "mobile";
				device = "iPod5";
				os = _os;
			} else {
				platform = "Unknown"
				device = "Unknown";
				os = _os;
			}
			
		}
		
		public static function get currentRenderer():String{
			return _currentRenderer;
		}

		public static function set currentRenderer(value:String):void{
			if(_currentRenderer == null){
				_currentRenderer = value;
			} else {
				throw new Error("D2DError: Can not change renderer while running!");
			}
		}

		private function initD2D():void{
			switch(currentRenderer){
				case "stage3D": 
					initStage3DRenderer();
					break;
				case "blitting": 
					initBlittingRenderer();
					break;
			}
		}
		
		private function initBlittingRenderer():void{
//			trace("D2DCore | Attempting to initialize Blitting renderer");
			startupText+=("\nD2DCore | Attempting to initialize Blitting renderer");
			D2DRenderer.blittingBuffer = new BitmapData(width, height, false, 0x0);
			stage.addChild(new Bitmap(D2DRenderer.blittingBuffer));
			rendererInitialized();
		}
		
		private function initStage3DRenderer():void{
//			trace("D2DCore | Attempting to initialize stage3D renderer");
			startupText+=("\nD2DCore | Attempting to initialize stage3D renderer");
			D2DRenderer.GCore = Genome2D.getInstance();
			D2DRenderer.GCore.onInitialized.addOnce(Stage3DInitialized);
			D2DRenderer.GCore.onFailed.addOnce(Stage3DFailed);
		 
			var config:GConfig = new GConfig(new Rectangle(0,0, width, height));	
			D2DRenderer.GCore.init(stage, config);	
			
		}
		
		private function Stage3DInitialized():void{
			D2DRenderer.GCore.autoUpdate = false;
			
			var driver:String = D2DRenderer.GCore.driverInfo.toLowerCase()
			startupText += "\n" +driver;
			if(driver.indexOf("software") != -1){
				startupText+=("\nD2DCore | Stage3D renderer initialized but hw acceleration is disabled... fall back to blitting");
				_currentRenderer = "blitting";
				initD2D();
			} else {
				rendererInitialized();
			}
		}
		
		private function Stage3DFailed():void{
//			trace("D2DCore | Stage3D Failed to initialize");
			startupText+=("\nD2DCore | Stage3D Failed to initialize - (wmode not set properly?)");
			_currentRenderer = "blitting";
			initD2D();
		}
		
		private function rendererInitialized():void{
//			trace("D2DCore | Renderer initialized - Current renderer: " + currentRenderer);
			startupText+=("\nD2DCore | Renderer initialized - Current renderer: " + currentRenderer);

			stage.addEventListener(Event.ENTER_FRAME, coreUpdate);
			root = D2DNode.getFromPool("D2D_root");
			
			D2DCore.camera = root.addComponent(D2DCamera) as D2DCamera;

			D2DCore.camera.node.transform.x = width/2;
			D2DCore.camera.node.transform.y = height/2;
					
			
			/*var container:D2DNode = new D2DNode("root_container");
			camera = container.addComponent(D2DCamera) as D2DCamera;
			
			root.addChild(container);
			root.transform.x = width/2
			root.transform.y = height/2*/
			
			
			D2DDebug.init()
			D2DDebug.text = startupText;
			D2DInitialized();
		}
	
		private function D2DInitialized():void{	
			if(onInitialized != null) onInitialized();
			create();
		}		
		
		private function create():void{
			currentState = D2DNode.createNodeWithComponent(_initialStateClass, "state") as D2DState
			root.addChild(currentState.node);
		}
		
		private function coreUpdate(e:Event):void{
			var _currentTime:int = getTimer();
			var deltaTime:int = _currentTime - _prevTime;
			_prevTime = _currentTime;
//			deltaTime = 1000/60;
			if(paused) deltaTime = 0;
			_iUpdateCount = 0;
			
			D2DInput.update(deltaTime);
			if(D2DInput.Keys.justReleased("P")) {
				trace("clicked");
				paused = !paused;
				if(paused) deltaTime = 0;
			}
			if(D2DInput.Keys.justReleased("BACKQUOTE")) D2DDebug.toggleVisible();
			
			if(_requestedStateChange){
				_requestedStateChange = false;
				currentState.node.dispose();
				currentState = D2DNode.createNodeWithComponent(_requestedState, "state") as D2DState;
				root.addChild(currentState.node);
			}
			
			if(physics != null) physics(deltaTime);
			update(deltaTime);
			D2DCore.camera.cameraUpdate(deltaTime); 
			
			_iRenderCount = 0;
			D2DRenderer.render(D2DCore.camera);
			D2DDebug.subtext = "Update Count: " + _iUpdateCount + " | Render Count: " + _iRenderCount;
		}
		
		public static function switchState(state:Class):void{
			if(!_requestedStateChange){
//				trace("D2DCore::switchState() | Switching state");
				_requestedStateChange = true;
				_requestedState = state;
			}
		}
		
		
		private function update(deltaTime:int):void{
			root.update(deltaTime);
		}	
		
		public static function pause():void{
			paused = true;
		}
		public static function unpause():void{
			paused = false;
		}
		public static function togglePause():void{
			paused = !paused;
		}
	}
}