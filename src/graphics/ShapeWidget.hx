package graphics;
import al.al2d.Widget2D;
import crosstarget.Widgetable;
import data.aliases.AttribAliases;
import data.IndexCollection;
import ec.CtxWatcher;
import gl.AttribSet;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.Renderable;
import gl.RenderTargets;
import gl.ValueWriter.AttributeWriters;
import graphics.shapes.Shape;
import haxe.io.Bytes;
import transform.AspectRatioProvider;
import transform.LiquidTransformer;

class ShapeWidget<T:AttribSet> extends Widgetable implements Renderable<T> {

    var attrs:T;
    var inited = false;
    var shapeRenderer:ShapeRenderer<T>;

    public function new(attrs:T, w:Widget2D) {
        this.attrs = attrs;
        super(w);
        shapeRenderer = new ShapeRenderer(attrs);
        var drawcallsData = DrawcallDataProvider.get(attrs, w.entity);
        drawcallsData.views.push(this);
        new CtxWatcher(Drawcalls, w.entity);
    }

    public function addChild(shape:Shape) {
        if (inited) throw "Can't add children after initialization";
        shapeRenderer.addChild(shape);
    }

    @:once var ratioProvider:AspectRatioProvider;
    @:once var transformer:LiquidTransformer;

    override function init() {
        createShapes();
        shapeRenderer.initChildren();
        inited = true;
        onShapesDone();
    }

    function createShapes() {}

    function onShapesDone() {}


    public function render(targets:RenderTargets<T>):Void {
        shapeRenderer.render(targets);
    }

//    function printVerts(n) {
//        for (i in 0...n)
//            trace(i + " " + attrs.printVertex(buffer, i));
//    }
}
