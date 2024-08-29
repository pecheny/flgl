package gl.passes;
import gl.aspects.RenderingAspect.RenderAspectBuilder;
import ec.Entity;
import gl.aspects.TextureBinder;
import gl.sets.TexSet;
import shaderbuilder.SnaderBuilder;
import shaderbuilder.TextureFragment;

class ImagePass extends PassBase<TexSet> {

    public function new(fui) {
        super(TexSet.instance, fui, "texture", "image");
        vertElems.push(Uv0Passthrough.instance,);
        vertElems.push(PosPassthrough.instance,);

        fragElems.push(TextureFragment.get(0, 0));
    }

    override function createGldo(e:Entity, xml:Xml, aspects:RenderAspectBuilder) {
        if (!xml.exists("path"))
            throw '<image /> gldo should have path property';
        // todo image name to gldo
        trace( xml.get("path" ));
        return fui.createGldo(TexSet.instance, e, "texture", new TextureBinder(fui.textureStorage, xml.get("path")), "");
    }
}
