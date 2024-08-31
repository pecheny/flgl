package gl.passes;

import gl.sets.ColorSet;
import shaderbuilder.SnaderBuilder;

class FlatColorPass extends PassBase<ColorSet> {
    public function new() {
        super(ColorSet.instance, "color", "color");
        vertElems.push(ColorPassthroughVert.instance);
        vertElems.push(PosPassthrough.instance);
        fragElems.push(ColorPassthroughFrag.instance);
    }
}
