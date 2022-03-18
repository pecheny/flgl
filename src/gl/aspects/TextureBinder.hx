package gl.aspects;
import FuiBuilder.TextureStorage;
import bindings.GLTexture;
import bindings.mock.WebGLRenderContext;
class TextureBinder implements RenderingAspect {
    var storage:TextureStorage;
    var path:String;
    var texture:GLTexture;
    var inited = false;

    public function new(st, path) {
        this.storage = st;
        this.path = path;
    }

    public function bind(gl:WebGLRenderContext):Void {
        init(gl);
        gl.bindTexture(gl.TEXTURE_2D, texture);
    }

    public function unbind(gl:WebGLRenderContext):Void {
        gl.bindTexture(gl.TEXTURE_2D, null);
    }

    function setProps(gl:WebGLRenderContext) {
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    }

    inline function init(gl:WebGLRenderContext):Void {
        if (!inited) {
            texture = storage.get(gl, path);
        }
    }


}
