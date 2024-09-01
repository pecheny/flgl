package shaderbuilder;

import shaderbuilder.ShaderElement;

class ProjectionMatrixElement implements ShaderElement {
	public static var instance(default, null) = new ProjectionMatrixElement();
	public static inline var matrix = "matrix";
    public static inline var  alias = "prj-mat";

	function new() {}

	public function getDecls():String {
		return '
        uniform mat4 $matrix;
        ';
	}

	public function getExprs():String {
		return '
        gl_Position = $matrix * gl_Position;
        ';
	}
}
