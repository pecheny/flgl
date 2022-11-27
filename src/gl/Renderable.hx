package gl;
interface Renderable<T:AttribSet> {
    function render(targets:RenderTarget<T>):Void;
}
