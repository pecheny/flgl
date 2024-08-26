import Axis2D;
import bindings.GLProgram;
import bindings.WebGLRenderContext;
import data.aliases.AttribAliases;
import flgl.WebGlRenderer;
import gl.GLDisplayObject;
import gl.sets.ColorSet;
import graphics.ShapeRenderer;
import graphics.shapes.Bar;
import a2d.AspectRatioProvider;
import a2d.transform.LineThicknessCalculator;
import a2d.transform.Resizable;
import a2d.transform.LiquidTransformer;

using macros.AVConstructor;

class BarGraphics {
    static function main() {
        var root = new WebGlRenderer();
        var resizer = new StageResizer();
        root.onResize.listen(resizer.resize);
        resizer.resize(root.width, root.height);

        var gldo = new GLDisplayObject(ColorSet.instance, create, null);
        var shapes = new ShapeRenderer(ColorSet.instance);
        createShapes(resizer, shapes);
        shapes.initChildren();
        var liquidTr = new LiquidTransformer(resizer.getAspectRatio());
        // liquidTr.setBounds(0.5, 0.5, 1, 1);
        liquidTr.setBounds(0,0, 0.5, 0.5);
        resizer.addResizable(liquidTr);
        shapes.transform = liquidTr.transformValue;
        // var propTr = new ProportionalTransformer(resizer.getAspectRatio());
        // propTr.setBounds(-0.5,-0.5, 1,1);
        // resizer.addResizable(propTr);
        // shapes.transform = propTr.transformValue;
        fillColor(shapes);
        gldo.addView(shapes);
        root.addChild(gldo);
        root.render();
    }

    static function createShapes(root:StageResizer, shapes) {
        var lineCalc = new LineThicknessCalculator(root.getAspectRatio());
        root.addResizable(lineCalc);
        var bb = new BarsBuilder(root.getAspectRatio(), lineCalc.lineScales());
        var elements = [
            new BarContainer(FixedThikness(new BarAxisSlot({pos: 1., thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot({pos: 0., thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
            new BarContainer(Portion(new BarAxisSlot({start: 0., end: 1.}, null)), FixedThikness(new BarAxisSlot({pos: 0., thikness: 1.}, null))),
            new BarContainer(Portion(new BarAxisSlot({start: 0., end: 1.}, null)), FixedThikness(new BarAxisSlot({pos: 1., thikness: 1.}, null))),
        ];
        var attrs = ColorSet.instance;
        for (e in elements) {
            var sh = bb.create(attrs, e);
            shapes.addChild(sh);
        }
    }

    static function fillColor(shapes) {
        var cw = ColorSet.instance.getWriter(AttribAliases.NAME_COLOR_IN);
        for (i in 0...shapes.getVertCount()) {
            cw[0].setValue(shapes.buffer, i, 255);
            cw[1].setValue(shapes.buffer, i, 255);
            cw[2].setValue(shapes.buffer, i, 0);
            cw[3].setValue(shapes.buffer, i, 255);
        }
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

class StageResizer implements AspectRatioProvider {
    var base:Float = 1;

    var resizables:Array<Resizable> = [];

    public var aspects = AVConstructor.create(Axis2D, 1., 1.);
    public var size = AVConstructor.create(Axis2D, 1, 1);
    public var pos = AVConstructor.create(Axis2D, 0., 0.);

    public function new() {}

    public function resize(w, h) {
        updateAspectRatio(w, h);
        resizeChildren(w, h);
    }

    function updateAspectRatio(width, height) {
        size[horizontal] = width;
        size[vertical] = height;
        if (width > height) {
            aspects[horizontal] = (base * width / height);
            aspects[vertical] = base;
        } else {
            aspects[horizontal] = base;
            aspects[vertical] = (base * height / width);
        }
    }

    function resizeChildren(width, height) {
        if (width > height) {
            var w = base * width / height;
            for (r in resizables)
                r.resize(w, base);
        } else {
            var h = base * height / width;
            for (r in resizables)
                r.resize(base, h);
        }
    }

    function resizeChild(r, width, height) {
        if (width > height) {
            var w = base * width / height;
            r.resize(w, base);
        } else {
            var h = base * height / width;
            r.resize(base, h);
        }
    }

    public function addResizable(r) {
        resizables.push(r);
        resizeChild(r, size[horizontal], size[vertical]);
    }

    public inline function getFactor(cmp:Axis2D):Float {
        return aspects[cmp];
    }

    public function getAspectRatio():ReadOnlyAVector2D<Float> {
        return aspects;
    }

    public function getWindowSize():ReadOnlyAVector2D<Int> {
        return size;
    }

    public function getValue(a:Axis2D):Float {
        return if (a == horizontal) size[horizontal] else size[vertical];
    }
}
