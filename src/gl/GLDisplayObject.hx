package gl;
#if lime
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GL;
import openfl.display.OpenGLRenderer;
import openfl.events.RenderEvent;
#end
import gl.aspects.RenderingAspect;
import bindings.GLBuffer;
import bindings.GLProgram;
import bindings.WebGLRenderContext;
import gl.AttribSet;
import data.ShadersAttrs;
import openfl.events.Event;
import openfl.display.DisplayObject;

#if nme
         import nme.gl.GL as gl;
#end

class GLState<T:AttribSet> {
    public var program(default, null):GLProgram;
    public var uniforms(default, null):Map<String, GLUniformLocation> = new Map();
    public var attrsState(default, null):ShadersAttrs;
    var attrs:T;

    public var gl(default, null):WebGLRenderContext;

    public function new(set:T) {
        attrs = set;
    }

    public function init(gl:WebGLRenderContext, program:GLProgram, uniDef:Array<String>):Void {
        this.program = program;
        this.gl = gl;
        attrsState = attrs.buildState(gl, program);
        if (uniDef != null) {
            for (name in uniDef) {
                uniforms[name] = gl.getUniformLocation(program, name);
            }
        }
    }
}

class GLDisplayObject<T:AttribSet> extends DisplayObject {
    var children:Array<Renderable<T>> = [];
    var buffer:GLBuffer;
    var indicesBuffer:GLBuffer;
    var targets:RenderTargets<T> ;
    var renderingAspect:RenderingAspect;
    var gl:WebGLRenderContext;
    var set:T;

    var viewport:ViewportRect;
    public var srcAlpha = GL.SRC_ALPHA;
    public var dstAlpha = GL.ONE_MINUS_SRC_ALPHA;

    var shaderFactory:WebGLRenderContext -> GLState<T>;

    public function new(set:T, shaderFactory, aspect:RenderingAspect) {
        super();
        this.renderingAspect = aspect;
        this.set = set;
        this.shaderFactory = shaderFactory;
        this.targets = new RenderTargets(set);
        addEventListener(RenderEvent.RENDER_OPENGL, render);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    var err:String;

    var inited = false;

    function init(gl:WebGLRenderContext) {
        if (inited)return;
        this.gl = gl;
        buffer = gl.createBuffer();
        indicesBuffer = gl.createBuffer();
        inited = true;
    }

    function onEnterFrame(e) {
        invalidate();
    }

    public function update() {
        #if !flash
        invalidate();
        #end
    }

    public function addView(v:Renderable<T>) {
        children.push(v) ;
    }

    public function removeView(v:Renderable<T>) {
        children.remove(v) ;
    }


    public function render(event:RenderEvent) {
        var renderer:OpenGLRenderer = cast event.renderer;
        init(renderer.gl);

        targets.flush();

        for (child in children) {
            child.render(targets);
        }

        var state:GLState<T> = shaderFactory(gl);
        gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
        set.enableAttributes(gl, state.attrsState);
        gl.useProgram(state.program);
        if (renderingAspect != null)
            renderingAspect.bind(state);

        if (viewport != null)
            gl.viewport(viewport.x, viewport.y, viewport.width, viewport.height);

        gl.bufferData(gl.ARRAY_BUFFER, targets.verts.getView(), gl.STREAM_DRAW);
        gl.blendFunc(srcAlpha, dstAlpha);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indicesBuffer);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, targets.inds.getView(), gl.DYNAMIC_DRAW);
        gl.drawElements(gl.TRIANGLES, targets.indsCount(), gl.UNSIGNED_SHORT, 0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
        gl.useProgram(null);
        gl.bindBuffer(gl.ARRAY_BUFFER, null);
        if (renderingAspect != null)
            renderingAspect.unbind(state);
    }

    function printVerts(n) {
        for (i in 0...n)
            trace(set.printVertex(targets.verts.getBytes(), i));
    }

    public function setViewport(x, y, w, h) {
        this.viewport = new ViewportRect(x, y, w, h);
    }
}

class ViewportRect {
    public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;

    public function new(x, y, w, h) {
        this.x = x;
        this.y = y;
        this.width = w;
        this.height = h;
    }
}
