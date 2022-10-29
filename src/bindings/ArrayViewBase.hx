package bindings;

import js.lib.ArrayBufferView;

typedef ArrayViewBase = #if js js.lib.ArrayBufferView #else lime.utils.ArrayBufferView #end
