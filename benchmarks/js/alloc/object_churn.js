// Object churn benchmark
// Create N small objects with 3 fields and sum all values

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 1000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var sum = 0;
for (var i = 0; i < N; i++) {
    var obj = { x: i, y: i * 2, z: i * 3 };
    sum += obj.x + obj.y + obj.z;
}

print(sum);
