import bindings.GLProgram;
import bindings.WebGLRenderContext;
import data.aliases.AttribAliases;
import flgl.WebGlRenderer;
import gl.GLDisplayObject;
import gl.sets.ColorSet;
import graphics.ShapeRenderer;
import graphics.shapes.QuadGraphicElement;

using macros.AVConstructor;

class Shapes {
    static function main() {
        var root = new WebGlRenderer();
        var gldo = new GLDisplayObject(ColorSet.instance, create, null);
        var shapes = new ShapeRenderer(ColorSet.instance);
        shapes.addChild(new QuadGraphicElement(ColorSet.instance));
        shapes.initChildren();
        var cw = ColorSet.instance.getWriter(AttribAliases.NAME_COLOR_IN);
        for (i in 0...shapes.getVertCount()) {
            cw[0].setValue(shapes.buffer, i, 1);
            cw[1].setValue(shapes.buffer, i, 1);
            cw[2].setValue(shapes.buffer, i, 1);
            cw[3].setValue(shapes.buffer, i, 1);
        }

        gldo.addView(shapes);
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