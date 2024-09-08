package gl.aspects;

import utils.TextureStorage;
import gl.aspects.UniformAspect.Uniform4fAspect;

class ExtractionUtils {
	public static function colorUniformExtractor(xml:Xml) {
		var color = new utils.RGBA(if (xml.exists("color")) Std.parseInt(xml.get("color")) else 0xffffff);
		return new Uniform4fAspect("color", color.r / 255, color.g / 255, color.b / 255, color.a / 255);
	}
}

class TextureAspectFactory {
	var textureStorage:TextureStorage;

	public function new(textures) {
		this.textureStorage = textures;
	}

	public function create(xml:Xml) {
		if (!xml.exists("path"))
			throw '<image /> gldo should have path property';
		return new TextureBinder(textureStorage, xml.get("path"));
	}

	public function getAlias(xml:Xml) {
		if (!xml.exists("path"))
			throw '<image /> gldo should have path property';
		return xml.get("path");
	}
}

