package gl.sets;

import data.aliases.AttribAliases;
import data.DataType;
import gl.AttribSet;

class CircleSet extends AttribSet {
   public static inline var  R1_IN = "R1_IN"; 
   public static inline var  R2_IN = "R2_IN"; 
   public static inline var  R1_OUT = "r1"; 
   public static inline var  R2_OUT = "r2"; 
   /**
        Thickness of "antialiasing zone" given in onits of UV-space.
   **/
   public static inline var  AASIZE_IN = "AASIZE_IN";
   public static inline var  AASIZE = "aasize";

    public static var instance(default, null):CircleSet = new CircleSet();

    function new() {
        super();
        addAttribute(AttribAliases.NAME_POSITION, 2, DataType.float32);
        addAttribute(AttribAliases.NAME_UV_0, 2, DataType.float32);
        addAttribute(R1_IN, 1, DataType.float32);
        addAttribute(R2_IN, 1, DataType.float32);
        addAttribute(AASIZE_IN, 1, DataType.float32);
        addAttribute(AttribAliases.NAME_COLOR_IN, 4, DataType.uint8, true);

        createWriters();
    }
}
