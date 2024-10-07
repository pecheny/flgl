package graphics;

import gl.AttribSet;
import graphics.ShapesBuffer;
import graphics.shapes.Shape;
import haxe.ds.ReadOnlyArray;

/**
    Utilirt class for managing shape colors: get individual setColor() function for each shape,
    assign color for shape even before the buffer initialization.
**/
class ShapeColors<T:AttribSet> {
    var shapeRenderer:ShapesBuffer<T>;
    var colorer:PerShapeColorAssigner<T>;
    var colors:Map<Int, Int> = new Map();
    var defaultColor:Int;
    var numChildren = 0;

    public function new(att:T, shapeRenderer, color = 0) {
        colorer = new PerShapeColorAssigner(att);
        this.shapeRenderer = shapeRenderer;
        defaultColor = color;
    }

    public function resetColors() {
        colors = new Map();
    }

    public function initChildren(children:ReadOnlyArray<Shape>) {
        colorer.initChildren(children);
        numChildren = children.length;
        if (shapeRenderer.isInited())
            colorizeAll();
        else
            shapeRenderer.onInit.listen(colorizeAll);
    }

    public function getColorizeFun(shapeId) {
        if (!shapeRenderer.isInited())
            return (color) -> {
                if (shapeRenderer.isInited())
                    colorer.colorize(shapeRenderer.getBuffer(), shapeId, color);
            }
        else
            return colorer.colorize.bind(shapeRenderer.getBuffer(), shapeId);
    }

    function colorizeAll() {
        shapeRenderer.onInit.remove(colorizeAll);
        for (i in 0...numChildren)
            colorer.colorize(shapeRenderer.getBuffer(), i, colors[i] ?? defaultColor);
    }

    public function colorize(shapeId, color:Int) {
        colors[shapeId] = color;
        if (shapeRenderer.isInited())
            colorer.colorize(shapeRenderer.getBuffer(), shapeId, color);
    }
}

/**
    Wrapper for writting color attribute for each shape individually according to given shapes array.
**/
class PerShapeColorAssigner<T:AttribSet> {
    var shapes:ReadOnlyArray<Shape> = [];
    var positions:Array<Int> = [];
    var currentPos = 0;
    var att:T;

    public function new(att:T) {
        this.att = att;
    }

    public function initChildren(children) {
        currentPos = 0;
        positions = [];
        shapes = children;
        for (shape in shapes) {
            positions.push(currentPos);
            currentPos += shape.getVertsCount();
        }
    }

    public function colorize(buffer, shapeId, color:Int) {
        att.writeColor(buffer, color, positions[shapeId], shapes[shapeId].getVertsCount());
    }
}
