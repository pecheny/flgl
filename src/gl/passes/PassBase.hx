package gl.passes;

import gl.AttribSet;
import gl.ShaderRegistry.ShaderDescr;
import gl.aspects.RenderingAspect.RenderAspectBuilder;
import shaderbuilder.ShaderElement;

class PassBase<TAtt:AttribSet> {
	public var attr (default, null):TAtt;

	public var shaderType(default, null):String;
	public var drawcallType(default, null):String;

	public var vertElems(default, null):Array<ShaderElement> = [];
	public var fragElems(default, null):Array<ShaderElement> = [];
	public var uniforms(default, null):Array<String> = [];
	public var alias(default, null):Array<String> = [];

	public var aspectRegistrator:(Xml, RenderAspectBuilder) -> Void;
	public var layerNameExtractor:Xml->String;

	public function new(att:TAtt, shaderType, drawcallType) {
		this.attr = att;
		this.drawcallType = drawcallType;
		this.shaderType = shaderType;
	}

	function getShaderAlias() {
		if (alias.length > 0)
			return drawcallType + "+" + alias.join("+");
		else
			return drawcallType;
	}


	public function getShaderDesc():ShaderDescr<TAtt> {
		return {
			type: getShaderAlias(),
			attrs: attr,
			vert: vertElems,
			frag: fragElems,
			uniforms: uniforms
		};
	}


	public function withLayerNameExtractor(layerNameExtractor) {
		this.layerNameExtractor = layerNameExtractor;
		return this;
	}

	public function withAspectRegistrator(aspectRegistrator) {
		this.aspectRegistrator = aspectRegistrator;
		return this;
	}
}
