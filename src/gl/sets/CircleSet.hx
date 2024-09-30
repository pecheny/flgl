package gl.sets;

import data.aliases.AttribAliases;
import data.DataType;
import gl.AttribSet;

class CircleSet extends AttribSet {
   public static inline var  R1_IN = "R1_IN"; 
   public static inline var  R2_IN = "R2_IN"; 
   public static inline var  R1_OUT = "r1"; 
   public static inline var  R2_OUT = "r2"; 

    public static var instance(default, null):CircleSet = new CircleSet();

    function new() {
        super();
        addAttribute(AttribAliases.NAME_POSITION, 2, DataType.float32);
        addAttribute(AttribAliases.NAME_UV_0, 2, DataType.float32);
        addAttribute(R1_IN, 1, DataType.float32);
        addAttribute(R2_IN, 1, DataType.float32);
        createWriters();
    }
}
