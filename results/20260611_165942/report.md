# lua-js-benchmark Report

Results from: `20260611_165942`
Baseline: **lua** (1.00x)

## Test Environment

| Item | Value |
|------|-------|
| Date | 2026-06-11 08:59:42 UTC |
| OS | Linux 6.6.87.2-microsoft-standard-WSL2 |
| Architecture | x86_64 |
| CPU | Intel(R) Core(TM) Ultra 7 255HX |
| CPU Cores | 20 |
| Memory | 15Gi |
| Compiler | cc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0 |

## Engines

| Engine | Name | Version | Build Flags |
|--------|------|---------|-------------|
| lua | Lua 5.4 | Lua 5.4.7  Copyright (C) 1994-2024 Lua.org, PUC-Rio | -O2 |
| lua55 | Lua 5.5 | Lua 5.5.0  Copyright (C) 1994-2025 Lua.org, PUC-Rio | -O2 |
| luajit | LuaJIT 2.1 | LuaJIT 2.1.1780076327 -- Copyright (C) 2005-2026 Mike Pall. https://luajit.org/ | -O2 -fomit-frame-pointer |
| luau | Luau | Luau | -O2 (Release) |
| luau-codegen | Luau (codegen) | Luau | -O2 (Release, native codegen) |
| quickjs | QuickJS | QuickJS version 2026-06-04 | -O2 |
| v8 | V8 (JIT) | V8 version 15.1.0 (candidate) | -O2 (release) |
| v8-nojit | V8 (no-JIT) | V8 version 15.1.0 (candidate) | -O2 (release) |

## Overall Performance

| Rank | Engine | Total Time (ms) | vs Lua | 
|------|--------|----------------:|-------:|
| #1 | v8 | 3240 | 0.18x |
| #2 | luajit | 4400 | 0.25x |
| #3 | luau-codegen | 11940 | 0.67x |
| #4 | lua55 | 16940 | 0.95x |
| #5 | luau | 17050 | 0.96x |
| #6 | lua (baseline) | 17800 | 1.00x |
| #7 | v8-nojit | 20770 | 1.17x |
| #8 | quickjs | 27310 | 1.53x |

## Performance by Category

| Category | lua | lua55 | luajit | luau | luau-codegen | quickjs | v8 | v8-nojit |
|----------|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
| alloc | 1.00x | 0.88x | 0.27x | 0.63x | 0.49x | 0.97x | 0.14x | 0.47x |
| call | 1.00x | 1.00x | 0.20x | 1.12x | 0.80x | 1.65x | 0.22x | 1.44x |
| compute | 1.00x | 0.94x | 0.12x | 1.00x | 0.57x | 2.30x | 0.12x | 1.77x |
| coroutine | 1.00x | 1.02x | 0.49x | 0.51x | 0.42x | 1.13x | 0.16x | 0.78x |
| string | 1.00x | 0.95x | 0.40x | 0.92x | 0.74x | 1.27x | 0.29x | 1.04x |
| table | 1.00x | 0.90x | 0.38x | 0.89x | 0.74x | 1.14x | 0.27x | 0.82x |

## Detailed Results

