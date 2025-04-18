package gl.passes;
import shaderbuilder.FragColorElement;
import gl.sets.CMSDFSet;
import gl.sets.MSDFSet;
import shaderbuilder.MSDFShader;
import shaderbuilder.SnaderBuilder;

class CmsdfPass extends PassBase<CMSDFSet> {
    static var smoothShaderEl = new GeneralPassthrough(MSDFSet.NAME_DPI, MSDFShader.smoothness);

    public function new() {
        super(CMSDFSet.instance, "cmsdf", "text");

        vertElems.push(ColorPassthroughVert.instance,);
        vertElems.push(Uv0Passthrough.instance,);
        vertElems.push(PosPassthrough.instance,);
        vertElems.push(smoothShaderEl);

        fragElems.push(FragColorAssignVertColor.instance);
        fragElems.push(MSDFFrag.instance);
        fragElems.push(FragColorElement.instance);
    }
}
