// GC stress benchmark
// Mixed short/long lived allocations to test garbage collector throughput

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 2000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

// Long-lived data structure (survives entire benchmark)
var registry = [];
var registry_size = 1000;

for (var i = 0; i < registry_size; i++) {
    var entry = { id: i + 1, data: [], refs: [] };
    for (var j = 0; j < 10; j++) {
        entry.data.push((j + 1) * (i + 1));
    }
    registry.push(entry);
}

var sum = 0;
var temp_pool = new Array(100);

for (var i = 1; i <= N; i++) {
    // Short-lived: create small objects that die immediately
    var obj = { x: i, y: i * 2, z: i * 3 };
    sum += obj.x + obj.y + obj.z;

    // Medium-lived: rotate through a pool
    var slot = (i - 1) % 100;
    temp_pool[slot] = { value: i, prev: temp_pool[slot] };

    // Periodically update long-lived structures
    if (i % 1000 === 0) {
        var idx = ((i / 1000) - 1) % registry_size;
        var e = registry[idx];
        e.refs.push({ ts: i, val: sum });
        // Trim to prevent unbounded growth
        if (e.refs.length > 10) {
            e.refs = [e.refs[e.refs.length - 1]];
        }
    }
}

// Verify long-lived data survived
var reg_sum = 0;
for (var i = 0; i < registry_size; i++) {
    for (var j = 0; j < 10; j++) {
        reg_sum += registry[i].data[j];
    }
}

print(sum);
print(reg_sum);
