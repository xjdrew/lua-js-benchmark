// Fannkuch-redux benchmark
// Print checksum and max flips count

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 10;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

function fannkuch(n) {
    var perm = new Array(n);
    var perm1 = new Array(n);
    var count = new Array(n);
    var maxFlipsCount = 0;
    var checksum = 0;
    var permCount = 0;

    for (var i = 0; i < n; i++) {
        perm1[i] = i;
    }

    var r = n;
    while (true) {
        while (r !== 1) {
            count[r - 1] = r;
            r--;
        }

        for (var i = 0; i < n; i++) {
            perm[i] = perm1[i];
        }

        var flipsCount = 0;
        var k;

        while ((k = perm[0]) !== 0) {
            var k2 = (k + 1) >> 1;
            for (var i = 0; i < k2; i++) {
                var temp = perm[i];
                perm[i] = perm[k - i];
                perm[k - i] = temp;
            }
            flipsCount++;
        }

        if (flipsCount > maxFlipsCount) {
            maxFlipsCount = flipsCount;
        }

        if (permCount % 2 === 0) {
            checksum += flipsCount;
        } else {
            checksum -= flipsCount;
        }
        permCount++;

        // Generate next permutation
        while (true) {
            if (r === n) {
                return [checksum, maxFlipsCount];
            }

            var perm0 = perm1[0];
            var i = 0;
            while (i < r) {
                var j = i + 1;
                perm1[i] = perm1[j];
                i = j;
            }
            perm1[r] = perm0;

            count[r]--;
            if (count[r] > 0) {
                break;
            }
            r++;
        }
    }
}

var result = fannkuch(N);
print(result[0]);
print("Pfannkuchen(" + N + ") = " + result[1]);
