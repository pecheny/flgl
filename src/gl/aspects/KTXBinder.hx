package gl.aspects;
import StringTools;
import bindings.GLProgram;
import bindings.GLTexture;
import bindings.WebGLRenderContext;
import data.aliases.UniformAliases;
import haxe.io.Bytes;
import haxe.io.Int32Array;
import haxe.io.UInt32Array;
import lime.utils.UInt8Array;
import oglrenderer.GLLayer.RenderingElement;
class KTXBinder implements RenderingAspect {
    var texture:GLTexture;
    var inited:Bool;
    var ktx:KhronosTextureContainer;
    inline static var GL_EXTENSIONS = 0x1F03;

    public function new(bytes, faces = 1) {
        ktx = new KhronosTextureContainer(bytes, faces);

    }

    public function bind():Void {
        gl.bindTexture(gl.TEXTURE_2D, texture);
    }

    public function unbind():Void {
        gl.bindTexture(gl.TEXTURE_2D, null);
    }

    public function init(gl:WebGLRenderContext, program:GLProgram):Void {
        this.gl = gl;
        var exs = gl.getSupportedExtensions();
        trace(gl.getExtension('WEBGL_compressed_texture_etc'));
        createTexture(gl, program);
    }

    var gl:WebGLRenderContext;

    @:access(lime.utils.ArrayBufferView)
    private function createTexture(gl:WebGLRenderContext, program):Void {
        var imageUniform = gl.getUniformLocation(program, UniformAliases.IMG_0);
        gl.uniform1i(imageUniform, 0);
        if (inited)
            return;
        texture = gl.createTexture();
        var ui8a = ktx.mipmaps(false)[0].data;
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.compressedTexImage2D(gl.TEXTURE_2D, 0, ktx.glInternalFormat, ktx.pixelWidth, ktx.pixelHeight, 0, ui8a);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
        gl.generateMipmap(gl.TEXTURE_2D);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.bindTexture(gl.TEXTURE_2D, null);
        inited = true;
    }
}

// Ported version of three.js version https://github.com/mrdoob/three.js/blob/master/examples/jsm/loaders/KTX2Loader.js
class KhronosTextureContainer {
    public static inline var HEADER_LEN = 12 + ( 13 * 4 ); // identifier + header elements (not including key value meta-data pairs)    // load types
    public static inline var COMPRESSED_2D = 0; // uses a gl.compressedTexImage2D()
    public static inline var COMPRESSED_3D = 1; // uses a gl.compressedTexImage3D()
    public static inline var TEX_2D = 2; // uses a gl.texImage2D()
    public static inline var TEX_3D = 3; // uses a gl.texImage3D()


    public var glType:Int;
    public var glTypeSize:Int;
    public var glFormat:Int;
    public var glInternalFormat:Int;
    public var glBaseInternalFormat:Int;
    public var pixelWidth:Int;
    public var pixelHeight:Int;
    public var pixelDepth:Int;
    public var numberOfArrayElements:Int;
    public var numberOfFaces:Int;
    public var numberOfMipmapLevels:Int;
    public var bytesOfKeyValueData:Int;

    public var glCompressionFormat:Int;

    public var arrayBuffer:Bytes;

//    public var data:


