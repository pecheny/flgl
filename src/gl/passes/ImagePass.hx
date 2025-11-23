package gl.passes;
import gl.sets.TexSet;
import shaderbuilder.SnaderBuilder;
import shaderbuilder.TextureFragment;

class ImagePass extends PassBase<TexSet> {

    public function new() {
        super(TexSet.instance, "texture");
        vertElems.push(Uv0Passthrough.instance,);
        vertElems.push(PosPassthrough.instance,);

        fragElems.push(TextureFragment.get(0, 0));
    }
}
