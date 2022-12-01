package utils;
import bindings.GLTexture;
import bindings.WebGLRenderContext;
class TextureStorage {
    var locations:Map<String, GLTexture> = new Map();

    public function new() {}

    public function get(gl:WebGLRenderContext, filename:String) {
        if (locations.exists(filename)) return locations.get(filename);
        var tex = gl.createTexture();
        var image = lime.utils.Assets.getImage(filename);
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.buffer.width, image.buffer.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
        gl.bindTexture(gl.TEXTURE_2D, null);
        locations[filename] = tex;
        return tex;
    }
}
