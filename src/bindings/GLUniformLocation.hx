package bindings;
typedef GLUniformLocation =
#if lime
lime.graphics.opengl.GLUniformLocation;
#elseif js
js.html.webgl.UniformLocation;
#else
Dynamic;
#end

