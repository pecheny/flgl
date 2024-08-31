package gl.passes;

import flgl.ProjPosElement;
import Aliases.AA;
import gl.aspects.RenderingAspect;
import flgl.ProjMatAspect;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder;
import gl.sets.ColorSet;

class FlatColorPass extends PassBase<ColorSet> {
    public function new(fui) {
        super(ColorSet.instance, fui, "color", "color");
        vertElems.push(ColorPassthroughVert.instance);
        vertElems.push(PosPassthrough.instance);
        fragElems.push(ColorPassthroughFrag.instance);
    }
}
