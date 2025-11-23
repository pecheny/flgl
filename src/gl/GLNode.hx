package gl;

import bindings.GL;
import bindings.GLBuffer;
import bindings.WebGLRenderContext;
import gl.AttribSet;
import gl.GLDisplayObject.GLState;
import gl.RenderTarget;
import gl.Renderable;
import gl.aspects.RenderingAspect;

class GLNode {
    var renderingAspects:Array<RenderingAspect> = [];

    public var name:String = "";

    public function addAspect(a) {
        renderingAspects.push(a);
    }

    public function render(gl:WebGLRenderContext) {}
}

class ContainerGLNode extends GLNode {
    public var children(default, null):Array<GLNode> = [];

    static var state = new GLState(null);

    public function new() {}

    override function render(gl:WebGLRenderContext) {
        // for now i didnt figure out yet how to separate two kind of aspects
        // shader/drawcall-related and just changing shared gl state
        // so leave dirty-dummy GLState instance to pass the context
        @:privateAccess state.gl = gl;
        super.render(gl);
        for (a in renderingAspects)
            a.bind(state);

        for (ch in children)
            ch.render(gl);

        for (a in renderingAspects)
            a.unbind(state);
    }

    public function addChild(ch) {
        children.push(ch);
    }
}

class ShadedGLNode<T:AttribSet> extends GLNode {
    var children:Array<Renderable<T>> = [];
    var buffer:GLBuffer;
    var indicesBuffer:GLBuffer;
    var targets:RenderTarget<T>;

    public var set(default, null):T;

    var shaderFactory:WebGLRenderContext->GLState<T>;
    var state:GLState<T>;

    public function new(set:T, shaderFactory, aspect:RenderingAspect) {
        if (aspect != null)
            renderingAspects.push(aspect);
        this.set = set;
        this.shaderFactory = shaderFactory;
        this.targets = new RenderTarget(set);
    }

    var err:String;

    var inited = false;

    function init(gl:WebGLRenderContext) {
        if (inited)
            return;
        // this.gl = gl;
        buffer = gl.createBuffer();
        indicesBuffer = gl.createBuffer();
        state = shaderFactory(gl);
        inited = true;
    }

    public function addView(v:Renderable<T>) {
        children.push(v);
    }

    public function removeView(v:Renderable<T>) {
        children.remove(v);
    }

    override public function render(gl:WebGLRenderContext) {
        init(gl);
        var NO_ERROR =
            #if lime
            gl.NO_ERROR;
            #else
            WebGLRenderContext.NO_ERROR;
            #end
        var err = gl.getError();
        if (err != NO_ERROR)
            trace("GL err " + err);
        if (gl.isContextLost())
            //  || this.gl.isContextLost())
            trace("context lost");

        targets.flush();

        for (child in children) {
            child.render(targets);
        }

        if (targets.indsCount() == 0)
            return;
        gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
        set.enableAttributes(gl, state.attrsState);
        gl.useProgram(state.program);
        for (a in renderingAspects)
            a.bind(state);

        gl.bufferData(GL.ARRAY_BUFFER, targets.verts.getView(), GL.STREAM_DRAW);
        gl.enable(GL.BLEND);
        // gl.blendFunc(srcAlpha, dstAlpha);
        gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
        gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, targets.inds.getView(), GL.DYNAMIC_DRAW);
        gl.drawElements(GL.TRIANGLES, Std.int(targets.indsCount()), GL.UNSIGNED_SHORT, 0);
        gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
        gl.useProgram(null);
        gl.bindBuffer(GL.ARRAY_BUFFER, null);

        for (a in renderingAspects)
            a.unbind(state);
    }
}
