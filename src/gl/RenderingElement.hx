package gl;
import bindings.GLProgram;
import bindings.WebGLRenderContext;
interface Bindable {
    function bind():Void;

    function unbind():Void;
}

interface GLInitable {
    public function init(gl:WebGLRenderContext, program:GLProgram):Void;
}

interface RenderingElement extends Bindable extends GLInitable {}




