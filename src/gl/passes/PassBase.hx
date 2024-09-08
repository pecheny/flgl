package gl.passes;

import gl.AttribSet;
import gl.ShaderRegistry.ShaderDescr;
import gl.aspects.RenderingAspect.RenderAspectBuilder;
import shaderbuilder.ShaderElement;

/**
	Pass is a wrapper around Shader desc and probably should be merged with. It provides parts to combine into exact shader.
	It also should be responsible for an unique key generation to be used in shader registry.
**/
class PassBase<TAtt:AttribSet> {
	public var attr(default, null):TAtt;

	/**
		Key for idendifying shader desc in the ShaderRegistry. 
		The descr consists of descriptions of attributes and uniforms and parts for shader program.
	**/
	public var shaderType(default, null):String;

	/**
		Key used as 'type' property of xml 'drawcall' node. Several drawcall types may refer to one shader type, 
		differing in aspects implementation or way to get aspects data.
		In other words the aspect which set predefined color value to the given uniform can get this value from different sources.
	**/
	public var drawcallType(default, null):String;

	public var vertElems(default, null):Array<ShaderElement> = [];
	public var fragElems(default, null):Array<ShaderElement> = [];
	public var uniforms(default, null):Array<String> = [];
	public var alias(default, null):Array<String> = [];

	public function new(att:TAtt, shaderType, drawcallType) {
		this.attr = att;
		this.drawcallType = drawcallType;
		this.shaderType = shaderType;
	}

	public function getShaderAlias() {
		if (alias.length > 0)
			return shaderType + "+" + alias.join("+");
		else
			return shaderType;
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
}
