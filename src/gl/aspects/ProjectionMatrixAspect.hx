package gl.aspects;

import shaderbuilder.ProjectionMatrixElement;
import bindings.GLUniformLocation;
import gl.GLDisplayObject.GLState;
import gl.aspects.RenderingAspect;
import lime.utils.Float32Array;

class ProjectionMatrixAspect implements RenderingAspect implements al.core.AllAxisApplier<Axis2D> {
    var color:GLUniformLocation;
    var inited = false;

    public function new() {
        setView(-1, 1, -1, 1);
    }

    public function bind(state:GLState<Dynamic>):Void {
        var gl = state.gl;
        gl.uniformMatrix4fv(state.uniforms[ProjectionMatrixElement.matrix], false, data);
    }

    // target viewport to map into
    var l = 0.0;
    var r = 1.0;
    var b = 1.0;
    var t = 0.0;

    public function apply(a:Axis2D, p, s) {
        switch a {
            case horizontal:
                l = p;
                r = p + s;
            case vertical:
                b = p;
                t = p + s;
        }
        setOrthoProjection(l, r, b, t, 0, 100);
    }

    var data = new Float32Array(16);

    // TODO check t/b and y axis direction everywhere
    // set visible rectangle in the word coords (in which mesh versices is set)
    var vl = 0.0;
    var vr = 1.0;
    var vb = 1.0;
    var vt = 0.0;

    public function setView(l, r, b, t) {
        vl = l;
        vr = r;
        vt = t;
        vb = b;
    }

    // http://learnwebgl.brown37.net/lib/learn_webgl_matrix.js
    // http://learnwebgl.brown37.net/transformations2/matrix_library_introduction.html
    public function setOrthoProjection(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float) {
        var M = data;

        // Make sure there is no division by zero
        if (left == right || bottom == top || near == far) {
            throw "Invalid createOrthographic parameters";
            //   self.setIdentity(M);
            //   return M;
        }

        var widthRatio = 1.0 / (right - left);
        var heightRatio = 1.0 / (top - bottom);
        var depthRatio = 1.0 / (far - near);

        var hs = vr - vl;
        var vs = vt - vb;

        var vx = (vr + vl) / 2;
        var vy = (vt + vb) / 2;

        var scale = Math.max(widthRatio / hs, heightRatio / vs) * 4;
        var sx = 2 * widthRatio * scale;
        var sy = 2 * heightRatio * scale;
        var sz = -2 * depthRatio * scale;

        var tx = 1 - (right + left + vx) * widthRatio;
        var ty = 1 - (top + bottom + vy) * heightRatio;
        var tz = -(far + near) * depthRatio;
// @formatter:off
        M[0] = sx;  M[4] = 0;   M[8] = 0;   M[12] = tx;
        M[1] = 0;   M[5] = sy;  M[9] = 0;   M[13] = ty;
        M[2] = 0;   M[6] = 0;   M[10] = sz; M[14] = tz;
        M[3] = 0;   M[7] = 0;   M[11] = 0;  M[15] = 1;
// @formatter:on
        return M;
    };

    public function unbind(gl):Void {
        // texure.unbind(gl);
        // TODO set identity here
    }
}
