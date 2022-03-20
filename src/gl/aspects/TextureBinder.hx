package gl.aspects;
import gl.GLDisplayObject.GLState;
import FuiBuilder.TextureStorage;
import bindings.GLTexture;
import bindings.WebGLRenderContext;
class TextureBinder implements RenderingAspect {
    var storage:TextureStorage;
    var path:String;
    var texture:GLTexture;
    var inited = false;

    public function new(st, path) {
        this.storage = st;
        this.path = path;
    }

    public function bind(state:GLState<Dynamic>):Void {
        var gl = state.gl;
        init(gl);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    }

    public function unbind(state:GLState<Dynamic>):Void {
        var gl = state.gl;
        gl.bindTexture(gl.TEXTURE_2D, null);
    }

    inline function init(gl:WebGLRenderContext):Void {
        if (!inited) {
            texture = storage.get(gl, path);
        }
    }
}
