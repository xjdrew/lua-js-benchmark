// Matrix multiplication benchmark
// Multiply two NxN matrices using array-of-arrays representation
// Tests nested array access + numerical computation

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 200;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function make_matrix(rows, cols, init_fn) {
    var m = new Array(rows);
    for (var i = 0; i < rows; i++) {
        m[i] = new Array(cols);
        for (var j = 0; j < cols; j++) {
            m[i][j] = init_fn(i + 1, j + 1);
        }
    }
    return m;
}

function multiply(a, b, n) {
    var c = new Array(n);
    for (var i = 0; i < n; i++) {
        c[i] = new Array(n);
        for (var j = 0; j < n; j++) {
            var sum = 0.0;
            for (var k = 0; k < n; k++) {
                sum += a[i][k] * b[k][j];
            }
            c[i][j] = sum;
        }
    }
    return c;
}

// Initialize matrices (using 1-based logic for same values as Lua)
var A = make_matrix(N, N, function(i, j) { return (i + j - 1) % 7 + 1.0; });
var B = make_matrix(N, N, function(i, j) { return (i * j) % 11 + 1.0; });

// Multiply 3 times: C = A*B, D = C*B, E = D*B
var C = multiply(A, B, N);
var D = multiply(C, B, N);
var E = multiply(D, B, N);

// Checksum: sum of corner elements (0-indexed)
var checksum = E[0][0] + E[0][N-1] + E[N-1][0] + E[N-1][N-1];
print(checksum.toFixed(6));
