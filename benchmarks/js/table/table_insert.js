// Table insert benchmark
// Insert N key-value pairs into a Map, then sum all values.
// Uses Map (not Object) so this measures the JS hash-map fast path,
// which is the structural counterpart of a Lua table used as a dict.

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 1000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var t = new Map();
for (var i = 1; i <= N; i++) {
    t.set("key_" + i, i);
}

var sum = 0;
for (var v of t.values()) {
    sum += v;
}

print(sum);
