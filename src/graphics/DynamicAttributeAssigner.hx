package graphics;
import mesh.MeshUtilss;
import gl.AttribSet;
import mesh.providers.AttrProviders.SolidColorProvider;
import data.aliases.AttribAliases;
import graphics.ShapesBuffer;
class DynamicAttributeAssigner<T:AttribSet> {
    var attrs:T;
    var buffer:ShapesBuffer<T>;

    public function new(attrs, buffer):Void {
        this.attrs = attrs;
        this.buffer = buffer;
        this.buffer.onInit.listen(_fillBuffer);
    }

    function _fillBuffer() {
        if (!buffer.isInited())
            return;
        fillBuffer(attrs, buffer);
    }

    dynamic public function fillBuffer(attrs, buffer) {
    }
}
