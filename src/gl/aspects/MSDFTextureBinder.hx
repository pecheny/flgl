package gl.aspects;
import bindings.GLTexture;
import bindings.WebGLRenderContext;
import gl.aspects.RenderingAspect;
import lime.graphics.Image;

class MSDFTextureBinder implements RenderingAspect {
    var texture:GLTexture;
    var image:Image;
    var inited:Bool;

    public function new(image) {
        this.image = image;
    }

    public function bind(gl:WebGLRenderContext):Void {
        createTexture(gl);
        gl.bindTexture(gl.TEXTURE_2D, texture);
    }

    public function unbind(gl:WebGLRenderContext):Void {
        gl.bindTexture(gl.TEXTURE_2D, null);
    }


    var gl:WebGLRenderContext;

    private inline function createTexture(gl:WebGLRenderContext):Void {
        if (!inited) {
            texture = gl.createTexture();

            gl.bindTexture(gl.TEXTURE_2D, texture);
            gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 0);
            gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 0);
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.buffer.width, image.buffer.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
            gl.generateMipmap(gl.TEXTURE_2D);
            gl.bindTexture(gl.TEXTURE_2D, null);
            inited = true;
        }
    }
}
