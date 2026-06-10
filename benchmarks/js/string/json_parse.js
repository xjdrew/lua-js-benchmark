// JSON parse benchmark
// Build a JSON string of N objects and parse it with JSON.parse

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 100000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

// Build JSON string
var parts = ["["];
for (var i = 0; i < N; i++) {
    if (i > 0) {
        parts.push(",");
    }
    parts.push('{"id":' + i + ',"name":"item_' + i + '","value":' + (i * 0.1).toFixed(1) + '}');
}
parts.push("]");
var jsonStr = parts.join("");

// Parse
var data = JSON.parse(jsonStr);

// Sum all id fields
var idSum = 0;
var count = 0;
for (var j = 0; j < data.length; j++) {
    idSum += data[j].id;
    count++;
}

print(idSum);
print(count);
