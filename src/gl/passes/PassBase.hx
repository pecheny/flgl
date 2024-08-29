package gl.passes;

import gl.aspects.RenderingAspect.RenderAspectBuilder;
import gl.ShaderRegistry.ShaderDescr;
import FuiBuilder.RenderingPipeline;
import ec.Entity;
import gl.AttribSet;
import shaderbuilder.ShaderElement;

class PassBase<TAtt:AttribSet> {
	var fui:RenderingPipeline;
	var attr:TAtt;

	public var shaderType(default, null):String;
	public var drawcallType(default, null):String;

	public var vertElems(default, null):Array<ShaderElement> = [];
	public var fragElems(default, null):Array<ShaderElement> = [];
	public var uniforms(default, null):Array<String> = [];
	public var alias(default, null):Array<String> = [];

	var aspectRegistrator:(Xml, RenderAspectBuilder) -> Void;
	var layerNameExtractor:Xml->String;

	public function new(att:TAtt, fui, shaderType, drawcallType) {
		this.fui = fui;
		this.attr = att;
		this.drawcallType = drawcallType;
		this.shaderType = shaderType;
	}

	function getShaderAlias() {
		if (alias.length > 0)
			return shaderType + "+" + alias.join("+");
		else
			return shaderType;
	}

	public function register() {
		// fui.regDrawcallType(drawcallType, , createGldo);
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

	public function createGldo(e:Entity, xml:Xml, aspects:RenderAspectBuilder) {
		if (aspectRegistrator != null)
			aspectRegistrator(xml, aspects);
		return fui.createGldo(attr, e, shaderType, aspects.build(), if (layerNameExtractor != null) layerNameExtractor(xml) else "");
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
