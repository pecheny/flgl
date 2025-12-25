package graphics.shapes;

import gl.sets.CircleSet;
import haxe.io.Bytes;
import Axis2D;
import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import al.core.WidgetContainer.Refreshable;
import graphics.shapes.WeightedGrid;
import macros.AVConstructor;

class NGridWeightsWriter implements Refreshable {
    var weights:AVector2D<Array<Float>>;
    var lineScale:ReadOnlyAVector2D<Float>;
    var cornerSize:Float;

    public function new(weights, lineScale, cornerSize) {
        this.weights = weights;
        this.lineScale = lineScale;
        this.cornerSize = cornerSize;
    }

    public function refresh() {
        for (a in Axis2D) {
            weights[a][1] = Math.min(cornerSize * lineScale[a], 0.5);
            weights[a][2] = Math.max(1 - cornerSize * lineScale[a], 0.5);
        }
    }
}

class EdgedBallon extends RoundNGrid {
    override function initInBuffer(target:Bytes, vertOffset:Int) {
        super.initInBuffer(target, vertOffset);
        var rad = new RadiusAtt(attrs, getVertsCount());
        rad.r2 = 1;
        rad.r1 = 1 - (1 / cornerSize);
        rad.r1 *= rad.r1;
        rad.writePostions(target, vertOffset, null);
    }

}

class FlatBallon extends RoundNGrid {
    override function initInBuffer(target:Bytes, vertOffset:Int) {
        super.initInBuffer(target, vertOffset);
        var rad = new RadiusAtt(attrs, getVertsCount());
        rad.r2 = 1;
        rad.r1 = 0;
        rad.writePostions(target, vertOffset, null);
    }
}
class RoundNGrid extends RoundWeightedGrid {
    static var uvWeights = AVConstructor.create(Axis2D, [0, 0.4999, 0.50001, 1], [0, 0.4999, 0.50001, 1]);

    // ? equivalent of corner radius expressed in line thickness
    public var cornerSize = 3;

    public function new(ph:Placeholder2D, color = 0, cornerSize = 3) {
        this.cornerSize = cornerSize;
        super(ph, AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0, 0.5, 0.5, 1]), uvWeights, color);
    }

    override function createGridWriter(ph:Placeholder2D, wwr):Refreshable {
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);
        return new NGridWeightsWriter(wwr.weights, steps.getRatio(), cornerSize);
    }
}
