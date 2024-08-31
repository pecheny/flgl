package gl.aspects;

import gl.GLDisplayObject.GLState;
import bindings.GL;

class AlphaBlendingAspect implements RenderingAspect {
	public var srcAlpha = GL.SRC_ALPHA;
	public var dstAlpha = GL.ONE_MINUS_SRC_ALPHA;

	public function new(?src, ?dst) {
		if (src != null)
			this.srcAlpha = src;
		if (dst != null)
			this.dstAlpha = dst;
	}

	var formerSrc:Int;
	var formerDst:Int;

	public function bind(state:GLState<Dynamic>) {
		formerSrc = state.gl.SRC_ALPHA;
		formerDst = state.gl.DST_ALPHA;
		state.gl.enable(GL.BLEND);
		state.gl.blendFunc(srcAlpha, dstAlpha);
	}

	public function unbind(state:GLState<Dynamic>) {
		state.gl.blendFunc(formerSrc, formerDst);
	}
}
