package graphics.shapes;

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

class RoundTGrid extends RoundWeightedGrid {
    static var uvWeights = AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]);

    public function new(ph:Placeholder2D, color) {
        super(ph, AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]), uvWeights, color);
    }

    override function createGridWriter(ph, wwr):Refreshable {
        return new TGridWeightsWriter(ph, wwr);
    }
}