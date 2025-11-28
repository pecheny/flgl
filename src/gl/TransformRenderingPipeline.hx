package gl;

import gl.passes.PassBase;
import gl.RenderingPipeline;

class TransformRenderingPipeline extends RenderingPipeline {
    override public function addPass<TAtt:AttribSet>(type:DrawcallType, p:PassBase<TAtt>) {
        var withTransform = p.clone();
        withTransform.uniforms.push(shaderbuilder.ProjectionMatrixElement.matrix);
        withTransform.vertElems.push(shaderbuilder.ProjectionMatrixElement.instance);
        withTransform.alias.push(shaderbuilder.ProjectionMatrixElement.alias);
        super.addPass(type, withTransform);
    }
}
