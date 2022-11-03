package graphics;

class ShapeRenderer {
    var buffer:Bytes;
    var posWriter:AttributeWriters;
    var children:Array<Shape> = [];
    var vertsCount:Int = 0;
    var inds:IndexCollection;
    var attrs:T;
    var inited = false;

    public function new(attrs:T:Widget2D) {
        this.attrs = attrs;
        posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
    }

    public function addChild(shape:Shape) {
        if (inited) throw "Can't add children after initialization";
        children.push(shape);
    }

    @:once var ratioProvider:AspectRatioProvider;
    @:once var transformer:LiquidTransformer;

    override function init() {
        createShapes();
        initChildren();
        inited = true;
        onShapesDone();
    }

    function createShapes() {}

    function onShapesDone() {}

    function initChildren() {
        var indsCount = 0;
        vertsCount = 0;
        for (sh in children) {
            vertsCount += sh.getVertsCount();
            indsCount += sh.getIndices().length;
        }
        buffer = Bytes.alloc(vertsCount * attrs.stride);
        inds = new IndexCollection(indsCount);
        fillIndices();
    }

    function fillIndices() {
        var indNum = 0;
        var vertNum = 0;
        for (sh in children) {
            var shInds = sh.getIndices();
            for (i in 0...shInds.length) {
                inds[indNum + i] = shInds[i] + vertNum;
            }
            vertNum += sh.getVertsCount();
            indNum += shInds.length;
        }
    }


    public function render(targets:RenderTargets<T>):Void {
        if (!inited)
            return;
        targets.blitIndices(inds, inds.length);
        var pos = 0;
        for (sh in children) {
            sh.writePostions(buffer, posWriter, pos);
            pos += sh.getVertsCount();
        }
        targets.blitVerts(buffer, vertsCount);
    }

    function printVerts(n) {
        for (i in 0...n)
            trace(i + " " + attrs.printVertex(buffer, i));
    }
} 