# lua-js-benchmark

[![CI](https://github.com/xjdrew/lua-js-benchmark/actions/workflows/ci.yml/badge.svg)](https://github.com/xjdrew/lua-js-benchmark/actions/workflows/ci.yml)

[中文版](README_cn.md)

Automated performance comparison of Lua and JavaScript engines. Build from source, run standardized benchmarks, and generate visual reports — all with a single command.

## Engines

| Engine | Language | Description |
|--------|----------|-------------|
| **Lua 5.4** | Lua | Official PUC-Rio interpreter (baseline for all comparisons) |
| Lua 5.5 | Lua | Latest PUC-Rio interpreter |
| LuaJIT 2.1 | Lua | High-performance JIT-compiled Lua |
| QuickJS | JavaScript | Lightweight embeddable JS engine (Fabrice Bellard) |
| V8 (JIT) | JavaScript | Chrome's JS engine with JIT compilation |
| V8 (no-JIT) | JavaScript | Chrome's JS engine in interpreter-only mode (`--jitless`) |

**Planned:** Luau, JavaScriptCore (JSC)

## Quick Start

```bash
git clone https://github.com/xjdrew/lua-js-benchmark.git
cd lua-js-benchmark

# One command does everything: check deps → download source → build → benchmark → report
make all
```

Or step by step:

```bash
make setup    # Download and build all engines
make bench    # Run benchmarks (default: 5 runs, 2 warmup)
make report   # Generate Markdown + HTML reports
```

Reports are saved to `results/<timestamp>/`:
- `report.md` — Markdown tables, viewable on GitHub
- `report.html` — Interactive charts (Chart.js), open in any browser

## Benchmark Categories

| Category | Benchmarks | What it tests |
|----------|-----------|---------------|
| **compute** | mandelbrot, n-body, spectral-norm, fannkuch-redux, matrix | CPU-bound numeric computation |
| **string** | fasta, json-parse, string-concat | String operations and pattern matching |
| **alloc** | binary-trees, object-churn, gc-stress | GC pressure and memory allocation |
| **table** | table-insert, array-access, table-ops | Hash table / object property operations |
| **call** | ackermann, fibonacci, n-queens, method-dispatch | Function call overhead and recursion |
| **coroutine** | scheduler | Coroutine / generator context switching |
| **startup** | empty | Engine cold-start time |

Each benchmark has both a Lua and a JavaScript implementation with verified identical output. See [benchmarks/README.md](benchmarks/README.md) for detailed descriptions, sources, and conventions.

## System Requirements

**Platforms:** Linux (x86_64, aarch64), macOS (x86_64, Apple Silicon)

**Required tools:**

| Tool | Purpose |
|------|---------|
| bash, make | Build system |
| git | Clone engine sources |
| curl or wget | Download Lua tarball |
| gcc or clang | C compiler |
| python3 | Report generation |
| /usr/bin/time | Performance measurement |

**Optional** (for V8 only): g++/clang++, ninja

Run `make setup` to automatically check dependencies. Missing tools are reported with platform-specific install commands.

<details>
<summary>Install dependencies by platform</summary>

**Ubuntu / Debian:**
```bash
sudo apt update && sudo apt install -y build-essential git curl python3 python3-venv time ninja-build
```

**Fedora / RHEL:**
```bash
sudo dnf install -y gcc gcc-c++ make git curl python3 python3-pip time ninja-build
```

**Arch Linux:**
```bash
sudo pacman -S --needed base-devel git curl python python-pip time ninja
```

**macOS:**
```bash
xcode-select --install
brew install bash git curl python3 ninja
```
</details>

## Advanced Usage

### Select engines

```bash
# Skip V8 (avoids large download)
make setup ENGINES="lua luajit quickjs"
make bench ENGINES="lua luajit quickjs"
```

### Select benchmark category

```bash
make bench CATEGORY=compute
make bench CATEGORY=string
```

### Tune iterations

```bash
make bench RUNS=10 WARMUP=3
```

### Retry failed downloads or builds

```bash
make download-lua       # Retry Lua source download
make download-v8        # Retry V8 source download
make build-lua          # Retry Lua compilation
make build-v8           # Retry V8 compilation
```

You can also manually place source code in `.build/src/` and run the corresponding build command.

### Clean everything

```bash
make clean              # Remove .build/ and results/
make rebuild            # Clean + setup
```

## Report

All comparisons use **Lua 5.4 as the baseline** (1.00x). Values below 1.00x mean faster than Lua; above means slower.

The HTML report includes:

- **Stacked bar chart** — Overall performance. Each bar is an engine, segments are categories. Shortest bar = best engine.
- **Category comparison** — Grouped bars per category with 1.0x baseline.
- **Radar chart** — Multi-dimensional view of engine strengths.
- **Memory usage** — Peak RSS comparison.
- **Detailed table** — Every benchmark with absolute times and relative multipliers.

## Adding a New Engine

1. Create `scripts/build_<engine>.sh` (download + compile)
2. Add download logic to `scripts/download_sources.sh`
3. Register in `runner/config.sh`: binary path, language, and runtime args
4. Run `make setup && make bench`

## Adding a New Benchmark

1. Add the Lua script to `benchmarks/lua/<category>/<name>.lua`
2. Add the JS script to `benchmarks/js/<js-category>/<name>.js`
3. Ensure both produce identical output for the same input
4. Generate expected output: `lua benchmarks/lua/<category>/<name>.lua > benchmarks/expected/<category>/<name>.txt`
5. Run `make bench` — new benchmarks are discovered automatically

## Project Structure

```
lua-js-benchmark/
├── Makefile                # Top-level entry point
├── scripts/                # Environment setup and engine build scripts
│   ├── setup.sh            # Main setup orchestrator
│   ├── check_deps.sh       # Dependency checker
│   ├── detect_platform.sh  # OS/arch detection
│   ├── download_sources.sh # Source code downloader
│   ├── build_lua.sh        # Lua build script
│   ├── build_luajit.sh     # LuaJIT build script
│   ├── build_quickjs.sh    # QuickJS build script
│   └── build_v8.sh         # V8 build script (stripped: no wasm/ICU/debug)
├── benchmarks/
│   ├── lua/                # Lua benchmark scripts
│   ├── js/                 # JavaScript benchmark scripts
│   └── expected/           # Expected output for correctness checks
├── runner/
│   ├── config.sh           # Engine registry and parameters
│   ├── measure.sh          # Single-run measurement wrapper
│   └── run.sh              # Benchmark runner
├── report/
│   ├── generate.py         # Report generator
│   └── templates/          # HTML template with Chart.js
├── docs/                   # Project planning documents
├── .build/                 # Downloaded sources and binaries (git ignored)
└── results/                # Benchmark results and reports (git ignored)
```

## Documentation

- [Project Plan](docs/PROJECT_PLAN.md) — Design decisions, architecture, and rationale
- [Implementation Plan](docs/IMPLEMENTATION_PLAN.md) — Phase-by-phase progress tracker

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
