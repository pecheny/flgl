package graphics;
import gl.AttribSet;
import haxe.io.Bytes;
import utils.Signal;
interface ShapesBuffer<T:AttribSet> {
    function getVertCount():Int;

    function getBuffer():Bytes;

    function isInited():Bool;

    var onInit(default, null):Signal<Void -> Void>;
}
