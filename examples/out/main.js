(function ($global) { "use strict";
var Shapes = function() { };
Shapes.main = function() {
	console.log("Shapes.hx:3:","shapes");
};
var haxe_iterators_ArrayIterator = function(array) {
	this.current = 0;
	this.array = array;
};
haxe_iterators_ArrayIterator.prototype = {
	hasNext: function() {
		return this.current < this.array.length;
	}
	,next: function() {
		return this.array[this.current++];
	}
};
Shapes.main();
})({});
