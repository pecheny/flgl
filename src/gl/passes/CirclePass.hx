package gl.passes;

import data.aliases.AttribAliases;
import shaderbuilder.FragColorElement;
import gl.sets.CircleSet;
import shaderbuilder.CircleShader;
import shaderbuilder.SnaderBuilder;

class CirclePass extends PassBase<CircleSet> {
    public function new() {
        super(CircleSet.instance, "circle", "circle");
        vertElems.push(Uv0Passthrough.instance);
        vertElems.push(PosPassthrough.instance);
        vertElems.push(new GeneralPassthrough(CircleSet.R1_IN, CircleSet.R1_OUT));
        vertElems.push(new GeneralPassthrough(CircleSet.R2_IN, CircleSet.R2_OUT));
        vertElems.push(new GeneralPassthrough(AttribAliases.AASIZE_IN, AttribAliases.AASIZE));
        vertElems.push(ColorPassthroughVert.instance);

        fragElems.push(FragColorAssignVertColor.instance);
        fragElems.push(CircleShader.instance);
        fragElems.push(FragColorElement.instance);
    }
}
