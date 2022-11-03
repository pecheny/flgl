package flgl;

import js.Browser;
import js.html.CanvasElement;
import bindings.WebGLRenderContext;
import bindings.GLDrawcall;
import bindings.GL;
import Axis2D;
class WebGlRenderer {
    var gl:WebGLRenderContext;
    var canvas:CanvasElement;
    var children:Array<GLDrawcall> = [];

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
        wnd.addEventListener("resize", onResize);
        onResize();
    }

    public function addChild(ch:GLDrawcall) {
        children.push(ch);
    }

    function onResize() {
        var wnd = Browser.window;
        var height = wnd.innerHeight; // wnd.document.documentElement.clientHeight; // wnd.innerWidth;
        canvas.height = height;
        var width = wnd.document.documentElement.clientWidth; // wnd.innerWidth;
        canvas.width = width;
        canvas.style.width = width + 'px';
        canvas.style.height = height + 'px';
        gl.viewport(0, 0, width, height);
        render();
    }

    public function render() {
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        gl.clear(GL.COLOR_BUFFER_BIT);
        for (ch in children)
            ch.render(gl);
    }
}