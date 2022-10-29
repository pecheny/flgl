package bindings;

#if js
import js.html.webgl.WebGL2RenderingContext as GL;

abstract JSGLProgram(js.html.webgl.Program) to js.html.webgl.Program from js.html.webgl.Program {
    public static inline function fromSources(gl:WebGLRenderContext, vertexSource:String, fragmentSource:String) {
        var vertexShader = fromSource(gl, vertexSource, GL.VERTEX_SHADER);
        var fragmentShader = fromSource(gl, fragmentSource, GL.FRAGMENT_SHADER);

        var program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);

        if (gl.getProgramParameter(program, GL.LINK_STATUS) == 0) {
            var message = "Unable to initialize the shader program";
            message += "\n" + gl.getProgramInfoLog(program);
            throw message;
        }

        return program;
    }

    static function fromSource(gl:WebGLRenderContext, source:String, type:Int) {
        var shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
        var shaderInfoLog = gl.getShaderInfoLog(shader);
        var compileStatus = gl.getShaderParameter(shader, GL.COMPILE_STATUS);

        if (shaderInfoLog != null || compileStatus == 0) {
            var message;

            if (compileStatus == 0)
                message = "Error ";
            else
                message = "Info ";

            if (type == GL.VERTEX_SHADER)
                message = "compiling vertex shader";
            else if (type == GL.FRAGMENT_SHADER)
                message = "compiling fragment shader";
            else
                message = "compiling unknown shader type";

            message += "\n" + shaderInfoLog;

            if (compileStatus == 0)
                throw message;
            else if (shaderInfoLog != null)
                message;
        }

        return shader;
    }
}
#end

typedef GLProgram = #if nme nme.gl.GLProgram #elseif lime lime.graphics.opengl.GLProgram #elseif js JSGLProgram #else Dynamic #end;
