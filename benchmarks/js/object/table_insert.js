// Table insert benchmark
// Insert N key-value pairs, then sum all values

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 1000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var t = {};
for (var i = 1; i <= N; i++) {
    t["key_" + i] = i;
}

var sum = 0;
var keys = Object.keys(t);
for (var j = 0; j < keys.length; j++) {
    sum += t[keys[j]];
}

print(sum);
