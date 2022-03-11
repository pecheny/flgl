package gl;
import bindings.GLProgram;
import shaderbuilder.SnaderBuilder.ShaderBase;
import bindings.WebGLRenderContext;
import gl.GLDisplayObject.GLState;
import shaderbuilder.MSDFShader.MSDFFrag;
import shaderbuilder.MSDFShader.LogisticSmoothnessCalculator;
import gl.sets.MSDFSet;
import shaderbuilder.TextureFragment;
import shaderbuilder.SnaderBuilder.Uv0Passthrough;
import gl.sets.TexSet;
import shaderbuilder.SnaderBuilder.ColorPassthroughFrag;
import shaderbuilder.SnaderBuilder.PosPassthrough;
import shaderbuilder.SnaderBuilder.ColorPassthroughVert;
import gl.sets.ColorSet;
import bindings.GLUniformLocation;
import data.DataType;
import shaderbuilder.ShaderElement;
typedef ShaderDescr<T:AttribSet> = {
        type:String,
        vert:Array<ShaderElement>,
        frag:Array<ShaderElement>,
        attrs:T,
        ?uniforms:Map<String, DataType>
}

typedef UniformState = {
    var name:String;
    var type:DataType;
    var location:GLUniformLocation;
}

class ShaderRegistry {
    var descrColor = {
        type:"color",
        attrs:ColorSet.instance,
        vert:[ColorPassthroughVert.instance, PosPassthrough.instance],
        frag:[cast ColorPassthroughFrag.instance]
    }
    var descrImage = {
        type:"texture",
        attrs:TexSet.instance,
        vert:[Uv0Passthrough.instance, PosPassthrough.instance],
        frag:[cast TextureFragment.get(0, 0)] // todo check
    }
    var descrMsdf = {
        type:"msdf",
        attrs:MSDFSet.instance,
        vert:[Uv0Passthrough.instance, PosPassthrough.instance, LogisticSmoothnessCalculator.instance],
        frag:[cast MSDFFrag.instance]
    }
    var descrs = new Map<String, ShaderDescr<Dynamic>>();
    var shaders:Map<String, GLState<Dynamic>> = new Map();

    public function new() {
        reg(descrColor);
        reg(descrImage);
        reg(descrMsdf);
    }

    public function getDescr(name):ShaderDescr<Dynamic> {
        return descrs[name];
    }

    public function getState(gl, name) {
        if (shaders.exists(name)) return shaders[name];
        return create(gl, name);
    }

    public function reg(descr:ShaderDescr<Dynamic>) {
        descrs[descr.type] = descr;
    }
//
    function create(gl:WebGLRenderContext, name) {
        var descr = descrs[name];
        if (descr == null)
            throw 'Shader $name is not registered';
        var factory = new ShaderBase(descr.vert, descr.frag);
        var err = null;
        var program:GLProgram = null;
        try {
            program = factory.create(gl);
        } catch (e:Dynamic) {
            err = "" + e ;
        }
        if (err != null) {
            trace(err);
            return null;
        }
        var state = new GLState(descr.attrs);
        shaders[name] = state;
        state.init(gl, program, descr.uniforms);
        return state;
    }
}
