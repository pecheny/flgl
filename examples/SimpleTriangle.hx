import flgl.WebGlRenderer;
import Axis2D;
import bindings.GLProgram;
import bindings.WebGLRenderContext;
import gl.GLDisplayObject;
import data.IndexCollection;
import data.aliases.AttribAliases;
import gl.AttribSet;
import gl.RenderTargets;
import gl.Renderable;
import gl.sets.ColorSet;
import haxe.io.Bytes;

using macros.AVConstructor;

class SimpleTriangle {
    static function main() {
        var root = new WebGlRenderer();
        var gldo = new GLDisplayObject(ColorSet.instance, create, null);
        gldo.addView(new Triangle(ColorSet.instance));
        root.addChild(gldo);
        root.render();
    }

    static function create(gl:WebGLRenderContext) {
        var program = GLProgram.fromSources(gl, '
        attribute vec2 ${AttribAliases.NAME_POSITION};
        attribute vec4 ${AttribAliases.NAME_COLOR_IN};
        varying vec4 ${AttribAliases.NAME_COLOR_OUT};
        void main(){
           ${AttribAliases.NAME_COLOR_OUT} = ${AttribAliases.NAME_COLOR_IN};
            gl_Position =  vec4(${AttribAliases.NAME_POSITION}.x, ${AttribAliases.NAME_POSITION}.y,  0, 1);
        }
    ', #if (!desktop
                || rpi) "precision mediump float;"
            + #else #end '
        varying vec4 ${AttribAliases.NAME_COLOR_OUT};
        void main(){
           gl_FragColor = ${AttribAliases.NAME_COLOR_OUT};
        }
    ');
        var state = new GLState(ColorSet.instance);
        state.init(gl, program, null);
        return state;
    }
}

class Triangle<T:AttribSet> implements Renderable<T> {
    static var inds:IndexCollection;

    var buffer:Bytes;
    var vertsCount = 3;

    public function new(attrs:T) {
        inds = new IndexCollection(3);
        inds[0] = 0;
        inds[1] = 1;
        inds[2] = 2;
        buffer = Bytes.alloc(vertsCount * attrs.stride);
        var posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
        var setX = posWriter[horizontal].setValue.bind(buffer);
        var setY = posWriter[vertical].setValue.bind(buffer);
        setX(0, -0.5);
        setY(0, -0.5);
        setX(1, 0.5);
        setY(1, -0.5);
        setX(2, 0);
        setY(2, 0.5);
        var colorWriter = attrs.getWriter(AttribAliases.NAME_COLOR_IN);
        for (i in 0...vertsCount) {
            colorWriter[0].setValue(buffer, i, 1);
            colorWriter[1].setValue(buffer, i, 1);
            colorWriter[2].setValue(buffer, i, 1);
            colorWriter[3].setValue(buffer, i, 1);
        }
    }

    public function render(targets:RenderTargets<T>):Void {
        targets.blitIndices(inds, inds.length);
        targets.blitVerts(buffer, vertsCount);
    }
}
