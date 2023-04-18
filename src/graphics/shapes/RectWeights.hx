package graphics.shapes;

import macros.AVConstructor;
import Axis2D;
import haxe.ds.ReadOnlyArray;

class RectWeights {
    // TODO replace with avector
    public static var weights:ReadOnlyAVector2D<ReadOnlyArray<Float>> = AVConstructor.create([0., 0., 1., 1.], [0., 1., 0., 1.]);

    public static inline function identity():AVector2D<Array<Float>> {
        return AVConstructor.create(weights[horizontal].copy(), weights[vertical].copy());
    }

    // public static var weights:Map<Axis2D, ReadOnlyArray<Float>> = [
    //     horizontal => [0, 0, 1, 1],
    //     vertical => [0, 1, 0, 1]
    // ];
    public static inline function apply(target:AVector2D<Array<Float>>, axis:Axis2D, pos:Float, size:Float) {
        for (i in 0...weights[axis].length)
            target[axis][i] = pos + size * weights[axis][i];
    }
}
