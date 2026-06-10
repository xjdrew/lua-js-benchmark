// Spectral norm benchmark
// Compute spectral norm approximation for size N

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 500;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function A(i, j) {
    return 1.0 / ((i + j) * (i + j + 1) / 2 + i + 1);
}

function multiplyAv(n, v, av) {
    for (var i = 0; i < n; i++) {
        av[i] = 0.0;
        for (var j = 0; j < n; j++) {
            av[i] += A(i, j) * v[j];
        }
    }
}

function multiplyAtv(n, v, atv) {
    for (var i = 0; i < n; i++) {
        atv[i] = 0.0;
        for (var j = 0; j < n; j++) {
            atv[i] += A(j, i) * v[j];
        }
    }
}

function multiplyAtAv(n, v, atav) {
    var u = new Array(n);
    multiplyAv(n, v, u);
    multiplyAtv(n, u, atav);
}

function spectralNorm(n) {
    var u = new Array(n);
    var v = new Array(n);

    for (var i = 0; i < n; i++) {
        u[i] = 1.0;
        v[i] = 0.0;
    }

    for (var i = 0; i < 10; i++) {
        multiplyAtAv(n, u, v);
        multiplyAtAv(n, v, u);
    }

    var vBv = 0.0;
    var vv = 0.0;
    for (var i = 0; i < n; i++) {
        vBv += u[i] * v[i];
        vv += v[i] * v[i];
    }

    return Math.sqrt(vBv / vv);
}

var result = spectralNorm(N);
print(result.toFixed(9));
