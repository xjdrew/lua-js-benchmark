// Mixed map operations benchmark
// String key insert, nested lookup, iteration, delete, merge
// Representative of config/data processing patterns
// Uses Map (not Object) for fair comparison with Lua tables-as-dict:
// Map provides O(1) delete, prototype-free lookups, and direct iteration
// without an Object.keys snapshot.

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 500000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

// Phase 1: Insert key-value pairs with string keys
var data = new Map();
for (var i = 1; i <= N; i++) {
    data.set("item_" + i, { id: i, value: i * 3, tags: ["a", "b"] });
}

// Phase 2: Nested lookups
var lookup_sum = 0;
for (var i = 1; i <= N; i++) {
    var entry = data.get("item_" + i);
    if (entry) {
        lookup_sum += entry.value + entry.id;
    }
}

// Phase 3: Iterate and accumulate
var iter_sum = 0;
var count = 0;
for (var v of data.values()) {
    iter_sum += v.value;
    count++;
}

// Phase 4: Delete half the entries
for (var i = 1; i <= N; i += 2) {
    data.delete("item_" + i);
}

// Phase 5: Merge remaining into new map
var merged = new Map();
var merge_count = 0;
for (var entry of data) {
    merged.set(entry[0], entry[1]);
    merge_count++;
}

print(lookup_sum);
print(iter_sum);
print(count);
print(merge_count);
