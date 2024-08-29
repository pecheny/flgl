package gl.passes;
import gl.aspects.RenderingAspect;
import ec.Entity;
import font.FontStorage;
import gl.AttribSet;
import gl.aspects.RenderingAspect.RenderAspectBuilder;
import gl.aspects.TextureBinder;
import gl.sets.MSDFSet;
import shaderbuilder.MSDFShader;
import shaderbuilder.SnaderBuilder;

class FontPass<TAtt:AttribSet>extends PassBase<TAtt> {
    static var smoothShaderEl = new GeneralPassthrough(MSDFSet.NAME_DPI, MSDFShader.smoothness);
    var fonts:FontStorage;
    var textureExtractor:Xml->RenderingAspect;

    public function new(att:TAtt, fui, shadertype, drawcalltype, fonts:FontStorage) {
        this.fonts = fonts;
        super(att, fui, shadertype, drawcalltype);
    }

    override function createGldo(e:Entity, xml:Xml, aspects:RenderAspectBuilder) {
        var fontName = xml.get("font");
        var font = fonts.getFont(fontName);
        if (font == null)
            throw 'there is no font $fontName';
        return fui.createGldo(attr, e, shaderType, new TextureBinder(fui.textureStorage, font.texturePath), font.getId());
    }
    
}
