package gl.aspects;

import gl.GLDisplayObject;

class Uniform4fAspect implements RenderingAspect {
	var alias:String;
	var r:Float;
	var g:Float;
	var b:Float;
	var a:Float;

	public function new(alias:String, r:Float, g:Float, b:Float, a:Float) {
		this.alias = alias;
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public function bind(state:GLState<Dynamic>) {
		var gl = state.gl;
		gl.uniform4f(state.uniforms[alias], r, g, b, a);
	}

	public function unbind(state:GLState<Dynamic>) {}
}
