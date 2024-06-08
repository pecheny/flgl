package gl;
#if lime
import openfl.display.OpenGLRenderer;
import openfl.events.RenderEvent;
import openfl.events.Event;
import openfl.display.DisplayObject;
#else
#end
import bindings.GL;
import gl.aspects.RenderingAspect;
import bindings.GLBuffer;
import bindings.GLProgram;
import bindings.WebGLRenderContext ;
import bindings.GLUniformLocation;
import bindings.GLDrawcall;
import gl.AttribSet;
import data.ShadersAttrs;

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

class GLDisplayObject<T:AttribSet> implements GLDrawcall
#if openfl extends openfl.display.Sprite
    #end {
    var children:Array<Renderable<T>> = [];
    var buffer:GLBuffer;
    var indicesBuffer:GLBuffer;
    var targets:RenderTarget<T> ;
    var renderingAspect:RenderingAspect;
    var gl:WebGLRenderContext;
    var set:T;

    var viewport:ViewportRect;
    public var srcAlpha = GL.SRC_ALPHA;
    public var dstAlpha = GL.ONE_MINUS_SRC_ALPHA;

    var shaderFactory:WebGLRenderContext -> GLState<T>;
    var state:GLState<T>;

    public function new(set:T, shaderFactory, aspect:RenderingAspect) {
        this.renderingAspect = aspect;
        this.set = set;
        this.shaderFactory = shaderFactory;
        this.targets = new RenderTarget(set);
        #if openfl
        super();
        addEventListener(RenderEvent.RENDER_OPENGL, onRender);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        #end
    }

    var err:String;

    var inited = false;

    function init(gl:WebGLRenderContext) {
        if (inited)return;
        this.gl = gl;
        buffer = gl.createBuffer();
        indicesBuffer = gl.createBuffer();
        state = shaderFactory(gl);
        inited = true;
    }
#if openfl
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
    #end

    public function addView(v:Renderable<T>) {
        children.push(v) ;
    }

    public function removeView(v:Renderable<T>) {
        children.remove(v) ;
    }


    public function render(gl:WebGLRenderContext) {
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
        if(gl.isContextLost() || this.gl.isContextLost())
            trace("context lost");

        targets.flush();

        for (child in children) {
            child.render(targets);
        }

        if(targets.indsCount() == 0)
            return;
        gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
        set.enableAttributes(gl, state.attrsState);
        gl.useProgram(state.program);
        if (renderingAspect != null)
            renderingAspect.bind(state);

        if (viewport != null)
            gl.viewport(viewport.x, viewport.y, viewport.width, viewport.height);

        gl.bufferData(GL.ARRAY_BUFFER, targets.verts.getView(), GL.STREAM_DRAW);
        gl.enable(GL.BLEND);
        gl.blendFunc(srcAlpha, dstAlpha);
        gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
        gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, targets.inds.getView(), GL.DYNAMIC_DRAW);
        gl.drawElements(GL.TRIANGLES,Std.int( targets.indsCount() ), GL.UNSIGNED_SHORT, 0);
        gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
        gl.useProgram(null);
        gl.bindBuffer(GL.ARRAY_BUFFER, null);
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
