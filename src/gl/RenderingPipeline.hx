package gl;

import gl.GLNode;
import gl.aspects.RenderingAspect;
import gl.passes.PassBase;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder;
import utils.TextureStorage;

class RenderingPipeline {
    public var renderAspectBuilder(default, null):RenderAspectBuilder;
    public var textureStorage:TextureStorage;
    public var shaderRegistry:ShaderRegistry;

    var pos:ShaderElement = PosPassthrough.instance;

    public function new() {
        renderAspectBuilder = new RenderAspectBuilder();
        textureStorage = new TextureStorage();
        shaderRegistry = new ShaderRegistry();
    }

    public function addAspect(a:RenderingAspect) {
        renderAspectBuilder.addShared(a);
    }

    public function setPositioning(pos:ShaderElement) {
        this.pos = pos;
        return this;
    }

    public function createContainer(descr):GLNode {
        var node = processNode(descr);
        renderAspectBuilder.reset();
        return node;
    }

    var handlers:Map<String, PassBase<Dynamic>> = new Map();

    public function processNode(node:Xml, ?container:Null<ContainerGLNode>):GLNode {
        return switch (node.nodeName) {
            case "container": {
                    var c = new ContainerGLNode();
                    if (container != null)
                        container.addChild(c);
                    for (child in node.elements()) {
                        processNode(child, c);
                    }
                    c;
                }
            case "drawcall": {
                    var drawcallType = node.get("type");
                    if (!handlers.exists(drawcallType)) {
                        trace('No "$drawcallType" drawcall type was registered.');
                        return container;
                    }
                    var pass = handlers[drawcallType];
                    renderAspectBuilder.newChain();

                    if (aspectFactories.exists(drawcallType))
                        for (fac in aspectFactories.get(drawcallType))
                            renderAspectBuilder.add(fac(node));

                    var gldo = new ShadedGLNode(pass.attr, shaderRegistry.getState.bind(pass.attr, _, pass.getShaderAlias()), renderAspectBuilder.build());

                    if (aliases[drawcallType] != null)
                        for (a in aliases[drawcallType])
                            gldo.name += a(node); // pass.layerNameExtractor(node);
                    if (container != null)
                        container.addChild(gldo);
                    gldo;
                }
            case _:
                throw "wrong " + node.nodeName;
        }
    }

    var aspectFactories:Map<String, Array<Xml->RenderingAspect>> = new Map();
    var aliases:Map<String, Array<Xml->Null<String>>> = new Map();

    /**
        Implementation of the AspectFactory meant for constructing certain type of RenderingAspect according to the drawcall xml description.
        If several drawcalls of given type and differing only in properties of the RenderingAspect impl constructed by the factory has application in one place 
        (like similar shader with different textures), the factory should provide alias and return null otherwise.
        The alias meant for identifying drawcall by given properties, therefore it should be unique for each seat of values. 
        For example, if the aspect is a texture binder, the alias should stay same for one texture, but two different textures should have different aliases.
        The same alias convention should be used in the CtxWatcher for Renderable impl.
    **/
    public function addAspectExtractor(drawcallType, factory:Xml->RenderingAspect, ?alias:Xml->Null<String>) {
        if (!aspectFactories.exists(drawcallType))
            aspectFactories[drawcallType] = [];
        if (!aliases.exists(drawcallType) && alias != null)
            aliases[drawcallType] = [];
        if (alias != null)
            aliases[drawcallType].push(alias);

        aspectFactories[drawcallType].push(factory);
    }

    public function addPass<TAtt:AttribSet>(type:DrawcallType, p:PassBase<TAtt>) {
        shaderRegistry.reg(p.getShaderDesc());
        handlers[type] = p;
    }
}

/**
    Value for 'type' attribute in the xml drawcall description. Used as a key for pass and aspects factories registration.
**/
typedef DrawcallType = String;
