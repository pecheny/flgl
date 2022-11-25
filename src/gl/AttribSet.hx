package gl;
import data.aliases.AttribAliases;
import haxe.io.Bytes;
import data.ShadersAttrs;
import data.AttributeState;
import data.AttributeDescr;
import bindings.WebGLRenderContext;
import bindings.GL;
import data.DataType;
import gl.ValueWriter;
#if (cpp || js || hl)
import bindings.GLProgram;
#end
import haxe.io.Float32Array;
import haxe.io.Int32Array;
import haxe.io.UInt16Array;
import haxe.io.UInt8Array;
class AttribSet {
    public function new() {}
    public var stride(default, null):Int = 0;
    public var attributes:Array<AttributeDescr> = [];
    var writers:Map<String, AttributeWriters> = new Map();
//    var offset:Int = 0;

    public function addAttribute(name:String, numComponents:Int, type:DataType, normalized:Bool = false) {
        var descr = {
            name:name,
            numComponents:numComponents,
            type:type,
            offset:stride,
            normalized:normalized
        }
        writers[name] = createWritersForAttribute(descr);
        stride += numComponents * getGlSize(type);
//        attribPointers[name] = attributes.length;
        attributes.push(descr);
    }

    public function getDescr(name):AttributeDescr {
        for (d in attributes) {
            if (d.name == name)
                return d;
        }
        throw "No such attr " + name;
    }

    public function hasAttr(name) {
        for (d in attributes) {
            if (d.name == name)
                return true;
        }
        return false;
    }



    #if (cpp || js || hl)

    public static inline function getGlSize(type:DataType) {
        return switch type {
            case int32 : Int32Array.BYTES_PER_ELEMENT;
            case uint8 : UInt8Array.BYTES_PER_ELEMENT;
            case uint16 : UInt16Array.BYTES_PER_ELEMENT;
            case float32 : Float32Array.BYTES_PER_ELEMENT;
        }
    }

    public function buildState(gl:WebGLRenderContext, program:GLProgram) {
        var attrs = [];
        for (desc in attributes) {
            var posIdx = gl.getAttribLocation(program, desc.name);
            attrs.push(new AttributeState(posIdx, desc));
        }
        return new ShadersAttrs(attrs);
    }

    public function enableAttributes(gl:WebGLRenderContext, attrsState:ShadersAttrs) {
        var offset = 0;
        var attributes = attrsState.attrs;
        for (i in 0...attributes.length) {
            var state = attributes[i];
            var descr= state.descr;
            gl.enableVertexAttribArray(state.idx);
            gl.vertexAttribPointer(state.idx, descr.numComponents, getGlType(descr.type, gl), descr.normalized, stride, descr.offset);
            offset += descr.numComponents * getGlSize(descr.type);
        }
    }

    static inline function getValue(reader:Bytes, type:DataType, offset) {
        return
            switch type {
                case uint8 : reader.get(offset);
                case int32 : reader.getInt32(offset);
                case uint16 : reader.getUInt16(offset);
                case float32 : reader.getFloat(offset);
            }
    }

    public inline function printVertex(data:Bytes, v){
        var r = "";
        for (att in attributes) {
            r += att.name  + ": [";
            var access = writers[att.name];
            for (i in 0...access.length)
                r+= access[i].getValue(data, v) + " ";
            r+="]";
        }
        return r;
    }

    public inline function getGlType(type:DataType, gl:WebGLRenderContext) {
        return switch type {
            case int32 : GL.INT;
            case uint8 : GL.UNSIGNED_BYTE;
            case uint16 : GL.UNSIGNED_SHORT;
            case float32 : GL.FLOAT;
        }
    }
    #end

    public function getView(alias:String) {
        for (desc in attributes) {
            if (desc.name == alias)
                return{
                    stride:stride,
                    offset:desc.offset,
                    numComponents:desc.numComponents,
                    type:desc.type
                }
        }
        throw "Wrong! " + alias;
    }

    inline function createWriter( attr:AttributeDescr, comp:Int, stride:Int, offset:Int = 0):IValueWriter {
        switch attr.type {
            case float32 : return new FloatValueWriter(attr, comp, stride, offset);
            case uint8 : return new Uint8ValueWriter(attr, comp, stride, offset);
            case _ : throw "not implemented yet";
        }
    }


    public function getWriter(alias:String):AttributeWriters {
        if (writers.exists(alias))
            return writers[alias];
        for (descr in attributes) {
            if (descr.name == alias) {
                writers[descr.name] = createWritersForAttribute(descr);
                return writers[descr.name];
            }
        }
        throw "wrong attr " + alias;
    }

    inline function createWritersForAttribute(descr:AttributeDescr):AttributeWriters {
        var wrs = [];
        for (i in 0...descr.numComponents) {
            wrs.push(createWriter(descr, i, stride));
        }
        return wrs;
    }

    function createWriters() {
        for (descr in attributes) {
            writers[descr.name] = createWritersForAttribute(descr);
        }
    }

    public inline function writeColor(buffer, color, first, count, alpha = 255) {
        var writers = getWriter(AttribAliases.NAME_COLOR_IN);
        var r = color >> 16;
        var g = (color & 0x00ff00) >> 8;
        var b = (color & 0x0000ff);
        for (vert in first...first + count) {
            writers[0].setValue(buffer, vert, r);
            writers[1].setValue(buffer, vert, g);
            writers[2].setValue(buffer, vert, b);
            writers[3].setValue(buffer, vert, alpha);
        }
    }
}
