// Ackermann function benchmark

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 10;
var M = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function ack(m, n) {
    if (m === 0) {
        return n + 1;
    } else if (n === 0) {
        return ack(m - 1, 1);
    } else {
        return ack(m - 1, ack(m, n - 1));
    }
}

var result = ack(3, M);
print("Ack(3," + M + "): " + result);
