// Sieve of Eratosthenes benchmark
// Byte Magazine "Byte Sieve" (1981), one of the earliest cross-language benchmarks
// Tests conditional loops with stride-based array writes

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 2000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var R = 10;
var count;

for (var r = 0; r < R; r++) {
    var flags = new Array(N + 1);
    for (var i = 2; i <= N; i++) {
        flags[i] = true;
    }

    count = 0;
    for (var i = 2; i <= N; i++) {
        if (flags[i]) {
            count++;
            if (i * i <= N) {
                for (var j = i * i; j <= N; j += i) {
                    flags[j] = false;
                }
            }
        }
    }
}

print(count);
