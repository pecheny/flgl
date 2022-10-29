package bindings;
typedef ArrayBufferView =
#if nme
    nme.utils.ArrayBufferView;
#elseif lime
    lime.utils.ArrayBufferView;
#elseif js
    js.lib.ArrayBufferView;
#else
    Dynamic;
#end
    
