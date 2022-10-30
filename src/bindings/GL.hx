package bindings;
typedef GL =
#if lime
lime.graphics.opengl.GL;
#elseif js
js.html.webgl.GL;
#else
Dynamic;
#end
