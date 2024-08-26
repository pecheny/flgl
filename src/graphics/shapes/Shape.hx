package graphics.shapes;
import data.IndexCollection;
import haxe.io.Bytes;

typedef Transformer = (c:Axis2D, input:Float) -> Float;

interface Shape {
    public function writePostions(target:Bytes,  vertOffset:Int = 0, transformer:Transformer):Void;

    public function getIndices():IndexCollection;

    public function getVertsCount():Int;
}
