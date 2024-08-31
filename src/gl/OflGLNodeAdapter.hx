package gl;

import bindings.WebGLRenderContext;
import openfl.display.OpenGLRenderer;
import openfl.events.Event;
import openfl.events.RenderEvent;
import openfl.display.Sprite;

class OflGLNodeAdapter extends Sprite {
	var childern:Array<GLNode> = [];

	public function new() {
		super();
		addEventListener(RenderEvent.RENDER_OPENGL, onRender);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function onEnterFrame(e) {
		invalidate();
	}

	public function update() {
		#if !flash
		invalidate();
		#end
	}

	function onRender(event) {
		var renderer:OpenGLRenderer = cast event.renderer;
		render(renderer.gl);
	}

	public function addNode(ch:GLNode) {
        childern.push(ch);
    }

	public function render(gl:WebGLRenderContext) {
        for(ch in childern)
            ch.render(gl);
    }
}
