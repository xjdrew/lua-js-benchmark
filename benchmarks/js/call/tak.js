// Takeuchi function benchmark
// Gabriel Benchmarks (1985), originally by Ikuo Takeuchi (1978)
// Tests deeply recursive triple-branching function calls

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 10;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function tak(x, y, z) {
    if (y >= x) return z;
    return tak(tak(x - 1, y, z), tak(y - 1, z, x), tak(z - 1, x, y));
}

var result = tak(N * 3, N * 2, N);
print(result);
