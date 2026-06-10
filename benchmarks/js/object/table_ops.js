// Mixed object operations benchmark
// String key insert, nested lookup, iteration, delete, merge
// Representative of config/data processing patterns

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 500000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

// Phase 1: Insert key-value pairs with string keys
var data = {};
for (var i = 1; i <= N; i++) {
    data["item_" + i] = { id: i, value: i * 3, tags: ["a", "b"] };
}

// Phase 2: Nested lookups
var lookup_sum = 0;
for (var i = 1; i <= N; i++) {
    var entry = data["item_" + i];
    if (entry) {
        lookup_sum += entry.value + entry.id;
    }
}

// Phase 3: Iterate and accumulate
var iter_sum = 0;
var count = 0;
var keys = Object.keys(data);
for (var i = 0; i < keys.length; i++) {
    iter_sum += data[keys[i]].value;
    count++;
}

// Phase 4: Delete half the entries
for (var i = 1; i <= N; i += 2) {
    delete data["item_" + i];
}

// Phase 5: Merge remaining into new object
var merged = {};
var merge_count = 0;
var remainingKeys = Object.keys(data);
for (var i = 0; i < remainingKeys.length; i++) {
    merged[remainingKeys[i]] = data[remainingKeys[i]];
    merge_count++;
}

print(lookup_sum);
print(iter_sum);
print(count);
print(merge_count);
