package ecbind;
#if slec
import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import gl.AttribSet;
import gl.GLDisplayObject;
import Type;
class RenderableBinder implements CtxBinder {
    var map = new GLDisplayObjectsCollection();

    public function new() {}

    public function addLayer<T:AttribSet>(set:T, layer:GLDisplayObject<T>, name = "") {
        var id = getLayerId(set, name);
        if (map.exists(id))
            throw "Already has layer with id " + id;
        map.set(id, layer);
    }

    public function bind(e:Entity) {
        var keys = map.keys();
        for (key in keys) {
            var ddp:RenderablesComponent<AttribSet> = e.getComponentByName(key);
            if (ddp == null)
                continue;
            var l = map.get(cast key);
            for (v in ddp.views)
                l.addView(v);
        }
    }

    public function unbind(e:Entity) {
        var keys = map.keys();
        for (key in keys) {
            var ddp:RenderablesComponent<AttribSet> = e.getComponentByName(key);
            if (ddp == null)
                continue;
            var l = map.get(cast key);
            for (v in ddp.views)
                l.removeView(v);
        }
    }

    public function findLayer<T:AttribSet>(attrs:T, layerName) {
        return map.get(getLayerId(attrs, layerName));
    }

    public static function getLayerId<T:AttribSet>(set:T, layerName:String) {
        return new LayerId(set, layerName);
    }
}

abstract LayerId<T:AttribSet>(String) to String {
    public inline function new(set:T, n:String) {
        this = Type.getClassName(Type.getClass(set)) + "_" + n;
    }
}

@:forward(keys, exists)
abstract GLDisplayObjectsCollection(Map<String, GLDisplayObject<AttribSet>>) {
    public function new() {
        this = new Map();
    }

    public inline function get<T:AttribSet>(lId:LayerId<T>):GLDisplayObject<T> {
        return cast this.get(lId);
    }

    public inline function set<T:AttribSet>(lId:LayerId<T>, l:GLDisplayObject<T>) {
        this.set(lId, cast l);
    }
}
#end