package gl.passes;
import font.FontStorage;
import ec.Entity;
import gl.GLDisplayObject;
import data.aliases.AttribAliases;
import shaderbuilder.ShaderElement;
import gl.aspects.TextureBinder;
import gl.sets.CMSDFSet;
import shaderbuilder.SnaderBuilder;
import shaderbuilder.MSDFShader;
import gl.sets.MSDFSet;

class CmsdfPass extends FontPass<CMSDFSet> {
    static var smoothShaderEl = new GeneralPassthrough(MSDFSet.NAME_DPI, MSDFShader.smoothness);

    public function new(fui, fonts:FontStorage) {
        super(CMSDFSet.instance, fui, "cmsdf", "text", fonts);

        vertElems.push(ColorPassthroughVert.instance,);
        vertElems.push(Uv0Passthrough.instance,);
        vertElems.push(PosPassthrough.instance,);
        vertElems.push(smoothShaderEl);

        fragElems.push(MSDFFrag.instance);
        fragElems.push(ApplyVertColorFrag.instance);
    }
}
