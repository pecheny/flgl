package shaderbuilder;

import data.aliases.AttribAliases;
import data.aliases.VaryingAliases;
import gl.sets.CircleSet;

class CircleShader implements ShaderElement {
    public static var instance = new CircleShader();

    static var uv = VaryingAliases.UV_0;
    static var r1 = CircleSet.R1_OUT;
    static var r2 = CircleSet.R2_OUT;
    static var aa = AttribAliases.AASIZE;

    function new() {}

    // aa - thickness of antialiasing zone. sqrt(r) - empirical multiplier to make antialiasing visually similar
    public function getDecls():String {
        return ' varying vec2 $uv; 
                varying float $aa;
                varying float $r1;
                varying float $r2;

                float circle(in float r){
                    vec2 dist = $uv - vec2(0.5);
                    float edge = sqrt(r) * $aa;
                    return 1. -smoothstep(r - edge, r + edge,
                                        dot(dist, dist) * 4.0);
                }
        ';
    }

    public function getExprs():String {
        return '
            float val = circle($r2);
            if ($r1 > 0.01)
             val *= (1. - circle($r1));
            ${FragColorElement.outColor}.a *= val;
        ';
    }
}
