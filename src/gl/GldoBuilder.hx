package gl;

import ecbind.RenderableBinder;
import gl.ShaderRegistry.IShaderRegistry;
import gl.GLDisplayObject;
import ec.Entity;

// todo decouple / ifdef with slec
class GldoBuilder {
	var shaders:IShaderRegistry;

	public function new(s) {
		this.shaders = s;
	}

	public function getDrawcalls(e:Entity) {
		if (e.hasComponent(RenderableBinder))
			return e.getComponent(RenderableBinder);
		var dc = new RenderableBinder();
		e.addComponent(dc);
		return dc;
	}

	public function bindLayer<TA:AttribSet>(e:Entity, attrs:TA, type, name, gldo:GLDisplayObject<TA>) {
		var dc = getDrawcalls(e);
		if (dc.findLayer(attrs, name)!= null)
			throw 'e ${e.name} already has layer $attrs _ $name';
		gldo.name = name;
		var dc = getDrawcalls(e);
		dc.addLayer(attrs, gldo, name);
		return gldo;
	}
}
