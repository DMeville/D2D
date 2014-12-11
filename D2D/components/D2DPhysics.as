package D2D.components {
	import D2D.core.D2DCore;
	import D2D.core.D2DNode;
	
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	
	public class D2DPhysics extends D2DComponent {
		
		public var body:Body
		public var rotate:Boolean = false;
		
		public function D2DPhysics(_node:D2DNode){
			super(_node);
		}
		
		public function init(space:Space, _polygon:Shape, _bodyType:BodyType):Body{
			body = new Body(_bodyType);
			body.position.x = this.node.transform.x 
			body.position.y = this.node.transform.y
			body.shapes.add(_polygon);
			
			body.space = space;
			return body;
		}
		
		public function init_body(_space:Space, _body:Body):Body{
			this.body = _body;
			body.position.x = this.node.transform.x;
			body.position.y = this.node.transform.y;
			
			body.space = _space;
			return body;
			
		}
		
		public function init_geompoly(space:Space, _polygon:GeomPolyList, _bodyType:BodyType):Body{
			body = new Body(_bodyType);
			body.position.x = this.node.transform.x 
			body.position.y = this.node.transform.y
			this.body = body;
			//geompoly
			_polygon.foreach(function(p:GeomPoly):void{
				body.shapes.add(new Polygon(p));
			})
			
			body.space = space;
			return body;
		}
		
		override public function update(deltaTime:int):void{
			if(body.isStatic() || body == null) return;
			this.node.transform.x = body.position.x 
			this.node.transform.y = body.position.y 
			if(rotate) this.node.transform.rotation = body.rotation;
		}
		
		override public function dispose():void{
			super.dispose();
			body.space = null;
			body.shapes.clear();
			body = null;
		}
	}
}