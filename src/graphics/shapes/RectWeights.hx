package graphics.shapes;
import macros.AVConstructor;
import Axis2D;
import haxe.ds.ReadOnlyArray;
class RectWeights {
    // TODO replace with avector
    public static var weights:ReadOnlyAVector2D<ReadOnlyArray<Float>> = AVConstructor.create([0., 0., 1., 1.], [0., 1., 0., 1.]);
    // public static var weights:Map<Axis2D, ReadOnlyArray<Float>> = [
    //     horizontal => [0, 0, 1, 1],
    //     vertical => [0, 1, 0, 1]
    // ];
}
