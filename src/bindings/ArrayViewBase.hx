package bindings;

typedef ArrayViewBase = #if js js.lib.ArrayBufferView #else lime.utils.ArrayBufferView #end
