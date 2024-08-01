package gl;

import ecbind.RenderableBinder;
import gl.ShaderRegistry.IShaderRegistry;
import gl.GLDisplayObject;
import ec.Entity;
import gl.AttribSet;
import gl.GldoBuilder;

#if slec
typedef Entity = ec.Entity;
#else
typedef Entity = {addComponent:Dynamic->Dynamic}
#end

typedef GldoFactory<T:AttribSet> = Entity -> Xml -> GLDisplayObject<T>;

class XmlProc {
	var handlers:Map<String, GldoFactory<Dynamic>> = new Map();
	var gldoBuilder:GldoBuilder;

	public function new(gb) {
		this.gldoBuilder = gb;
	}

	public function processNode(e:Entity, node:Xml, ?container:Null<GldoContainer>):Entity {
		return switch (node.nodeName) {
			case "container": {
					var c = new GldoContainer();
					e.addComponent(c);
					if (container != null)
						container.addChild(c);
					var dc = gldoBuilder.getDrawcalls(e);
					for (child in node.elements()) {
						processNode(e, child, c);
					}
					e;
				}
			case "drawcall": {
					var type = node.get("type");
					if (!handlers.exists(type)) {
						trace('No "$type" drawcall type was registered.');
						return e;
					}
					var gldo = handlers[type](e, node);
					if (container != null)
						container.addChild(gldo);
					else {
						var dc = gldoBuilder.getDrawcalls(e);
						e.addComponent(gldo);
					}
					e;
				}
			case _:
				throw "wrong " + node.nodeName;
		}
	}

	public function regHandler(t, h) {
		handlers[t] = h;
	}
}

typedef GldoContainer =
	#if openfl
	openfl.display.Sprite;
	#else
	{addChild: GLDisplayObject -> Void;}
	#end