| Benchmark | Category | lua (ms) | lua55 | luajit | luau | luau-codegen | quickjs | v8 | v8-nojit |
|-----------|----------|------------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
| alloc/binary_trees | alloc | 580 | 0.91x | 0.53x | 0.59x | 0.50x | 1.22x | 0.12x | 0.57x |
| alloc/gc_stress | alloc | 1710 | 0.88x | 0.25x | 0.73x | 0.58x | 0.36x | 0.05x | 0.15x |
| alloc/object_churn | alloc | 650 | 0.85x | 0.02x | 0.57x | 0.38x | 1.32x | 0.26x | 0.71x |
| call/ackermann | call | 440 | 1.05x | 0.20x | 1.27x | 0.77x | 2.02x | 0.20x | 1.50x |
| call/closure | call | 540 | 1.00x | 0.07x | 1.13x | 0.81x | 1.48x | 0.33x | 1.57x |
| call/fibonacci | call | 1250 | 1.06x | 0.22x | 1.04x | 0.81x | 1.50x | 0.18x | 1.58x |
| call/method_dispatch | call | 430 | 1.05x | 0.16x | 1.14x | 0.93x | 1.60x | 0.14x | 1.14x |
| call/queens | call | 1350 | 0.81x | 0.27x | 1.23x | 0.83x | 1.73x | 0.33x | 1.21x |
| call/tak | call | 960 | 1.04x | 0.26x | 0.94x | 0.66x | 1.56x | 0.17x | 1.65x |
| compute/fannkuch | compute | 1850 | 1.15x | 0.19x | 1.15x | 0.55x | 1.64x | 0.10x | 1.36x |
| compute/mandelbrot | compute | 940 | 1.01x | 0.09x | 0.96x | 0.49x | 2.47x | 0.11x | 2.13x |
| compute/matrix | compute | 260 | 0.92x | 0.08x | 0.96x | 0.46x | 1.69x | 0.15x | 1.81x |
| compute/nbody | compute | 510 | 0.98x | 0.10x | 0.69x | 0.24x | 1.78x | 0.06x | 1.80x |
| compute/sieve | compute | 890 | 0.56x | 0.24x | 0.84x | 0.76x | 4.31x | 0.18x | 1.40x |
| compute/spectral_norm | compute | 860 | 1.00x | 0.03x | 1.42x | 0.91x | 1.91x | 0.13x | 2.09x |
| coroutine/scheduler | coroutine | 450 | 1.02x | 0.49x | 0.51x | 0.42x | 1.13x | 0.16x | 0.78x |
| string/fasta | string | 470 | 0.98x | 0.32x | 1.00x | 0.66x | 1.45x | 0.21x | 1.36x |
| string/json_parse | string | 500 | 1.04x | 0.48x | 0.98x | 0.90x | 0.86x | 0.16x | 0.70x |
| string/string_concat | string | 180 | 0.83x | 0.39x | 0.78x | 0.67x | 1.50x | 0.50x | 1.06x |
| table/array_access | table | 720 | 0.78x | 0.32x | 0.94x | 0.65x | 2.38x | 0.17x | 1.74x |
| table/table_insert | table | 920 | 0.97x | 0.42x | 0.83x | 0.83x | 0.40x | 0.39x | 0.42x |
| table/table_ops | table | 1340 | 0.94x | 0.40x | 0.91x | 0.74x | 0.66x | 0.24x | 0.31x |

## Memory Usage (Peak RSS)

| Benchmark | lua (KB) | lua55 (KB) | luajit (KB) | luau (KB) | luau-codegen (KB) | quickjs (KB) | v8 (KB) | v8-nojit (KB) |
|-----------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| alloc/binary_trees | 21280 | 33600 | 29120 | 34944 | 35572 | 19360 | 48960 | 40320 |
| alloc/gc_stress | 370400 | 385280 | 252960 | 318080 | 311840 | 225120 | 104320 | 120160 |
| alloc/object_churn | 2240 | 2240 | 2400 | 5440 | 6080 | 3040 | 27680 | 20160 |
| call/ackermann | 3360 | 3520 | 2880 | 6080 | 6880 | 8800 | 25760 | 18560 |
| call/closure | 2080 | 2240 | 2560 | 5280 | 5920 | 3040 | 29120 | 20160 |
| call/fibonacci | 2240 | 2240 | 2400 | 5120 | 5920 | 3040 | 24960 | 17600 |
| call/method_dispatch | 2080 | 2240 | 2400 | 5280 | 6080 | 3040 | 28800 | 20320 |
| call/queens | 2080 | 2240 | 2400 | 5280 | 6080 | 3040 | 25760 | 17920 |
| call/tak | 2240 | 2240 | 2400 | 5120 | 5920 | 3040 | 24960 | 17600 |
| compute/fannkuch | 2240 | 2400 | 2400 | 5280 | 6080 | 3040 | 26080 | 17920 |
| compute/mandelbrot | 2400 | 2240 | 2560 | 5120 | 5920 | 3040 | 27040 | 20480 |
| compute/matrix | 6400 | 4640 | 4320 | 9440 | 10080 | 6560 | 29440 | 23360 |
| compute/nbody | 2400 | 2400 | 2560 | 5440 | 6400 | 3040 | 28160 | 20320 |
| compute/sieve | 34780 | 38044 | 166080 | 332800 | 333600 | 104604 | 89440 | 87840 |
| compute/spectral_norm | 2400 | 2400 | 2400 | 5440 | 6080 | 3040 | 27840 | 20480 |
| coroutine/scheduler | 2240 | 2240 | 2400 | 5280 | 5920 | 3040 | 28000 | 20320 |
| string/fasta | 2400 | 2400 | 2560 | 5280 | 5920 | 3040 | 28960 | 20160 |
| string/json_parse | 48520 | 48656 | 51904 | 54212 | 54920 | 35200 | 85884 | 76320 |
| string/string_concat | 142720 | 75680 | 77600 | 156960 | 157600 | 85920 | 107768 | 100476 |
| table/array_access | 526400 | 296896 | 264480 | 529280 | 530080 | 315360 | 104000 | 96000 |
| table/table_insert | 112188 | 112184 | 81860 | 106748 | 107112 | 109600 | 96748 | 88984 |
| table/table_ops | 222252 | 215620 | 184308 | 215208 | 215860 | 187840 | 118420 | 143976 |