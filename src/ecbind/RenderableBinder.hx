package ecbind;
import gl.GLNode.ShadedGLNode;
#if slec
import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import gl.AttribSet;
import Type;

/**
    Aims to put Renderable views from the descending hierarchy to the apropriate drawcall (GLNode) registered by attribute set and alias.
**/
@:build(ec.macros.Macros.buildGetOrCreate("onCreate"))
class RenderableBinder implements CtxBinder {
    var map = new ShadedGLNodesCollection();

    public function new() {}
    
    public function onCreate(e:Entity) {
        e.addComponent(this);
    }


    public function addLayer<T:AttribSet>(set:T, layer:ShadedGLNode<T>, name = "") {
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
    
    public function bindLayer<TA:AttribSet>(e:Entity, attrs:TA, name, gldo:ShadedGLNode<TA>) {
		if (findLayer(attrs, name) != null)
			throw 'e ${e.name} already has layer $attrs _ $name';
		gldo.name = name;
		addLayer(attrs, gldo, name);
		return gldo;
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
abstract ShadedGLNodesCollection(Map<String, ShadedGLNode<AttribSet>>) {
    public function new() {
        this = new Map();
    }

    public inline function get<T:AttribSet>(lId:LayerId<T>):ShadedGLNode<T> {
        return cast this.get(lId);
    }

    public inline function set<T:AttribSet>(lId:LayerId<T>, l:ShadedGLNode<T>) {
        this.set(lId, cast l);
    }
}
#end