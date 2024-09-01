package gl;

import gl.GLNode;
import gl.aspects.RenderingAspect;
import gl.passes.PassBase;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder;
import utils.TextureStorage;

class RenderingPipeline {
	public var renderAspectBuilder(default, null):RenderAspectBuilder;
	public var textureStorage:TextureStorage;
	public var shaderRegistry:ShaderRegistry;

	var pos:ShaderElement = PosPassthrough.instance;

	public function new() {
		renderAspectBuilder = new RenderAspectBuilder();
		textureStorage = new TextureStorage();
		shaderRegistry = new ShaderRegistry();
	}

	public function hasDrawcallType(type) {
		return (shaderRegistry.getDescr(type) != null);
	}

	public function addAspect(a:RenderingAspect) {
		renderAspectBuilder.addShared(a);
	}

	public function setPositioning(pos:ShaderElement) {
		this.pos = pos;
		return this;
	}

	public function createContainer(descr):GLNode {
		var node = processNode(descr);
		renderAspectBuilder.reset();
		return node;
	}

	var handlers:Map<String, PassBase<Dynamic>> = new Map();

	public function processNode( node:Xml, ?container:Null<ContainerGLNode>):GLNode {
		return switch (node.nodeName) {
			case "container": {
					var c = new ContainerGLNode();
					if (container != null)
						container.addChild(c);
					for (child in node.elements()) {
						processNode( child, c);
					}
					c;
				}
			case "drawcall": {
					var type = node.get("type");
					if (!handlers.exists(type)) {
						trace('No "$type" drawcall type was registered.');
						return container;
					}
					var pass = handlers[type];
					renderAspectBuilder.newChain();

					if (pass.aspectRegistrator != null)
						pass.aspectRegistrator(node, renderAspectBuilder);
					var gldo = new ShadedGLNode(pass.attr, shaderRegistry.getState.bind(pass.attr, _, pass.getShaderAlias()), renderAspectBuilder.build());

					if (pass.layerNameExtractor != null)
						gldo.name = pass.layerNameExtractor(node);
					if (container != null)
						container.addChild(gldo);
					gldo;
				}
			case _:
				throw "wrong " + node.nodeName;
		}
	}

	public function addPass<TAtt:AttribSet>(p:PassBase<TAtt>) {
		shaderRegistry.reg(p.getShaderDesc());
		handlers[p.drawcallType] = p;
	}
}
