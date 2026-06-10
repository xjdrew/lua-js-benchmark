# Contributing to lua-js-benchmark

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Ways to Contribute

- **Add a new engine** (e.g., Luau, JSC, Hermes)
- **Add new benchmarks** to improve coverage
- **Fix bugs** in build scripts or the runner
- **Improve reports** with better visualizations
- **Test on new platforms** and report issues
- **Improve documentation**

## Adding a New Engine

1. Create `scripts/build_<engine>.sh`:
   - Download source code to `.build/src/<engine>/`
   - Compile with release optimizations
   - Install binary to `.build/engines/<engine>/bin/`
   - Verify the binary works
2. Add download logic to `scripts/download_sources.sh`
3. Register the engine in `runner/config.sh`:
   - `ENGINE_BIN[<engine>]` — path to binary
   - `ENGINE_LANG[<engine>]` — `lua` or `js`
   - `ENGINE_ARGS[<engine>]` — runtime arguments (if any)
   - Add category directory mapping in `CATEGORY_DIR_JS` if needed
4. Test: `make setup ENGINES=<engine> && make bench ENGINES=<engine>`

## Adding a New Benchmark

1. Write both Lua (`benchmarks/lua/<category>/<name>.lua`) and JS (`benchmarks/js/<js-category>/<name>.js`) versions
2. Requirements:
   - Accept problem size via command line argument (`arg[1]` in Lua, `scriptArgs[1]` in JS)
   - Print deterministic output (same input = same output, every time)
   - Both versions must produce **identical output** for the same input
   - Use idiomatic language patterns, not mechanical translations
   - No external dependencies
3. Generate expected output: `lua benchmarks/lua/<category>/<name>.lua > benchmarks/expected/<category>/<name>.txt`
4. Verify with all engines: run on Lua, LuaJIT, QuickJS and check output matches

### JS Compatibility

JS benchmarks must work with both QuickJS and V8 (d8). Use this portable pattern:

```js
const print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
const N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;
```

## Code Style

- Shell scripts: use `set -euo pipefail`, 4-space indentation
- Python: standard library only (no pip dependencies for core functionality)
- Keep scripts self-contained and readable
- Prefer clarity over cleverness

## Reporting Issues

When reporting issues, please include:

- OS and architecture (`uname -a`)
- Which engine(s) are affected
- Full error output
- Steps to reproduce

## Pull Requests

1. Fork the repository
2. Create a feature branch
3. Test on at least one platform (Linux or macOS)
4. Ensure `make all ENGINES="lua luajit quickjs"` passes
5. Submit a PR with a clear description of what and why
