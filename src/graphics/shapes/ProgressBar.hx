package graphics.shapes;

import data.aliases.AttribAliases;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
import data.IndexCollection;
import Axis2D;
import gl.AttribSet;
class ProgressBar <T:AttribSet> implements Shape {
    public var weights:Array<Array<Float>>;
    var writers:AttributeWriters;

    public function new(attrs:T) {
        weights = [];
        weights[0] = RectWeights.weights[horizontal].copy();
        weights[1] = RectWeights.weights[vertical].copy();
        writers = attrs.getWriter(AttribAliases.NAME_POSITION) ;
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

    public function writePostions(target:Bytes,  vertOffset = 0, t) {
        inline function writeAxis(axis:Axis2D, i) {
            var wg = weights[axis][i];
            writers[axis].setValue(target, vertOffset + i, t(axis, wg));
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
