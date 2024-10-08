package shaderbuilder;

import gl.sets.CircleSet;
import data.aliases.VaryingAliases;

class CircleShader implements ShaderElement {
    public static var instance = new CircleShader();

    static var uv_v = VaryingAliases.UV_0;
    static var r1 = CircleSet.R1_OUT;
    static var r2 = CircleSet.R2_OUT;
    static var aa = CircleSet.AASIZE;

    function new() {}
// aa - thickness of antialiasing zone. sqrt(r) - empirical multiplier to make antialiasing visually similar
    public function getDecls():String {
        return ' varying vec2 $uv_v; 
                varying float $aa;
                varying float $r1;
                varying float $r2;

                float circle(in vec2 _st, in float r){
                    vec2 dist = _st - vec2(0.5);
                    return 1. -smoothstep(r - ($aa * sqrt(r)),
                                        r + ($aa * sqrt(r)),
                                        dot(dist, dist) * 4.0);
                }
        ';

    }

    public function getExprs():String {
        return '
        vec2 st = $uv_v.xy ;
        vec3 color = vec3(circle(st, $r2) * (1. - (circle(st, $r1))));;
        gl_FragColor = vec4( color, 1.0 );
        ';

    }
}
