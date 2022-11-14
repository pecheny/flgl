package flgl;

import js.Browser;
import js.html.CanvasElement;
import bindings.WebGLRenderContext;
import bindings.GLDrawcall;
import bindings.GL;
import utils.Signal;

class WebGlRenderer {
    var gl:WebGLRenderContext;
    var canvas:CanvasElement;
    var children:Array<GLDrawcall> = [];
    public var width(default, null):Int = 0;
    public var height(default, null):Int = 0;

    public var onResize(default, null):Signal<Int->Int->Void> = new Signal();
    public function new() {
        canvas = Browser.document.createCanvasElement();
        Browser.document.body.appendChild(canvas);
        var wnd = Browser.window;
        var gl = canvas.getContextWebGL2();
        if (gl == null) {
            trace("Unable to initialize WebGL. Your browser or machine may not support it.");
            return;
        }
        this.gl = gl;
        wnd.addEventListener("resize", onResizeHandler);
        onResizeHandler();
    }

    public function addChild(ch:GLDrawcall) {
        children.push(ch);
    }


    function onResizeHandler() {
        var wnd = Browser.window;
        height = wnd.innerHeight; // wnd.document.documentElement.clientHeight; // wnd.innerWidth;
        canvas.height = height;
        width = wnd.document.documentElement.clientWidth; // wnd.innerWidth;
        canvas.width = width;
        onResize.dispatch(width, height);
        canvas.style.width = width + 'px';
        canvas.style.height = height + 'px';
        gl.viewport(0, 0, width, height);
        render();
    }

    public function render() {
        gl.clearColor(0.0, 0.0, 0.0, 1.);
        gl.clear(GL.COLOR_BUFFER_BIT);
        for (ch in children)
            ch.render(gl);
    }
}
