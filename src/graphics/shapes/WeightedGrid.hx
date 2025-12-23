package graphics.shapes;

import Axis2D;
import a2d.Placeholder2D;
import a2d.WidgetInPixels;
import a2d.transform.WidgetToScreenRatio;
import al.core.MultiRefresher;
import al.core.WidgetContainer.Refreshable;
import data.IndexCollection;
import data.aliases.AttribAliases;
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import gl.ValueWriter.AttributeWriters;
import gl.sets.CircleSet;
import graphics.PhAntialiasing.PixelSizeInUVSpace;
import haxe.io.Bytes;
import macros.AVConstructor;

class WeightedGrid implements Shape {
    var inds:IndexCollection;
    var wwr:WeightedAttWriter;
    var count:Int;

    public function new(wwr) {
        this.wwr = wwr;
        inds = IndexCollection.qGrid(wwr.weights[horizontal].length, wwr.weights[vertical].length);
        count = wwr.weights[horizontal].length * wwr.weights[vertical].length;
    }

    public function writePostions(target:haxe.io.Bytes, vertOffset = 0, tr) {
        wwr.writeAtts(target, vertOffset, tr);
        writeAttributes(target, vertOffset, tr);
    }

    public dynamic function writeAttributes(target:Bytes, vertOffset = 0, transformer) {}

    public function getVertsCount():Int {
        return count;
    }

    public function getIndices() {
        return inds;
    }
}

class RoundWeightedGrid extends WeightedGrid {
    var attrs:CircleSet = CircleSet.instance;
    var aaAttrRequired = true;

    public function new(ph:Placeholder2D, posWeights, uvWeights) {
        var writers = attrs.getWriter(AttribAliases.NAME_POSITION);
        var wwr = new WeightedAttWriter(writers, posWeights);
        super(wwr);

        var uvwriters = attrs.getWriter(AttribAliases.NAME_UV_0);
        var uvWwr = new WeightedAttWriter(uvwriters, uvWeights);
        var sa = createGridWriter(ph, wwr);
        var rr = new MultiRefresher();
        rr.add(sa.refresh);
        ph.axisStates[vertical].addSibling(rr);
        if (aaAttrRequired) {
            var wip = new WidgetInPixels(ph);
            var piuv = new WGridPixelDensity(posWeights, uvWeights, wip);
            rr.add(() -> {
                wip.refresh();
                piuv.direction = wwr.direction;
                piuv.refresh();
            });
            var aac = new PhAntialiasing(attrs, getVertsCount(), piuv);
            writeAttributes = (target:Bytes, vertOffset = 0, transformer) -> {
                uvWwr.writeAtts(target, vertOffset, passThrough);
                aac.writePostions(target, vertOffset, transformer);
            }
        } else {
            writeAttributes = (target:Bytes, vertOffset = 0, transformer) -> {
                uvWwr.writeAtts(target, vertOffset, passThrough);
            }
        }
    }

    function createGridWriter(ph, wwr):Refreshable {
        throw "abstract: N/A";
    }

    function passThrough(_, v)
        return v;
}

// class GridFactoryBase<T:AttribSet> {
//     var attrs:T;
//     var uvWeights:AVector2D<Array<Float>>;
//     var aaAttrRequired = false;
//     var uvWwr:WeightedAttWriter;

//     // var uvWriters = attrs.getWriter(AttribAliases.NAME_UV_0);

//     public function new(attrs) {
//         this.attrs = attrs;
//         aaAttrRequired = attrs.hasAttr(AttribAliases.AASIZE_IN);
//         uvWeights = createUVWeights();
//         var uvWriters = attrs.getWriter(AttribAliases.NAME_UV_0);
//         uvWwr = new WeightedAttWriter(uvWriters, uvWeights);
//     }

//     public function create(ph:Placeholder2D) {
//         // var posWeights = createPosWeights();
//         // var writers = attrs.getWriter(AttribAliases.NAME_POSITION);
//         // var wwr = new WeightedAttWriter(writers, posWeights);

