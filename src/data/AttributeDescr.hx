package data;

import data.DataType;
typedef AttributeDescr = {
    name:String,
    type:DataType,
    numComponents:Int,
    normalized:Bool,
    ?offset:Int,
    ?writer:Float->Float
}

