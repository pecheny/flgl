package graphics.shapes;
import haxe.ds.ReadOnlyArray;
import macros.AVConstructor;
import Axis2D;
import data.IndexCollection;
import gl.AttribSet;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
class QuadGraphicElement<T:AttribSet> implements Shape {
    public var weights:AVector2D<Array<Float>>;

    public function new(attrs:T) {
        weights = AVConstructor.create(RectWeights.weights[horizontal].copy(), RectWeights.weights[vertical].copy());
    }

    public inline function getIndices():IndexCollection {
        return IndexCollections.QUAD_ODD;
    }

    public static inline function writeQuadPostions(target:Bytes, writer:AttributeWriters, vertOffset = 0, transformer, weights:ReadOnlyAVector2D<ReadOnlyArray<Float>> = null) {
        weights = weights ?? RectWeights.weights;
        inline function writeAxis(axis:Axis2D, i) {
            var wg = weights[axis][i];
            writer[axis].setValue(target, vertOffset + i, transformer(axis, wg));
        }
        for (i in 0...4) {
            writeAxis(horizontal, i);
            writeAxis(vertical, i);
        }
    }

    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset = 0, transformer) {
        writeQuadPostions(target, writer, vertOffset , transformer, weights);
    }

    public function getVertsCount():Int {
        return 4;
    }
}
