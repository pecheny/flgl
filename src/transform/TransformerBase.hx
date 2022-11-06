package transform;
import al.al2d.Boundbox;
import al.core.AxisApplier;
import al.utils.Signal;
import Axis2D;
import macros.AVConstructor;
/**
* Transformer provide a function to translate normalized coordinates (i.e. lacated in [0,1] range) into widget bounds.
**/

class TransformerBase {
    var appliers:AVector2D<TransformatorAxisApplier>;

    public var aspects = AVConstructor.create(Axis2D, 1., 1.).readonly();
    public var size = AVConstructor.create(Axis2D, 1., 1.).readonly();
    public var pos = AVConstructor.create(Axis2D, 0., 0.).readonly();
    public var changed(default, null):Signal<Void -> Void> = new Signal();

    public function getAxisApplier(a:Axis2D):AxisApplier {
        return appliers[a];
    }

//todo make own boundbox, exclude al dependency
    var bounds:Boundbox = new Boundbox();

    public function new(aspects:ReadOnlyAVector2D<Float>) {
        this.aspects = aspects;
        appliers = AVConstructor.factoryCreate(k -> new TransformatorAxisApplier(this, k));
    }

    public function setBounds(x, y, w, h) {
        bounds.set(x, y, w, h);
    }

    public function invalidate() {}

    public function transformValue(c:Axis2D, input:Float):Float {throw "N/A";}
}

class TransformatorAxisApplier implements AxisApplier {
    var axisIntex:Axis2D;
    var target:TransformerBase;

    public function new(target:TransformerBase, c) {
        this.target = target;
        axisIntex = c;
    }

    public function apply(pos:Float, size:Float):Void {
        var p:AVector2D<Float> = cast target.pos;
        p[axisIntex] = pos;
        var s:AVector2D<Float> = cast target.size;
        s[axisIntex] = size;
        target.changed.dispatch();
    }
}