// FASTA benchmark - generate random DNA sequences
// Uses linear congruential generator

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 5000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var IM = 139968;
var IA = 3877;
var IC = 29573;
var seed = 42;

function random(max) {
    seed = (seed * IA + IC) % IM;
    return max * seed / IM;
}

var chars = "acgtBDHKMNRSVWY";
var probs = [
    0.27, 0.12, 0.12, 0.27,
    0.02, 0.02, 0.02, 0.02,
    0.02, 0.02, 0.02, 0.02,
    0.02, 0.02, 0.02
];

// Build cumulative probabilities
var cumulative = [];
var cp = 0;
for (var i = 0; i < probs.length; i++) {
    cp += probs[i];
    cumulative.push(cp);
}

function selectChar(r) {
    for (var i = 0; i < cumulative.length; i++) {
        if (r < cumulative[i]) {
            return chars[i];
        }
    }
    return chars[chars.length - 1];
}

var lastChar;
for (var i = 0; i < N; i++) {
    var r = random(1.0);
    lastChar = selectChar(r);
}

print(lastChar);
print(seed);
