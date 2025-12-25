package graphics.shapes;
import data.aliases.AttribAliases;
import haxe.ds.ReadOnlyArray;
import macros.AVConstructor;
import Axis2D;
import data.IndexCollection;
import gl.AttribSet;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
class QuadGraphicElement<T:AttribSet> implements Shape {
    public var weights:AVector2D<Array<Float>>;
    var writers:AttributeWriters;

    public function new(attrs:T) {
        weights = RectWeights.identity();
        // var writers:AttributeWriters;
        writers = attrs.getWriter(AttribAliases.NAME_POSITION) ;
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

    public function writePostions(target:Bytes,  vertOffset = 0, transformer) {
        writeQuadPostions(target, writers, vertOffset , transformer, weights);
        writeAttributes(target, vertOffset, transformer);
    }

    public dynamic function writeAttributes(target:Bytes,  vertOffset = 0, transformer) {
        
    }

    public function getVertsCount():Int {
        return 4;
    }
    public function initInBuffer(target:Bytes, vertOffset:Int):Void {}

}
