// N-queens benchmark
// Count all solutions to the N-queens problem

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 13;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var count = 0;
var cols = {};
var diag1 = {};
var diag2 = {};

function solve(row) {
    if (row > N) {
        count++;
        return;
    }
    for (var col = 1; col <= N; col++) {
        var d1 = row - col + N;
        var d2 = row + col;
        if (!cols[col] && !diag1[d1] && !diag2[d2]) {
            cols[col] = true;
            diag1[d1] = true;
            diag2[d2] = true;
            solve(row + 1);
            delete cols[col];
            delete diag1[d1];
            delete diag2[d2];
        }
    }
}

solve(1);
print(count + " solutions for " + N + "-queens");
