package graphics;
import mesh.MeshUtilss;
import gl.AttribSet;
import mesh.providers.AttrProviders.SolidColorProvider;
import data.aliases.AttribAliases;
import graphics.ShapesBuffer;
class ShapesColorAssigner<T:AttribSet> {
    var attrs:T;
    var cp:SolidColorProvider;
    var buffer:ShapesBuffer<T>;
    var color:Int = -1;


    public function new(attrs, color, buffer):Void {
        this.attrs = attrs;
        this.buffer = buffer;
        cp = new SolidColorProvider(0,0,0);
        setColor(color);
        this.buffer.onInit.listen(fillBuffer);
    }

    function fillBuffer() {
        if (!buffer.isInited())
            return;
        MeshUtilss.writeInt8Attribute(attrs, buffer.getBuffer(), AttribAliases.NAME_COLOR_IN, 0, buffer.getVertCount(), cp.getValue);
    }

    public function setColor(c:Int) {
        if (color == c)
            return;
        cp.setColor(c);
        fillBuffer();
        color = c;
    }
}
