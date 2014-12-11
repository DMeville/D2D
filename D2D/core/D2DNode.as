package D2D.core {
	import D2D.components.D2DComponent;
	import D2D.components.D2DRenderable;
	import D2D.components.D2DSprite;
	import D2D.components.D2DTransform;
	
	import com.genome2d.core.GNode;
	
	import editors.Editor;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class D2DNode {
		
		public static var _nodePool:Vector.<D2DNode> = new Vector.<D2DNode>()
		
		public var id:String
		
		public var _components:Vector.<D2DComponent>;
		public var parent:D2DNode;
		
		public var prev:D2DNode;
		public var next:D2DNode;
		public var firstChild:D2DNode;
		public var lastChild:D2DNode;
		public var userData:Object
		
		private var index:int = 0;
		public var transform:D2DTransform
		public var active:Boolean = true;
		private var _disposed:Boolean = false;
		private var _updating:Boolean = false;
		private var _rendering:Boolean = false;
		public var _disposeAfterUpdate:Boolean = false;
//		public var onScreen:Boolean = true;
		
		public function D2DNode(id:String) {
			this.id = id;
			_components = new Vector.<D2DComponent>();
			transform = D2DTransform.getFromPool(this);
			_components.push(transform);
		}
		
		public function init(id:String):void{
			this.id = id;
			transform = D2DTransform.getFromPool(this);
			_components.push(transform);
			prev = null;
			next = null;
			firstChild = null;
			lastChild = null;
			userData = null;
			index = 0;
			active = true;
			_disposed = false;
			_updating = false;
			_rendering = false;
			_disposeAfterUpdate = false;
		}
		
		
		public function update(deltaTime:int):void{
			if(!active) return;
			D2DCore._iUpdateCount++;
			_updating = true;
			index = _components.length -1;
			while(index >=0){
				_components[index].update(deltaTime);
				index--;
			}
			
			//children update
			
				
			var current:D2DNode = firstChild;
			while(current){
				current.update(deltaTime);
				if(current._disposeAfterUpdate){
					current.dispose();
				}
				current = current.next;
			}
			
			_updating = false;
		}
		
		public function render():void{
			if(transform.visible == false || transform.alpha == 0 || (this.id != "D2D_root" && parent ==null)) return;
			_rendering = true;
			index = 0
			var c:D2DComponent;
			while(index <= _components.length-1){
				c = _components[index];
				
				if(c is D2DRenderable) (c as D2DRenderable).render();
				index++;
			}
			
			//children render
			index = 0
			var current:D2DNode = firstChild;
			while(current != null){
				current.render();
				current = current.next;
			}
			_rendering = false;
		}
		
		public function addChild(node:D2DNode):void{
			if(node == this) throw new Error("D2DNode::addChild() - Can not add child to itself");
			var ol:D2DNode;
			if(firstChild == null){
				firstChild = node;
				lastChild = node;
			} else {
				ol = lastChild;
				ol.next = node;
				node.prev = ol;
				lastChild = node;
			}
			node.parent = this;
		}
		public function removeChild(node:D2DNode):void{
			if(node == null) throw new Error("D2DNode::removeChild() - Can not remove a null node");
			if(node.parent == null) throw new Error("D2DNode::removeChild() - Can not remove a node with a null parent");
			if(node == null) throw new Error("D2DNode::removeChild() - Can not remove a null node");
			if(node.parent == null) throw new Error("D2DNode::removeChild() - Can not remove a node with a null parent");
			
			node.parent = null;
			
			if(this.firstChild == node){
				firstChild = node.next;
			}
			
			if(this.lastChild == node){
				lastChild = node.prev;
			}
			
			if(node.prev) node.prev.next = node.next
			if(node.next) node.next.prev = node.prev;
			
			node.prev = null;
			node.next = null;
		}
		
		public function addComponent(component:Class):D2DComponent{
			var c:D2DComponent;
			if(component == D2DTransform){
				c = D2DTransform.getFromPool(this);
			} else if(component == D2DSprite){
				c = D2DSprite.getFromPool(this);
			} else {
				c = new component(this);
			}
			_components.push(c);
			return _components[_components.length-1];
		}
		
		public function removeComponent(component:D2DComponent):void{
			_components.splice(_components.indexOf(component),1);
		}
		
		public function getComponent(component:Class):D2DComponent{
			for(var i:int = 0; i < _components.length; i++){
				if(_components[i] is component) return _components[i];
			}
			return null;
		}
		
		
		public function dispose():void{
			if(_updating) {
				_disposeAfterUpdate = true;
				return;
			}
			
			while(_components.length>0){
				_components[_components.length-1].dispose();
			}
			
			_components.length = 0;
			disposeChildren();
			if(this.parent != null) this.parent.removeChild(this);
			parent = null;
			this.active = false;
			this._disposed = true;
			returnToPool();
			
		}
		
		public function disposeChildren():void{
			var first:D2DNode = firstChild;
			var next:D2DNode 
			while(first != null){
				next = first.next;
				first.parent = null;
				first.prev = null;
				first.next = null
				first.dispose();
				first = next;
			}
		}
		
		public function toString():String{
			return String("[D2DNode]_" + id);
		}
		
		
		public static function createNodeWithComponent(component:Class, node_id:String):D2DComponent{
			var node:D2DNode = D2DNode.getFromPool(node_id);
			return node.addComponent(component);
		}
		
		/**
		 * Use this function to get a node from the pool 
		 * @param id
		 * @return 
		 * 
		 */		
		public static function getFromPool(id:String):D2DNode{
			var n:D2DNode;
			if(_nodePool.length >0){
				n = _nodePool.shift();
				n.init(id);
				return n;
			} else {
				n = new D2DNode(id);
				return n;
			}
		}
		
		public function returnToPool():void{
			_nodePool.push(this);
		}
		
	}
}