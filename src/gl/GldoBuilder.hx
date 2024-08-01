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

	public function getGldo(e:Entity, type, aspect, name) {
		var attrs = shaders.getAttributeSet(type);
		var dc = getDrawcalls(e);
		var gldo = dc.findLayer(attrs, name);
		if (gldo != null)
			return gldo;
		var gldo = new GLDisplayObject(attrs, shaders.getState.bind(attrs, _, type), aspect);
		gldo.name = name;
		var dc = getDrawcalls(e);
		dc.addLayer(attrs, gldo, name);
		return gldo;
	}
}
