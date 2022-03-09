package gl;
import bindings.GLProgram;
import bindings.WebGLRenderContext;
interface Bindable {
    function bind():Void;

    function unbind():Void;
}

interface GLInitable {
    public function init(gl:WebGLRenderContext, program:GLProgram):Void;
}

interface RenderingAspect extends Bindable extends GLInitable {
}

interface RenderingElementsFactory {
    function newChain():RenderingElementsFactory;

    function add(re:RenderingAspect):RenderingElementsFactory;

    function build():RenderingAspect;
}

class RenderingAspects implements RenderingAspect {
    var children:Array<RenderingAspect>;

    public function new(children) {
        this.children = children;
    }

    public function bind():Void {
        for (c in children)
            c.bind();
    }

    public function unbind():Void {
        for (c in children)
            c.unbind();
    }

    public function init(gl:WebGLRenderContext, program:GLProgram):Void {
        for (c in children)
            c.init(gl, program);
    }

}

class RenderAspectBuilder implements RenderingElementsFactory {
    // для элементов не зваисящих от шейдерной программы
    // для зависящих вместо массива надоделать фабрику
    var sharedAspects:Array<RenderingAspect>;
    var instance:Array<RenderingAspect>;

    public function new(sharedAspects) {
        this.sharedAspects = sharedAspects;
    }

    public function newChain() {
        instance = [];
        return this;
    }

    public function add(re:RenderingAspect) {
        instance.push(re);
        return this;
    }

    public function build() {
        if (instance == null) throw "start new chain before build()";
        var result =
        if (sharedAspects.length + instance.length == 0)
            null;
        else if (instance.length == 0) {
            if (sharedAspects.length > 1)
                new RenderingAspects(sharedAspects);
            else
                sharedAspects[0];
        }
        else if (sharedAspects.length == 0) {
            if (instance.length > 1)
                new RenderingAspects(instance);
            else
                instance[0];
        } else
            new RenderingAspects(sharedAspects.concat(instance));
        instance = null;
        return result;
    }
}