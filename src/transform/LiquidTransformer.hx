package transform;
import al.al2d.Widget2D;
import al.al2d.Boundbox;
import al.al2d.Axis2D;
using transform.LiquidTransformer.BoundboxConverters;
class LiquidTransformer extends TransformerBase {
    override public function transformValue(c:Axis2D, input:Float) {
        var a = Axis2D.fromInt(c);
        var sign = c == 0 ? 1 : -1;
        return
            sign *
            ((pos[c] + bounds.localToGlobal(a, input) * size[c]) / aspects.getFactor(c) - 1) ;
    }

    public static function withLiquidTransform(w:Widget2D, aspectRatio) {
        var transformer = new LiquidTransformer(aspectRatio);
        for (a in Axis2D.keys) {
            var applier2 = transformer.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        w.entity.addComponent(transformer);
        return w;
    }
}

class BoundboxConverters {
    public static inline function localToGlobal(bb:Boundbox, a:Axis2D, value:Float):Float {
        return bb.pos[a] + value / bb.size[a];
    }

    public static inline function globalToLocal(bb:Boundbox, a:Axis2D, value:Float):Float {
        return value * bb.size[a] - bb.pos[a];
    }
}


