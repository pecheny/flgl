package graphics.shapes;

import gl.sets.CircleSet;
import haxe.io.Bytes;
import Axis2D;
import a2d.Placeholder2D;
import al.core.WidgetContainer.Refreshable;
import graphics.shapes.WeightedGrid;
import macros.AVConstructor;

class TGridWeightsWriter implements Refreshable {
    var wwr:WeightedAttWriter;
    var ph:Placeholder2D;

    public function new(ph, wwr) {
        this.ph = ph;
        this.wwr = wwr;
    }

    public function refresh() {
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w > h ? horizontal : vertical;
        wwr.direction = dir;
        var cdir = dir.other();
        var so = ph.axisStates[cdir].getSize() / ph.axisStates[dir].getSize();
        var aw = wwr.weights[horizontal];
        aw[1] = so * 0.5;
        aw[2] = 1 - so * 0.5;
    }
}

class EdgedBubble extends RoundTGrid {
    override function initInBuffer(target:Bytes, vertOffset:Int) {
        super.initInBuffer(target, vertOffset);
        var steps = a2d.transform.WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);
        var rad = new RadiusAtt(attrs, getVertsCount());
        new fu.graphics.CircleThicknessCalculator(ph, steps, cast rad, target, vertOffset);
    }

    var ph:Placeholder2D;

    override function createGridWriter(ph:Placeholder2D, wwr:WeightedAttWriter):Refreshable {
        this.ph = ph;
        return super.createGridWriter(ph, wwr);
    }
}

class FlatBubble extends RoundTGrid {
    override function initInBuffer(target:Bytes, vertOffset:Int) {
        super.initInBuffer(target, vertOffset);
        var rad = new RadiusAtt(attrs, getVertsCount());
        rad.r1 = 0;
        rad.r2 = 1;
        rad.writePostions(target, vertOffset, null);
    }
}

class RoundTGrid extends RoundWeightedGrid {
    static var uvWeights = AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]);

    public function new(ph:Placeholder2D, color) {
        super(ph, AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]), uvWeights, color);
    }

    override function createGridWriter(ph, wwr):Refreshable {
        return new TGridWeightsWriter(ph, wwr);
    }
}
