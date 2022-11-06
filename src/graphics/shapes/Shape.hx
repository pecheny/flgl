package graphics.shapes;
import transform.Transformer;
import data.IndexCollection;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
interface Shape {
    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset:Int = 0, transformer:Transformer):Void;

    public function getIndices():IndexCollection;

    public function getVertsCount():Int;
}
