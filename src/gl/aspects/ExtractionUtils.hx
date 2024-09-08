package gl.aspects;

import gl.aspects.UniformAspect.Uniform4fAspect;

class ExtractionUtils {
	public static function colorUniformExtractor(xml:Xml) {
		var color = new utils.RGBA(if (xml.exists("color")) Std.parseInt(xml.get("color")) else 0xffffff);
		return new Uniform4fAspect("color", color.r / 255, color.g / 255, color.b / 255, color.a / 255);
	}
}
