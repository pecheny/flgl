package graphics.shapes;
import Axis2D;
import data.IndexCollection;
import gl.ValueWriter;
import graphics.shapes.RectWeights;
import haxe.ds.ReadOnlyArray;
import haxe.io.Bytes;
import macros.AVConstructor;
import transform.AspectRatio;

class Bar implements Shape {
    var axis:ReadOnlyAVector2D<BarAxisBase>;

    public function new(att, xt, yt) {
        axis = AVConstructor.create(xt, yt);
    }

    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset = 0, transformer) {
        for (a in Axis2D) {
            axis[a].writePositions(a, transformer, target, writer, vertOffset);
        }
    }

    public function getVertsCount():Int {
        return 4;
    }

    public function getIndices() {
        return IndexCollections.QUAD_ODD;
    }
}

class BarContainer {
    public var axis:ReadOnlyAVector2D<BarAxisType>;

    public function new(x:BarAxisType, y:BarAxisType) {
        axis = AVConstructor.create(Axis2D, x, y);
    }
}

enum BarAxisType {
    Portion(slot:BarAxisSlot<PortionBarAxisDescr, PortionTransformApplier>);
    FixedThikness(slot:BarAxisSlot<FixedThiknessDescr, FixedThiknessTransformApplier>);
}

class BarAxisSlot<TDescr, TInst:BarAxisBase> {
    public var descr:TDescr;
    public var instance:TInst;

    public function new(d, i) {
        this.descr = d;
        this.instance = i;
    }
}

class BarAxisBase {
    public var componentWriter:IValueWriter;

    public function writePositions(a:Axis2D, tr:(Axis2D, Float) -> Float, target:Bytes, writer:AttributeWriters, vertOffset = 0):Void {
        throw "not implemented";
    }
}

typedef FixedThiknessDescr = {
    var thikness:Float;
    var pos:Float;
}

class FixedThiknessTransformApplier extends BarAxisBase {
    var weights:ReadOnlyArray<Float>;
    public var pos:Float = 0;
    public var thikness:Float = 0.1;
    var lineScales:ReadOnlyAVector2D<Float>;


    public function new(weights, lineScales) {
        this.weights = weights;
        this.lineScales = lineScales;
    }

    override public function writePositions(a:Axis2D, tr:(Axis2D, Float) -> Float, target:Bytes, writer:AttributeWriters, vertOffset = 0):Void {
        var localTh = lineScales[a] * thikness;
        var totalWidth = 1 - localTh;
        var lPos = totalWidth * pos;
        for (i in 0...weights.length) {
            writer[a].setValue(target, vertOffset + i, tr(a, lPos + weights[i] * (lineScales[a] )));
        }
    }
}

typedef PortionBarAxisDescr = {
    var start:Float;
    var end:Float;
}

class PortionTransformApplier extends BarAxisBase {
    var weights:ReadOnlyArray<Float>;
    public var start:Float = 0;
    public var end:Float = 1;

    public function new(weights) {
        this.weights = weights;
    }

    override public function writePositions(a:Axis2D, tr:(Axis2D, Float) -> Float, target:Bytes, writer:AttributeWriters, vertOffset = 0):Void {
        for (i in 0...weights.length) {
            writer[a].setValue(target, vertOffset + i, tr(a, start + weights[i] * (end - start)));
        }
    }
}

class BarsBuilder {
    var lineScales:ReadOnlyAVector2D<Float>;

    public function new(aspectRatio:AspectRatio, lineScales:ReadOnlyAVector2D<Float>) {
        this.lineScales = lineScales;
    }

    public function createAxis(axis:Axis2D, input:BarAxisType):BarAxisBase {
        switch input {
            case Portion(slot) :
                var apl = new PortionTransformApplier(RectWeights.weights[axis]);
                apl.start = slot.descr.start;
                apl.end = slot.descr.end;
                slot.instance = apl;
                return apl;
            case FixedThikness(slot):
                var apl = new FixedThiknessTransformApplier(RectWeights.weights[axis], lineScales);
                apl.pos = slot.descr.pos;
                apl.thikness = slot.descr.thikness;
                slot.instance = apl;
                return apl;
        }
    }

    public function create(attrs, tr, container:BarContainer) {
        return new Bar(attrs,
        createAxis(horizontal, container.axis[horizontal]),
        createAxis(vertical, container.axis[vertical])
        );
    }
}

class BarAnimationUtils {
    public static function directUnfold(bar:BarContainer, axis = null):Float -> Void {
        if (axis != null) {
            switch bar.axis[axis] {
                case Portion(slot):
                    return (t) -> slot.instance.end = t * slot.descr.end;
                case _:
            }
        }
        for (a in Axis2D) {
            switch bar.axis[a] {
                case Portion(slot):
                    return (t) -> slot.instance.end = t * slot.descr.end;
                case _:
            }
        }
        return (_) -> {};
    }
}