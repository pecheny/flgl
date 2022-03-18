package gl;
import bindings.GLProgram;
import bindings.GLUniformLocation;
import bindings.WebGLRenderContext;
import data.DataType;
import gl.GLDisplayObject.GLState;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder.ShaderBase;
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
interface IShaderRegistry {
    function getState(gl:WebGLRenderContext, name:String):GLState<Dynamic>;

    function getAttributeSet(name:String):AttribSet;
}

class ShaderRegistry implements IShaderRegistry {

    var descrs = new Map<String, ShaderDescr<Dynamic>>();
    var shaders:Map<String, GLState<Dynamic>> = new Map();

    public function new() {
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

    public function getAttributeSet(name:String):AttribSet {
        trace(name);
        return getDescr(name).attrs;
    }

}
