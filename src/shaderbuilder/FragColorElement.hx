package shaderbuilder;

import data.aliases.AttribAliases;
import shaderbuilder.ShaderElement;

class FragColorElement implements ShaderElement {
    public static var instance = new FragColorElement();

    public static inline var  outColor = "outColor";
    function new() {}

    public function getDecls():String {
        return 'vec4 $outColor = vec4(1.,1.,1.,1.);';
    }

    public function getExprs():String {
        return 'gl_FragColor = $outColor;';
    }
}

class FragColorAssignVertColor implements ShaderElement {
    public static var instance(default, null) = new FragColorAssignVertColor ();

    function new() {}

    public function getDecls():String {
        return '
           varying vec4 ${AttribAliases.NAME_COLOR_OUT};';
    }

    public function getExprs():String {
        return '${FragColorElement.outColor} = ${AttribAliases.NAME_COLOR_OUT};';
    }
}