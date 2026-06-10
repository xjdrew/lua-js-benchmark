// Generator scheduler benchmark
// Create 100 generators, each counting from 0 to N/100, round-robin schedule

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 100000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

var numGenerators = 100;
var perGenerator = Math.floor(N / numGenerators);

function* worker(limit) {
    for (var i = 0; i < limit; i++) {
        yield;
    }
}

// Create generators
var generators = new Array(numGenerators);
for (var i = 0; i < numGenerators; i++) {
    generators[i] = worker(perGenerator);
}

// Round-robin scheduler
var totalYields = 0;
var alive = numGenerators;
while (alive > 0) {
    for (var i = 0; i < numGenerators; i++) {
        var gen = generators[i];
        if (gen) {
            var result = gen.next();
            if (result.done) {
                generators[i] = null;
                alive--;
            } else {
                totalYields++;
            }
        }
    }
}

print(totalYields);
