package gl.sets;

import haxe.io.Bytes;
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
        addAttribute(AttribAliases.AASIZE_IN, 1, DataType.float32);
        addAttribute(AttribAliases.NAME_COLOR_IN, 4, DataType.uint8, true);

        createWriters();
    }
}

class RadiusAtt<T:AttribSet> {
    var att:T;

    public var r1 = 0.3;
    public var r2 = 0.9;

    var vertsCount:Int;

    public function new(att, vertsCount) {
        this.att = att;
        this.vertsCount = vertsCount;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        att.fillFloat(target, CircleSet.R1_IN, r1, vertOffset, vertsCount);
        att.fillFloat(target, CircleSet.R2_IN, r2, vertOffset, vertsCount);
    }
}