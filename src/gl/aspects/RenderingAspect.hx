package gl.aspects;
import gl.GLDisplayObject.GLState;


interface RenderingAspect {

    function bind(state:GLState<Dynamic>):Void ;

    function unbind(state:GLState<Dynamic>):Void ;
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

    public function bind(gl):Void {
        for (c in children)
            c.bind(gl);
    }

    public function unbind(gl):Void {
        for (c in children)
            c.unbind(gl);
    }
}

class RenderAspectBuilder implements RenderingElementsFactory {
    // для элементов не зваисящих от шейдерной программы
    // для зависящих вместо массива надоделать фабрику
    var sharedAspects:Array<RenderingAspect> = [];
    var instance:Array<RenderingAspect> = [];

    public function new() { }

    public function newChain() {
        instance = [];
        return this;
    }

    public function add(re:RenderingAspect) {
        instance.push(re);
        return this;
    }

    public function addShared(re:RenderingAspect) {
        sharedAspects.push(re);
        return this;
    }

    public function build() {
        if (instance == null) throw "start new chain before build()";
        var result =
        if (sharedAspects.length + instance.length == 0)
            null;
        else if (instance.length == 0) {
            if (sharedAspects.length > 1)
                new RenderingAspects(sharedAspects.copy());
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
        instance = [];
        return result;
    }
    
    public function reset() {
        sharedAspects.resize(0);
        instance = [];
    }
}