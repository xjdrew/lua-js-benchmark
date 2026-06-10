# Benchmarks

[中文版](README_cn.md)

This directory contains 20 benchmark cases across 7 categories. Each benchmark has both a Lua and a JavaScript implementation that produce **identical output** for the same input, ensuring a fair comparison.

## Directory Structure

```
benchmarks/
├── lua/                  # Lua implementations (canonical source)
│   ├── compute/
│   ├── string/
│   ├── alloc/
│   ├── table/
│   ├── call/
│   ├── coroutine/
│   └── startup/
├── js/                   # JavaScript implementations
│   ├── compute/
│   ├── string/
│   ├── alloc/
│   ├── object/           # ← maps to Lua "table" category
│   ├── call/
│   ├── async/            # ← maps to Lua "coroutine" category
│   └── startup/
└── expected/             # Expected output files for correctness checks
```

The Lua directory is the canonical source for benchmark discovery. The runner scans `lua/` and resolves corresponding JS scripts via category mapping (`table` → `object`, `coroutine` → `async`).

## Benchmark Cases

### compute — CPU-bound numeric computation

| Benchmark | Source | Description |
|-----------|--------|-------------|
| mandelbrot | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | Mandelbrot set: iterate complex plane, count pixels inside the set |
| nbody | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | N-body simulation: Jovian planet orbit simulation using leapfrog integration |
| spectral_norm | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | Spectral norm: compute the largest singular value of an infinite matrix |
| fannkuch | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | Fannkuch-redux: generate permutations and count pancake flips |
| matrix | Original | Matrix multiplication (200×200, 3 rounds) using table-of-tables |

### string — String operations

| Benchmark | Source | Description |
|-----------|--------|-------------|
| fasta | Original | Generate random DNA sequences using a linear congruential generator |
| json_parse | Original | Build a JSON string of N objects and parse it with a recursive descent parser |
| string_concat | Original | Concatenate strings N times (using `table.concat` / array join) |

### alloc — GC pressure and memory allocation

| Benchmark | Source | Description |
|-----------|--------|-------------|
| binary_trees | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | Allocate and deallocate binary trees of increasing depth |
| object_churn | Original | Create N small tables/objects with 3 fields and sum all values |
| gc_stress | Original | Mixed short/long lived allocations — tests GC throughput under realistic pressure |

### table — Hash table / object property operations

| Benchmark | Source | Description |
|-----------|--------|-------------|
| table_insert | Original | Insert N key-value pairs into a table/object, then sum all values |
| array_access | Original | Create array, sum elements, reverse in-place, sum again |
| table_ops | Original | Mixed operations: string-key insert, nested lookup, iteration, delete, merge |

### call — Function call overhead and recursion

| Benchmark | Source | Description |
|-----------|--------|-------------|
| ackermann | Classic | Ackermann function `ack(3, 10)` — deep recursion stress test |
| fibonacci | Classic | Naive recursive Fibonacci — function call overhead measurement |
| queens | Classic | N-queens problem — count all solutions for N=13 |
| method_dispatch | Original | Metatable/prototype method dispatch — polymorphic OOP patterns |

### coroutine — Coroutine / generator context switching

| Benchmark | Source | Description |
|-----------|--------|-------------|
| scheduler | Original | 100 coroutines/generators each counting to N/100, round-robin scheduled |

Lua uses `coroutine.create`/`coroutine.resume`/`coroutine.yield`. JavaScript uses generator functions (`function*`/`yield`).

### startup — Engine cold-start time

| Benchmark | Source | Description |
|-----------|--------|-------------|
| empty | Original | Empty script — measures pure engine startup overhead |

## Output Equivalence

Every benchmark accepts a problem size via command-line argument (`arg[1]` in Lua, `scriptArgs[1]` or `process.argv[2]` in JS) and prints deterministic output.

Both the Lua and JS implementations of each benchmark must produce **byte-identical output** for the same input. The expected output files in `expected/` are generated from the Lua version and verified against all engines during benchmark runs.

To regenerate expected output:

```bash
lua benchmarks/lua/<category>/<name>.lua [args] > benchmarks/expected/<category>/<name>.txt
```

## JS Compatibility

JavaScript benchmarks must work with both QuickJS and V8 (d8). Use this portable pattern:

```js
const print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
const N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1]
    : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;
```

## Adding a New Benchmark

1. Write `benchmarks/lua/<category>/<name>.lua`
2. Write `benchmarks/js/<js-category>/<name>.js`
3. Ensure both produce identical output for the same input
4. Generate expected output: `lua benchmarks/lua/<category>/<name>.lua > benchmarks/expected/<category>/<name>.txt`
5. Verify on all available engines
6. The benchmark will be discovered automatically by the runner
