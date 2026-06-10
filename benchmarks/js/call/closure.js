// Closure benchmark
// Tests closure creation, upvalue capture/mutation, and function composition
// Classic funarg patterns from 1970s onward, common in production callback code

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 10000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function make_adder(k) {
    return function(x) { return x + k; };
}

function make_counter(init) {
    var n = init;
    return function(delta) {
        n += delta;
        return n;
    };
}

function compose(f, g) {
    return function(x) { return f(g(x)); };
}

var add1 = make_adder(1);
var add2 = make_adder(2);
var add3 = compose(add1, add2);

var counters = [];
for (var i = 0; i < 10; i++) {
    counters.push(make_counter(0));
}

var sum = 0;
for (var i = 1; i <= N; i++) {
    sum += add3(i);

    var c = counters[i % 10];
    sum += c(1);

    if (i % 10000 === 0) {
        var adder = make_adder(i);
        sum += adder(i);
    }
}

print(sum);
