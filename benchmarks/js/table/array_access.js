// Array access benchmark
// Create array, sum elements, reverse in-place, sum again

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 20000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var arr = new Array(N);
for (var i = 0; i < N; i++) {
    arr[i] = (i + 1) % 100;
}

// First sum
var sum1 = 0;
for (var i = 0; i < N; i++) {
    sum1 += arr[i];
}

// Reverse in-place
var half = Math.floor(N / 2);
for (var i = 0; i < half; i++) {
    var j = N - 1 - i;
    var tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
}

// Second sum
var sum2 = 0;
for (var i = 0; i < N; i++) {
    sum2 += arr[i];
}

print(sum1);
print(sum2);
