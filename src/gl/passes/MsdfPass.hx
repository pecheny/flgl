package gl.passes;
import gl.sets.MSDFSet;
import shaderbuilder.MSDFShader;
import shaderbuilder.SnaderBuilder;

class MsdfPass extends PassBase<MSDFSet> {
    static var smoothShaderEl = new GeneralPassthrough(MSDFSet.NAME_DPI, MSDFShader.smoothness);

    public function new(fui) {
        super(MSDFSet.instance, fui, "msdf", "text");
        vertElems.push(ColorPassthroughVert.instance,);
        vertElems.push(Uv0Passthrough.instance,);
        vertElems.push(PosPassthrough.instance,);
        vertElems.push(smoothShaderEl);

        fragElems.push(MSDFFrag.instance);
        fragElems.push(ApplyVertColorFrag.instance);
    }
}
