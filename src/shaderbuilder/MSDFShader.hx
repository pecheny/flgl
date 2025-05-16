package shaderbuilder;

import gl.GLDisplayObject.GLState;
import bindings.GLUniformLocation;
import data.aliases.AttribAliases;
import data.aliases.VaryingAliases;
import gl.aspects.RenderingAspect;
import gl.aspects.TextureBinder;
import gl.sets.MSDFSet;
import shaderbuilder.SnaderBuilder;

class MSDFFrag implements ShaderElement {
    public static var instance = new MSDFFrag();
    static var uv_v = VaryingAliases.UV_0;
    static var smothness = MSDFShader.smoothness;

    public function new() {}

    public function getDecls():String {
        return '
            varying float $smothness;
            uniform sampler2D ${MSDFShader.glyphAtlas};
            varying vec2 $uv_v;

            float median(float r, float g, float b) {
                return max(min(r, g), min(max(r, g), b));
            }';
    }

    public function getExprs():String {
        return '   float vFieldRangeDisplay_px = 120.0;
            float acut = 0.5;
            vec4 sample = texture2D(${MSDFShader.glyphAtlas}, $uv_v);
            float sigDist =  median(sample.r, sample.g, sample.b);
            float r = clamp($smothness, 0., 0.5);
            // spread field range over 1px for antialiasing
            float fillAlpha = 	smoothstep(acut-r, acut +r, sigDist );
            ${FragColorElement.outColor}.a *= fillAlpha; ';
    }
}

// todo Use linear function for now, check if logistic function has meaning for edge cases
// class LogisticSmoothnessCalculator implements ShaderElement {
//    public static var instance(default, null) = new LogisticSmoothnessCalculator();
//
//    function new() {}
//
//    public function getDecls():String {
//        return '
//                varying float ${MSDFShader.smoothness};
//                 attribute float ${MSDFSet.NAME_DPI};
//
//                 float logist(float x) {
//                           float p0 = 0.03;
//                           float k = 0.7;
//                           float r = 3.;
//                           float t = (x -80.) / 100. ;
//                           float ert = exp(r*t);
//                           return 0.0 +  k -(k * p0 * ert) / (k + p0 *(ert - 1.));
//    }
// ' ;
//    }
//
//    public function getExprs():String {
//        return '
//                   ${MSDFShader.smoothness} = logist(${MSDFSet.NAME_DPI});';
//    }
// }

class MSDFShader extends ShaderBase {
    public static var instence = new MSDFShader();
    public static inline var smoothness = "smoothness";
    public static inline var resolution = "resolution";
    public static inline var glyphAtlas = "glyphAtlas";
    public static inline var color = "color";
    public static inline var position = AttribAliases.NAME_POSITION;
    public static inline var uv = AttribAliases.NAME_UV_0;

    //    public static inline var atlasScale = MSDFSet.NAME_ATLAS_SCALE;
    static var smoothShaderEl:GeneralPassthrough;

    public function new() {
        smoothShaderEl = new GeneralPassthrough(MSDFSet.NAME_DPI, smoothness);
        super([PosPassthrough.instance, Uv0Passthrough.instance, smoothShaderEl], [MSDFFrag.instance]);
    }
}
