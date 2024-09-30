package gl.passes;

import gl.sets.CircleSet;
import shaderbuilder.CircleShader;
import shaderbuilder.SnaderBuilder;

class CirclePass extends PassBase<CircleSet> {
    public function new() {
        super(CircleSet.instance, "circle", "circle");
        vertElems.push(Uv0Passthrough.instance,);
        vertElems.push(PosPassthrough.instance,);
        vertElems.push(new GeneralPassthrough(CircleSet.R1_IN, CircleSet.R1_OUT));
        vertElems.push(new GeneralPassthrough(CircleSet.R2_IN, CircleSet.R2_OUT));

        fragElems.push(CircleShader.instance);
    }
}
