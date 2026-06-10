// String concatenation benchmark
// Concatenate "x" N times using array push + join

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 5000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var arr = [];
for (var i = 0; i < N; i++) {
    arr.push("x");
}
var result = arr.join("");

print(result.length);
