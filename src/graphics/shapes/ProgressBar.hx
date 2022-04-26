package graphics.shapes;

import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
import data.IndexCollection;
import al.al2d.Axis2D;
import gl.AttribSet;
class ProgressBar <T:AttribSet> implements Shape {
    public var weights:Array<Array<Float>>;
    var transformators:(Axis2D, Float) -> Float;

    public function new(attrs:T, transformators) {
        this.transformators = transformators;
        weights = [];
        weights[0] = RectWeights.weights[horizontal].copy();
        weights[1] = RectWeights.weights[vertical].copy();
    }

    public inline function getIndices():IndexCollection {
        return IndexCollections.QUAD_ODD;
    }

    public function setVal(a, v:Float) {
        var fullWeights = RectWeights.weights[a];
        for (i in 0...fullWeights.length) {
            weights[a][i] = fullWeights[i] * v;
        }
    }

    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset = 0) {
        inline function writeAxis(axis:Axis2D, i) {
            var wg = weights[axis][i];
            writer[axis].setValue(target, vertOffset + i, transformators(axis, wg));
        }
        for (i in 0...4) {
            writeAxis(horizontal, i);
            writeAxis(vertical, i);
        }
    }

    public function getVertsCount():Int {
        return 4;
    }
}
