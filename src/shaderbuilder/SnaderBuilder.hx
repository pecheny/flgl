package shaderbuilder;

import bindings.GLProgram;
import lime.graphics.opengl.GLShader;
import data.aliases.AttribAliases;
import data.aliases.VaryingAliases;

class ShaderBase {
    public var vs(default, null):String;
    public var fs(default, null):String;

    public function create(gl) {
        #if debug
        return fromSources(gl, vs, fs);
        #end
        return GLProgram.fromSources(gl, vs, fs);
    }

    #if debug
    static function fromSources(gl, vertexSource:String, fragmentSource:String):GLProgram {
        var vertexShader = GLShader.fromSource(gl, vertexSource, gl.VERTEX_SHADER);
        var info = gl.getShaderInfoLog(vertexShader);
        if (info != null)
            trace(info);

        var fragmentShader = GLShader.fromSource(gl, fragmentSource, gl.FRAGMENT_SHADER);
        info = gl.getShaderInfoLog(fragmentShader);
        if (info != null)
            trace(info);

        var program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);

        if (gl.getProgramParameter(program, gl.LINK_STATUS) == 0) {
            var message = "Unable to initialize the shader program";
            message += "\n" + gl.getProgramInfoLog(program);
            trace(message);
        }

        return program;
    }
    #end

    public function new(vertEls:Array<ShaderElement>, fragEls:Array<ShaderElement>) {
        var vs = new ShaderBuilder();
        for (ve in vertEls)
            vs.addNode(ve);
        this.vs = vs.build();
        //        trace(this.vs);

        var fs = new ShaderBuilder();
        for (fe in fragEls)
            fs.addNode(fe);
        this.fs = fs.buildFragment();
        //        trace(this.fs);
        //        trace(TextureShader.instance.vs  + " " + TextureShader.instance.fs);
    }
}

class TextureShader extends ShaderBase {
    public static var instance(default, null) = new TextureShader();

    function new() {
        super([PosPassthrough.instance, Uv0Passthrough.instance], [TextureFragment.get(0, 0)]);
        // trace(vs);
        // trace(fs);
    }
}

class VertColorShader extends ShaderBase {
    public static var instance(default, null) = new VertColorShader();

    function new() {
        super([PosPassthrough.instance, ColorPassthroughVert.instance], [ColorPassthroughFrag.instance]);
    }
}

class ShaderBuilder {
    var nodes:Array<ShaderElement> = [];

    inline static var FRAG_HEADER = #if (!desktop || rpi) "precision mediump float;" #else "" #end;

    public function new() {}

    public function addNode(n:ShaderElement) {
        nodes.push(n);
    }

    public inline function buildFragment() {
        return FRAG_HEADER + "\n" + build();
    }

    public inline function build() {
        var decls = "";
        for (n in nodes) {
            decls += n.getDecls() + "\n";
        }
        var body = "void main() {\n";
        for (n in nodes) {
            body += n.getExprs() + "\n";
        }
        body += "}\n";
        return decls + "\n" + body;
    }
}

class PosPassthrough implements ShaderElement {
    public static var instance(default, null) = new PosPassthrough();

    function new() {}

    public function getDecls():String {
        return '
        attribute vec2 ${AttribAliases.NAME_POSITION};';
    }

    public function getExprs():String {
        return '
        gl_Position =  vec4(${AttribAliases.NAME_POSITION}.x, ${AttribAliases.NAME_POSITION}.y,  0, 1);';
    }
}

class ColorPassthroughVert implements ShaderElement {
    public static var instance(default, null) = new ColorPassthroughVert();

    function new() {}

    public function getDecls():String {
        return '
         attribute vec4 ${AttribAliases.NAME_COLOR_IN};
         varying vec4 ${AttribAliases.NAME_COLOR_OUT};';
    }

    public function getExprs():String {
        return '
                   ${AttribAliases.NAME_COLOR_OUT} = ${AttribAliases.NAME_COLOR_IN};';
    }
}

class ColorPassthroughFrag implements ShaderElement {
    public static var instance(default, null) = new ColorPassthroughFrag();

    function new() {}

    public function getDecls():String {
        return '
           varying vec4 ${AttribAliases.NAME_COLOR_OUT};';
    }

    public function getExprs():String {
        return '
           gl_FragColor = ${AttribAliases.NAME_COLOR_OUT};';
    }
}

class Uv0Passthrough implements ShaderElement {
    public static var instance(default, null) = new Uv0Passthrough();

    function new() {}

    public function getDecls():String {
        return '
                 attribute vec2 ${AttribAliases.NAME_UV_0};
                 varying vec2 ${VaryingAliases.UV_0};';
    }

    public function getExprs():String {
        return '
                   ${VaryingAliases.UV_0} = ${AttribAliases.NAME_UV_0};';
    }
}

class GeneralPassthrough implements ShaderElement {
    var type:String = "float";
    var attrName:String;
    var varName:String;

    public function new(a, v, t = "float") {
        this.attrName = a;
        this.varName = v;
        this.type = t;
    }

    public function getDecls():String {
        return '
                 attribute $type $attrName;
                 varying $type $varName;';
    }

    public function getExprs():String {
        return '$varName = $attrName;';
    }
}

class ApplyVertColorFrag implements ShaderElement {
    public static var instance(default, null) = new ApplyVertColorFrag();

    function new() {}

    public function getDecls():String {
        return '
           varying vec4 ${AttribAliases.NAME_COLOR_OUT};';
    }

    public function getExprs():String {
        return '
           vec4 cl = vec4(0.0, 0.0, 0.0, 1.0);
           gl_FragColor.rgb = ${AttribAliases.NAME_COLOR_OUT}.rgb;';
    }
}

class ApplyUnoformColorFrag implements ShaderElement {
    public static var instance(default, null) = new ApplyUnoformColorFrag();

    function new() {}

    public function getDecls():String {
        return '
           uniform vec4 color;';
    }

    public function getExprs():String {
        return '
           gl_FragColor.rgb = color.rgb;';
    }
}
