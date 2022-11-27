package graphics;

import utils.Signal;
import data.aliases.AttribAliases;
import data.IndexCollection;
import gl.AttribSet;
import gl.Renderable;
import gl.RenderTarget;
import gl.ValueWriter.AttributeWriters;
import graphics.shapes.Shape;
import haxe.io.Bytes;

class ShapeRenderer<T:AttribSet> implements Renderable<T> implements ShapesBuffer<T> {
    public var buffer(default, null):Bytes;
    public var onInit(default, null):Signal<Void -> Void> = new Signal();
    var posWriter:AttributeWriters;
    var children:Array<Shape> = [];
    var vertsCount:Int = 0;
    var inds:IndexCollection;
    var attrs:T;
    var inited = false;

    public function new(attrs:T) {
        this.attrs = attrs;
        posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
    }

    public function addChild(shape:Shape) {
        if (inited) throw "Can't add children after initialization";
        children.push(shape);
    }

    public function initChildren() {
        var indsCount = 0;
        vertsCount = 0;
        for (sh in children) {
            vertsCount += sh.getVertsCount();
            indsCount += sh.getIndices().length;
        }
        buffer = Bytes.alloc(vertsCount * attrs.stride);
        inds = new IndexCollection(indsCount);
        fillIndices();
        inited = true;
        onInit.dispatch();
    }

    function fillIndices() {
        var indNum = 0;
        var vertNum = 0;
        for (sh in children) {
            var shInds = sh.getIndices();
            for (i in 0...shInds.length) {
                inds[indNum + i] = shInds[i] + vertNum;
            }
            vertNum += sh.getVertsCount();
            indNum += shInds.length;
        }
    }

    public dynamic function transform(a:Axis2D, v) return v;

    public function render(targets:RenderTarget<T>):Void {
        if (!inited)
            return;
        targets.blitIndices(inds, inds.length);
        var pos = 0;
        for (sh in children) {
            sh.writePostions(buffer, posWriter, pos, transform);
            pos += sh.getVertsCount();
        }
        targets.blitVerts(buffer, vertsCount);
    }

    public function getVertCount():Int {
        if (!inited) throw "wrong";
        return vertsCount;
    }

    function printVerts(n) {
        for (i in 0...n)
            trace(i + " " + attrs.printVertex(buffer, i));
    }

    public function getBuffer():Bytes {
        return buffer;
    }

    public function isInited():Bool {
        return inited;
    }
}
