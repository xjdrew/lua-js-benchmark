// Mandelbrot set benchmark
// Counts pixels inside the Mandelbrot set for an NxN grid
// Iteration limit: 50, escape radius: 4.0

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 1500;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function mandelbrot(size) {
    var count = 0;
    var maxIter = 50;
    var escapeRadius = 4.0;

    for (var y = 0; y < size; y++) {
        for (var x = 0; x < size; x++) {
            var cr = 2.0 * x / size - 1.5;
            var ci = 2.0 * y / size - 1.0;

            var zr = 0.0;
            var zi = 0.0;
            var i = 0;

            while (i < maxIter) {
                var tr = zr * zr - zi * zi + cr;
                var ti = 2.0 * zr * zi + ci;
                zr = tr;
                zi = ti;
                if (zr * zr + zi * zi > escapeRadius) {
                    break;
                }
                i++;
            }

            if (i === maxIter) {
                count++;
            }
        }
    }

    return count;
}

var result = mandelbrot(N);
print(result);
