package bindings;
typedef WebGLRenderContext =
#if idea
bindings.mock.WebGLRenderContext;
#elseif lime
lime.graphics.WebGLRenderContext;
#elseif js
js.html.webgl.WebGL2RenderingContext;
#else
Dynamic
#end
