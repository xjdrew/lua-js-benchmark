# lua-js-benchmark Report

Results from: `20260610_103616`
Baseline: **lua** (1.00x)

## Test Environment

| Item | Value |
|------|-------|
| Date | 2026-06-10 02:36:16 UTC |
| OS | Linux 6.6.87.2-microsoft-standard-WSL2 |
| Architecture | x86_64 |
| CPU | Intel(R) Core(TM) Ultra 7 255HX |
| CPU Cores | 20 |
| Memory | 15Gi |

## Engines

| Engine | Name | Version |
|--------|------|---------|
| lua | Lua 5.4 | Lua 5.4.7  Copyright (C) 1994-2024 Lua.org, PUC-Rio |
| luajit | LuaJIT 2.1 | LuaJIT 2.1.1780076327 -- Copyright (C) 2005-2026 Mike Pall. https://luajit.org/ |
| quickjs | QuickJS | QuickJS version 2026-06-04 |
| v8 | V8 (JIT) | V8 version 15.1.0 (candidate) |
| v8-nojit | V8 (no-JIT) | V8 version 15.1.0 (candidate) |

## Overall Performance

| Rank | Engine | Total Time (ms) | vs Lua | 
|------|--------|----------------:|-------:|
| #1 | v8 | 1460 | 0.24x |
| #2 | luajit | 1520 | 0.25x |
| #3 | lua (baseline) | 6190 | 1.00x |
| #4 | v8-nojit | 8520 | 1.38x |
| #5 | quickjs | 8920 | 1.44x |

## Performance by Category

| Category | lua | luajit | quickjs | v8 | v8-nojit |
|----------|-------:|-------:|-------:|-------:|-------:|
| alloc | 1.00x | 0.29x | 1.36x | 0.25x | 0.84x |
| call | 1.00x | 0.24x | 1.74x | 0.28x | 1.46x |
| compute | 1.00x | 0.10x | 1.85x | 0.11x | 1.79x |
| coroutine | 1.00x | 0.00x | 1.00x | 1.00x | 2.00x |
| string | 1.00x | 0.30x | 0.80x | 0.25x | 1.15x |
| table | 1.00x | 0.38x | 1.31x | 0.48x | 1.28x |

## Detailed Results

| Benchmark | Category | lua (ms) | luajit | quickjs | v8 | v8-nojit |
|-----------|----------|------------:|-------:|-------:|-------:|-------:|
| alloc/binary_trees | alloc | 620 | 0.58x | 1.34x | 0.13x | 0.68x |
| alloc/object_churn | alloc | 80 | 0.00x | 1.38x | 0.38x | 1.00x |
| call/ackermann | call | 140 | 0.21x | 1.71x | 0.21x | 1.36x |
| call/fibonacci | call | 340 | 0.21x | 1.47x | 0.18x | 1.56x |
| call/queens | call | 240 | 0.29x | 2.04x | 0.46x | 1.46x |
| compute/fannkuch | compute | 2150 | 0.17x | 1.43x | 0.09x | 1.35x |
| compute/mandelbrot | compute | 480 | 0.08x | 2.46x | 0.12x | 2.02x |
| compute/nbody | compute | 570 | 0.11x | 1.88x | 0.07x | 1.98x |
| compute/spectral_norm | compute | 290 | 0.03x | 1.62x | 0.14x | 1.79x |
| coroutine/scheduler | coroutine | 10 | 0.00x | 1.00x | 1.00x | 2.00x |
| string/fasta | string | 100 | 0.40x | 1.60x | 0.30x | 1.90x |
| string/json_parse | string | 50 | 0.20x | 0.00x | 0.20x | 0.40x |
| table/array_access | table | 220 | 0.32x | 2.32x | 0.18x | 1.64x |
| table/table_insert | table | 900 | 0.43x | 0.31x | 0.78x | 0.92x |

## Memory Usage (Peak RSS)

| Benchmark | lua (KB) | luajit (KB) | quickjs (KB) | v8 (KB) | v8-nojit (KB) |
|-----------|----------:|----------:|----------:|----------:|----------:|
| alloc/binary_trees | 21280 | 27840 | 19360 | 49600 | 40480 |
| alloc/object_churn | 2080 | 2400 | 3040 | 28160 | 20320 |
| call/ackermann | 2560 | 2576 | 5920 | 26080 | 18560 |
| call/fibonacci | 2080 | 2560 | 3040 | 25440 | 18080 |
| call/queens | 2240 | 2400 | 3040 | 26240 | 18240 |
| compute/fannkuch | 2240 | 2560 | 3040 | 26720 | 18400 |
| compute/mandelbrot | 2400 | 2560 | 3040 | 27680 | 20480 |
| compute/nbody | 2400 | 2560 | 3040 | 28800 | 20800 |
| compute/spectral_norm | 2400 | 2400 | 3040 | 28960 | 20800 |
| coroutine/scheduler | 2240 | 2560 | 3200 | 28640 | 20480 |
| string/fasta | 2400 | 2560 | 3040 | 29280 | 20640 |
| string/json_parse | 7356 | 7348 | 6240 | 31680 | 23520 |
| table/array_access | 133120 | 67840 | 81120 | 46240 | 37760 |
| table/table_insert | 112192 | 81860 | 107248 | 109092 | 103896 |