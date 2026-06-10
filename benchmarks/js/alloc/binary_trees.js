// The Computer Language Benchmarks Game
// https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
// Binary trees benchmark

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 15;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function make(depth) {
    if (depth === 0) {
        return [1];
    }
    depth -= 1;
    return [make(depth), make(depth)];
}

function check(node) {
    if (node[1]) {
        return 1 + check(node[0]) + check(node[1]);
    }
    return 1;
}

var minDepth = 4;
var maxDepth = N;
if (minDepth + 2 > maxDepth) {
    maxDepth = minDepth + 2;
}

var stretchDepth = maxDepth + 1;
print("stretch tree of depth " + stretchDepth + "\t check: " + check(make(stretchDepth)));

var longLived = make(maxDepth);

for (var depth = minDepth; depth <= maxDepth; depth += 2) {
    var iterations = 1 << (maxDepth - depth + minDepth);
    var sum = 0;
    for (var i = 0; i < iterations; i++) {
        sum += check(make(depth));
    }
    print(iterations + "\t trees of depth " + depth + "\t check: " + sum);
}

print("long lived tree of depth " + maxDepth + "\t check: " + check(longLived));
