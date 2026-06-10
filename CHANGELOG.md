# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] - 2026-06-10

### Added

- Initial release
- Engine support: Lua 5.4, LuaJIT 2.1, QuickJS, V8 (JIT and no-JIT)
- Automated environment setup: dependency checking, source download, compilation
- 16 benchmark cases across 7 categories: compute, string, alloc, table, call, coroutine, startup
- Dual-language benchmarks: each test case has both Lua and JavaScript implementations with verified identical output
- Benchmark runner with configurable warmup and iteration counts
- Report generation: Markdown tables + interactive HTML with Chart.js
- HTML report includes: stacked bar chart (overall), category comparison, radar chart, memory usage, detailed results table
- All comparisons use Lua 5.4 as baseline (1.00x)
- Support for selective engine/category benchmarking via `ENGINES` and `CATEGORY` parameters
- Per-engine download and build retry commands
- Platform support: Linux (x86_64, aarch64), macOS (x86_64, Apple Silicon)
- V8 stripped build: no WebAssembly, no ICU, no external startup data, no debug symbols
