package gl;

import gl.passes.PassBase;
import gl.aspects.RenderingAspect.RenderAspectBuilder;
import ecbind.RenderableBinder;
import gl.ShaderRegistry.IShaderRegistry;
import gl.GLDisplayObject;
import ec.Entity;
import gl.AttribSet;

#if slec
typedef Entity = ec.Entity;
#else
typedef Entity = {addComponent:Dynamic->Dynamic}
#end


class XmlProc {
	var handlers:Map<String, PassBase<Dynamic>> = new Map();
    var aspects:RenderAspectBuilder;

	public function new(aspects) {
        this.aspects = aspects;
	}

	public function processNode(e:Entity, node:Xml, ?container:Null<GldoContainer>):Entity {
		return switch (node.nodeName) {
			case "container": {
					var c = new GldoContainer();
					e.addComponent(c);
					if (container != null)
						container.addChild(c);
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
					var pass = handlers[type];
                    aspects.newChain(); // for now duplicates in pipe.cgldo
                    var gldo = pass.createGldo(e, node, aspects);
					if (container != null)
						container.addChild(gldo);
					else {
						e.addComponent(gldo);
					}
					e;
				}
			case _:
				throw "wrong " + node.nodeName;
		}
	}

	public function regHandler<T:AttribSet>(pass:PassBase<T>) {
		handlers[pass.drawcallType] = pass;
	}
}

typedef GldoContainer =
	#if openfl
	openfl.display.Sprite;
	#else
	{addChild: GLDisplayObject -> Void;}
	#end