    /**
	 * @param {ArrayBuffer} arrayBuffer- contents of the KTX container file
	 * @param {number} facesExpected- should be either 1 or 6, based whether a cube texture or or
	 * @param {boolean} threeDExpected- provision for indicating that data should be a 3D texture, not implemented
	 * @param {boolean} textureArrayExpected- provision for indicating that data should be a texture array, not implemented
	 */
    public function new(arrayBuffer:haxe.io.Bytes, facesExpected:Int /*, threeDExpected, textureArrayExpected */) {


        // Test that it is a ktx formatted file, based on the first 12 bytes, character representation is:
        // '´', 'K', 'T', 'X', ' ', '1', '1', 'ª', '\r', '\n', '\x1A', '\n'
        // 0xAB, 0x4B, 0x54, 0x58, 0x20, 0x31, 0x31, 0xBB, 0x0D, 0x0A, 0x1A, 0x0A
        var identifier = UInt8Array.fromBytes(arrayBuffer, 0, 12);
        if (identifier[ 0 ] != 0xAB ||
        identifier[ 1 ] != 0x4B ||
        identifier[ 2 ] != 0x54 ||
        identifier[ 3 ] != 0x58 ||
        identifier[ 4 ] != 0x20 ||
        identifier[ 5 ] != 0x31 ||
        identifier[ 6 ] != 0x31 ||
        identifier[ 7 ] != 0xBB ||
        identifier[ 8 ] != 0x0D ||
        identifier[ 9 ] != 0x0A ||
        identifier[ 10 ] != 0x1A ||
        identifier[ 11 ] != 0x0A) {

            trace('texture missing KTX identifier');
            return;

        }

        // load the reset of the header in native 32 bit uint
        var dataSize = UInt32Array.BYTES_PER_ELEMENT;
        var headerDataView = UInt32Array.fromBytes(arrayBuffer, 12, 13 * dataSize);
        var endianness = headerDataView.get(0);
        var littleEndian = endianness == 0x04030201;
        trace("Is little " + littleEndian);

        this.glType = headerDataView.get(1); // must be 0 for compressed textures
        this.glTypeSize = headerDataView.get(2); // must be 1 for compressed textures
        this.glFormat = headerDataView.get(3); // must be 0 for compressed textures
        this.glInternalFormat = headerDataView.get(4); // the value of arg passed to gl.compressedTexImage2D(,,x,,,,)
        this.glBaseInternalFormat = headerDataView.get(5); // specify GL_RGB, GL_RGBA, GL_ALPHA, etc (un-compressed only)
        this.pixelWidth = headerDataView.get(6); // level 0 value of arg passed to gl.compressedTexImage2D(,,,x,,,)
        this.pixelHeight = headerDataView.get(7); // level 0 value of arg passed to gl.compressedTexImage2D(,,,,x,,)
        this.pixelDepth = headerDataView.get(8); // level 0 value of arg passed to gl.compressedTexImage3D(,,,,,x,,)
        this.numberOfArrayElements = headerDataView.get(9); // used for texture arrays
        this.numberOfFaces = headerDataView.get(10); // used for cubemap textures, should either be 1 or 6
        this.numberOfMipmapLevels = headerDataView.get(11); // number of levels; disregard possibility of 0 for compressed textures
        this.bytesOfKeyValueData = headerDataView.get(12); // the amount of space after the header for meta-data

        // Make sure we have a compressed type.  Not only reduces work, but probably better to let dev know they are not compressing.
        if (this.glType != 0) {

            trace('only compressed formats currently supported');
            return;

        } else {

            // value of zero is an indication to generate mipmaps @ runtime.  Not usually allowed for compressed, so disregard.
            this.numberOfMipmapLevels = Std.int(Math.max(1, this.numberOfMipmapLevels));

        }

        if (this.pixelHeight == 0 || this.pixelDepth != 0) {

            trace('only 2D textures currently supported');
            return;

        }

        if (this.numberOfArrayElements != 0) {

            trace('texture arrays not currently supported');
            return;

        }

        if (this.numberOfFaces != facesExpected) {

            trace('number of faces expected' + facesExpected + ', but found ' + this.numberOfFaces);
            return;

        }

//        var gl:WebGLRenderContext;
//        switch (glBaseInternalFormat)
//        {
//            case 0x83f1:
//                compressedFormat_ = gl.CF_DXT1;
//                components_ = 4;
//                break;
//
//            case 0x83f2:
//                compressedFormat_ = CF_DXT3;
//                components_ = 4;
//                break;
//
//            case 0x83f3:
//                compressedFormat_ = CF_DXT5;
//                components_ = 4;
//                break;
//
//            case 0x8d64:
//                compressedFormat_ = CF_ETC1;
//                components_ = 3;
//                break;
//
//            case 0x9274:
//                compressedFormat_ = CF_ETC2_RGB;
//                components_ = 3;
//                break;
//
//            case 0x9278:
//                compressedFormat_ = CF_ETC2_RGBA;
//                components_ = 4;
//                break;
//
//            case 0x8c00:
//                compressedFormat_ = CF_PVRTC_RGB_4BPP;
//                components_ = 3;
//                break;
//
//            case 0x8c01:
//                compressedFormat_ = CF_PVRTC_RGB_2BPP;
//                components_ = 3;
//                break;
//
//            case 0x8c02:
//                compressedFormat_ = CF_PVRTC_RGBA_4BPP;
//                components_ = 4;
//                break;
//
//            case 0x8c03:
//                compressedFormat_ = CF_PVRTC_RGBA_2BPP;
//                components_ = 4;
//                break;
//
//            default:
//                compressedFormat_ = CF_NONE;
//                break;
//        }

        // we now have a completely validated file, so could use existence of loadType as success
        // would need to make this more elaborate & adjust checks above to support more than one load type
//        this.loadType = KhronosTextureContainer.COMPRESSED_2D;

        trace("KTX " + StringTools.hex(glInternalFormat) + haxe.Json.stringify(this, null, " "));
        this.arrayBuffer = arrayBuffer;
    }

    // return mipmaps for js
    public function mipmaps(loadMipmaps:Bool) {

        var mipmaps:Array<MipmapLevel> = [];

        // initialize width & height for level 1
        var dataOffset = KhronosTextureContainer.HEADER_LEN + this.bytesOfKeyValueData;
        var width = this.pixelWidth;
        var height = this.pixelHeight;
        var mipmapCount = loadMipmaps ? this.numberOfMipmapLevels : 1;

        for (level in 0...mipmapCount) {

            var imageSize = Int32Array.fromBytes(this.arrayBuffer, dataOffset, 1)[ 0 ]; // size per face, since not supporting array cubemaps
            dataOffset += 4; // size of the image + 4 for the imageSize field

            for (face in 0...numberOfFaces) {

                var byteArray = UInt8Array.fromBytes(this.arrayBuffer, dataOffset, imageSize);

                mipmaps.push({ data: byteArray, width: width, height: height });

                dataOffset += imageSize;
                dataOffset += 3 - ( ( imageSize + 3 ) % 4 ); // add padding for odd sized image

            }

            width = Std.int(Math.max(1.0, width * 0.5));
            height = Std.int(Math.max(1.0, height * 0.5));

        }

        return mipmaps;

    }


}
typedef MipmapLevel = {
    var data:UInt8Array;
    var width:Int;
    var height:Int;
}
