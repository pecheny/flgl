package gl.aspects;

import bindings.GLUniformLocation;
import gl.GLDisplayObject.GLState;
import gl.aspects.RenderingAspect;
import lime.utils.Float32Array;
import lime.math.Matrix4;
import shaderbuilder.ProjectionMatrixElement;

class TransformAspect implements RenderingAspect {
    var color:GLUniformLocation;
    var inited = false;

    public final matrix = new Matrix4();

    public function new() {}

    public function bind(state:GLState<Dynamic>):Void {
        var gl = state.gl;
        #if debug
        if (!state.uniforms.exists(ProjectionMatrixElement.matrix))
            throw 'Uniform "${ProjectionMatrixElement.matrix}" is not defined in the pass.';
        #end
        gl.uniformMatrix4fv(state.uniforms[ProjectionMatrixElement.matrix], false, matrix);
    }

    public function unbind(gl):Void {
        // texure.unbind(gl);
        // TODO set identity here
    }
}
