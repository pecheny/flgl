package gl.sets;

import data.aliases.AttribAliases;
import data.DataType;
import gl.AttribSet;
class CMSDFSet extends AttribSet {
    public static inline var NAME_DPI = "dpi";
    public static var instance(default, null):CMSDFSet = new CMSDFSet();

    function new() {
        super();
        addAttribute(AttribAliases.NAME_POSITION, 2, DataType.float32);
        addAttribute(AttribAliases.NAME_UV_0, 2, DataType.float32);
        addAttribute(NAME_DPI, 1, DataType.float32);
        addAttribute(AttribAliases.NAME_COLOR_IN, 4, DataType.uint8, true);
        createWriters();
    }
}
