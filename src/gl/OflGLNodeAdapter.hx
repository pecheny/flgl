package gl;

import gl.aspects.RenderingAspect;
import gl.GLNode.ContainerGLNode;
import openfl.display.DisplayObject;
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
        for (ch in childern)
            ch.render(gl);
    }
}

class OflGLNodeMixer extends Sprite implements ContainerGLNode {
    public var children(default, null):Array<GLNode> = [];

    var renderingAspects:Array<RenderingAspect> = [];

    public function addAspect(a) {
        renderingAspects.push(a);
        for (c in children)
            c.addAspect(a);
    }

    public function addNode(node:GLNode) {
        children.push(node);
        for (a in renderingAspects)
            node.addAspect(a);
        var last = getChildAt(numChildren);
        var adapter:OflGLNodeAdapter;
        if (last != null && Std.isOfType(last, OflGLNodeAdapter)) {
            adapter = cast last;
        } else {
            adapter = new OflGLNodeAdapter();
            addChild(adapter);
        }
        adapter.addNode(node);
    }

    override public function addChild(c) {
        return super.addChild(c);
    }

    public function render(gl:WebGLRenderContext) {
        throw "Wrong!";
    }
}