//         // var s = new WeightedGrid(wwr);
//         // var sa = createGridWriter(ph, wwr);
//         // var rr = new MultiRefresher();
//         // rr.add(sa.refresh);
//         // ph.axisStates[vertical].addSibling(rr);
//         // if (aaAttrRequired) {

//         //     var aac = getAACalculator(ph, s, wwr, rr);
//         //     s.writeAttributes = (target:Bytes, vertOffset = 0, transformer) -> {
//         //         uvWwr.writeAtts(target, vertOffset, passThrough);
//         //         aac.writePostions(target, vertOffset, transformer);
//         //     }
//         // } else {
//         //     s.writeAttributes = (target:Bytes, vertOffset = 0, transformer) -> {
//         //         uvWwr.writeAtts(target, vertOffset, (_, v) -> v);
//         //     }
//         // }
//         // return s;
//     }

//     function passThrough(_, v)
//         return v;

//     public function addUV(buffer:ShapesBuffer<T>, vertOffset = 0) {}

//     function createUVWeights():AVector2D<Array<Float>> {
//         throw "abstract: N/A";
//     }

//     function createPosWeights():AVector2D<Array<Float>> {
//         throw "abstract: N/A";
//     }

//     function createGridWriter(ph, wwr):Refreshable {
//         throw "abstract: N/A";
//     }

//     function getAACalculator(ph, s, wwr, rr) {
//         var wip = new WidgetInPixels(ph);
//         var piuv = new WGridPixelDensity(wwr.weights, uvWeights, wip);
//         rr.add(() -> {
//             wip.refresh();
//             piuv.direction = wwr.direction;
//             piuv.refresh();
//         });
//         var aa = new PhAntialiasing(attrs, s.getVertsCount(), piuv);
//         return aa;
//     }

//     // function adduv(shw:shapewidget<t>) {
//     //     var buffer:shapesbuffer<t> = shw.getbuffer();
//     //     var vertoffset = 0;
//     //     var writers = attrs.getwriter(attribaliases.name_uv_0);
//     //     var wwr = new weightedattwriter(writers, uvweights);
//     //     wwr.writeatts(buffer.getbuffer(), vertoffset, (_, v) -> v);
//     // }
// }

interface Directed {
    public var direction(default, null):Axis2D;
}

class WeightedAttWriter implements Directed {
    var writers:AttributeWriters;
    public var verbose:Bool;

    public var direction:Axis2D = horizontal;
    public var weights(default, null):AVector2D<Array<Float>>;

    public function new(wrs, wghs:AVector2D<Array<Float>>) {
        this.writers = wrs;
        this.weights = wghs;
    }

    public inline function writeAtts(target, vertOffset, tr) {
        var aw = weights[horizontal];
        var cw = weights[vertical];
        if(verbose)
        trace(aw, cw);
        for (i in 0...cw.length)
            writeLine(target, direction, vertOffset + aw.length * i, 1, aw, tr);
        for (i in 0...aw.length) {
            writeLine(target, direction.other(), vertOffset + i, aw.length, cw, tr);
        }
    }

    public inline function writeLine(target, dir:Axis2D, start, offset, weights, tr) {
        for (i in 0...weights.length)
            writers[dir].setValue(target, start + i * offset, tr(dir, weights[i]));
    }
}

class WGridPixelDensity implements PixelSizeInUVSpace implements Refreshable {
    var weights:AVector2D<Array<Float>>;
    var uvweights:AVector2D<Array<Float>>;
    var wip:WidgetInPixels;

    public var direction:Axis2D = horizontal;
    public var pixelSizeInUVSpace(default, null):Float;

    public function new(wgs, uvwgs, wip) {
        this.weights = wgs;
        this.uvweights = uvwgs;
        this.wip = wip;
    }

    public function refresh() {
        // current direction impl supposed for tgrid
        // which swaps weights according to the ratio
        // so primary weights applied to given direction is always horizontal
        var wgs = weights[horizontal];
        var size = wgs[1] - wgs[0];
        var pxPerQuad = wip.size[direction] * size;
        var wgs = uvweights[horizontal];
        var uvuPerQuad = wgs[1] - wgs[0];
        pixelSizeInUVSpace = uvuPerQuad / pxPerQuad;
    }
}
