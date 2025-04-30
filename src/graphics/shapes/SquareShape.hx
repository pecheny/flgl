package graphics.shapes;

import Axis2D;
import data.IndexCollection;
import data.aliases.AttribAliases;
import gl.AttribSet;
import gl.ValueWriter;
import gl.sets.CircleSet;
import graphics.shapes.Shape;
import graphics.shapes.SquareShape;
import haxe.ds.ReadOnlyArray;
import haxe.io.Bytes;
import macros.AVConstructor;

class SquareShape<T:AttribSet> implements Shape {
    var pos:AVector2D<Float>;
    var writers:AttributeWriters;
    var size:Float;
    var lineScales:ReadOnlyAVector2D<Float>;

    static var weights:ReadOnlyAVector2D<ReadOnlyArray<Float>> = AVConstructor.create([-0.5, -0.5, 0.5, 0.5], [-0.5, 0.5, -0.5, 0.5]);

    public function new(attrs:T, lineScales, x, y, size = 1) {
        this.size = size;
        this.lineScales = lineScales;
        this.pos = AVConstructor.create(x, y);
        this.writers = attrs.getWriter(AttribAliases.NAME_POSITION);
    }

    public inline function getIndices():IndexCollection {
        return IndexCollections.QUAD_ODD;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        inline function writeAxis(axis:Axis2D, i) {
            var vpos = pos[axis] + weights[axis][i] * size * lineScales[axis];
            writers[axis].setValue(target, vertOffset + i, transformer(axis, vpos));
        }
        for (i in 0...4) {
            writeAxis(horizontal, i);
            writeAxis(vertical, i);
        }

        writeAttributes(target, vertOffset, transformer);
    }

    function writeAttributes(target:Bytes, vertOffset = 0, transformer) {
        for (a in moreAttribs)
            a(target, vertOffset, transformer);
    }

    var moreAttribs:Array<(Bytes, Int, Transformer) -> Void> = [];

    public function withAtt(a) {
        moreAttribs.push(a);
        return this;
    }

    public function getVertsCount():Int {
        return 4;
    }
}

@:access(graphics.shapes.SquareShape)
class SquareAntialiasing<T:AttribSet> {
    var att:T;
    var square:SquareShape<T>;
    var screenSize:ReadOnlyAVector2D<Int>;
    var smoothness = 6.;

    public function new(att, square, screen) {
        this.att = att;
        this.square = square;
        this.screenSize = screen;
    }

    public function writePostions(target:Bytes, vertOffset = 0, _) {
        var aasize = smoothness / (square.size * square.lineScales[horizontal] * screenSize[horizontal]);
        att.fillFloat(target, AttribAliases.AASIZE_IN, aasize, vertOffset, 4);
    }
}
