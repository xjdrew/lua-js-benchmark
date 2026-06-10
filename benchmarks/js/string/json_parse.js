// JSON parse benchmark
// Build a JSON string of N objects and parse it with recursive descent parser

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

// Simple recursive descent JSON parser (mirrors the Lua implementation)
var pos = 0;

function skip_ws() {
    while (pos < jsonStr.length) {
        var c = jsonStr.charCodeAt(pos);
        if (c === 32 || c === 9 || c === 10 || c === 13) {
            pos++;
        } else {
            break;
        }
    }
}

function parse_string() {
    pos++; // skip opening quote
    var start = pos;
    while (pos < jsonStr.length) {
        var c = jsonStr.charCodeAt(pos);
        if (c === 34) { // closing quote
            var s = jsonStr.substring(start, pos);
            pos++;
            return s;
        } else if (c === 92) { // backslash
            pos += 2;
        } else {
            pos++;
        }
    }
    throw new Error("unterminated string");
}

function parse_number() {
    var start = pos;
    while (pos < jsonStr.length) {
        var c = jsonStr.charCodeAt(pos);
        if (c === 44 || c === 93 || c === 125 || c === 32 || c === 9 || c === 10 || c === 13) {
            break;
        }
        pos++;
    }
    return Number(jsonStr.substring(start, pos));
}

function parse_array() {
    pos++; // skip [
    var arr = [];
    skip_ws();
    if (jsonStr.charCodeAt(pos) === 93) { // empty array
        pos++;
        return arr;
    }
    while (true) {
        skip_ws();
        arr.push(parse_value());
        skip_ws();
        var c = jsonStr.charCodeAt(pos);
        if (c === 44) { // comma
            pos++;
        } else if (c === 93) { // ]
            pos++;
            return arr;
        } else {
            throw new Error("expected , or ] at pos " + pos);
        }
    }
}

function parse_object() {
    pos++; // skip {
    var obj = {};
    skip_ws();
    if (jsonStr.charCodeAt(pos) === 125) { // empty object
        pos++;
        return obj;
    }
    while (true) {
        skip_ws();
        var key = parse_string();
        skip_ws();
        pos++; // skip :
        skip_ws();
        obj[key] = parse_value();
        skip_ws();
        var c = jsonStr.charCodeAt(pos);
        if (c === 44) { // comma
            pos++;
        } else if (c === 125) { // }
            pos++;
            return obj;
        } else {
            throw new Error("expected , or } at pos " + pos);
        }
    }
}

function parse_value() {
    skip_ws();
    var c = jsonStr.charCodeAt(pos);
    if (c === 34) { // "
        return parse_string();
    } else if (c === 91) { // [
        return parse_array();
    } else if (c === 123) { // {
        return parse_object();
    } else if (c === 116) { // true
        pos += 4;
        return true;
    } else if (c === 102) { // false
        pos += 5;
        return false;
    } else if (c === 110) { // null
        pos += 4;
        return null;
    } else {
        return parse_number();
    }
}

// Parse
pos = 0;
var data = parse_value();

// Sum all id fields
var idSum = 0;
var count = 0;
for (var j = 0; j < data.length; j++) {
    idSum += data[j].id;
    count++;
}

print(idSum);
print(count);
