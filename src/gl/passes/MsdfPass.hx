package gl.passes;
import ec.Entity;
import gl.GLDisplayObject;
import data.aliases.AttribAliases;
import shaderbuilder.ShaderElement;
import gl.aspects.TextureBinder;
import shaderbuilder.SnaderBuilder;
import shaderbuilder.MSDFShader;
import gl.sets.MSDFSet;

class MsdfPass extends FontPass<MSDFSet> {
    static var smoothShaderEl = new GeneralPassthrough(MSDFSet.NAME_DPI, MSDFShader.smoothness);

    public function new(fui, fonts) {
        super(MSDFSet.instance, fui, "msdf", "text", fonts);
        vertElems.push(ColorPassthroughVert.instance,);
        vertElems.push(Uv0Passthrough.instance,);
        vertElems.push(PosPassthrough.instance,);
        vertElems.push(smoothShaderEl);

        fragElems.push(MSDFFrag.instance);
        fragElems.push(ApplyVertColorFrag.instance);
    }
}
