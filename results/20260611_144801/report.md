# lua-js-benchmark Report

Results from: `20260611_144801`
Baseline: **lua** (1.00x)

## Test Environment

| Item | Value |
|------|-------|
| Date | 2026-06-11 06:48:01 UTC |
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
| quickjs | QuickJS | QuickJS version 2026-06-04 | -O2 |
| v8 | V8 (JIT) | V8 version 15.1.0 (candidate) | -O2 (release) |
| v8-nojit | V8 (no-JIT) | V8 version 15.1.0 (candidate) | -O2 (release) |

## Overall Performance

| Rank | Engine | Total Time (ms) | vs Lua | 
|------|--------|----------------:|-------:|
| #1 | v8 | 3760 | 0.20x |
| #2 | luajit | 4610 | 0.24x |
| #3 | lua55 | 17570 | 0.93x |
| #4 | lua (baseline) | 18920 | 1.00x |
| #5 | v8-nojit | 22110 | 1.17x |
| #6 | quickjs | 28470 | 1.50x |

## Performance by Category

| Category | lua | lua55 | luajit | quickjs | v8 | v8-nojit |
|----------|-------:|-------:|-------:|-------:|-------:|-------:|
| alloc | 1.00x | 0.92x | 0.27x | 0.94x | 0.17x | 0.48x |
| call | 1.00x | 0.97x | 0.20x | 1.68x | 0.25x | 1.48x |
| compute | 1.00x | 0.88x | 0.11x | 2.18x | 0.11x | 1.69x |
| coroutine | 1.00x | 0.98x | 0.48x | 1.19x | 0.19x | 0.86x |
| string | 1.00x | 0.96x | 0.39x | 1.40x | 0.36x | 1.15x |
| table | 1.00x | 0.94x | 0.41x | 1.24x | 0.29x | 0.85x |

## Detailed Results

| Benchmark | Category | lua (ms) | lua55 | luajit | quickjs | v8 | v8-nojit |
|-----------|----------|------------:|-------:|-------:|-------:|-------:|-------:|
| alloc/binary_trees | alloc | 590 | 0.98x | 0.56x | 1.19x | 0.22x | 0.58x |
| alloc/gc_stress | alloc | 1660 | 0.90x | 0.23x | 0.37x | 0.05x | 0.16x |
| alloc/object_churn | alloc | 640 | 0.86x | 0.02x | 1.25x | 0.23x | 0.70x |
| call/ackermann | call | 420 | 1.05x | 0.21x | 2.14x | 0.24x | 1.55x |
| call/closure | call | 540 | 0.94x | 0.07x | 1.57x | 0.37x | 1.91x |
| call/fibonacci | call | 1570 | 0.96x | 0.20x | 1.38x | 0.15x | 1.46x |
| call/method_dispatch | call | 580 | 1.00x | 0.14x | 1.38x | 0.12x | 0.93x |
| call/queens | call | 1510 | 0.89x | 0.28x | 1.81x | 0.41x | 1.28x |
| call/tak | call | 1010 | 1.00x | 0.29x | 1.77x | 0.18x | 1.76x |
| compute/fannkuch | compute | 2120 | 0.92x | 0.15x | 1.47x | 0.08x | 1.28x |
| compute/mandelbrot | compute | 950 | 1.00x | 0.07x | 2.59x | 0.12x | 2.02x |
| compute/matrix | compute | 260 | 0.88x | 0.08x | 1.73x | 0.12x | 1.73x |
| compute/nbody | compute | 510 | 1.02x | 0.10x | 1.78x | 0.06x | 1.78x |
| compute/sieve | compute | 870 | 0.53x | 0.21x | 3.79x | 0.17x | 1.40x |
| compute/spectral_norm | compute | 910 | 0.92x | 0.03x | 1.71x | 0.11x | 1.95x |
| coroutine/scheduler | coroutine | 420 | 0.98x | 0.48x | 1.19x | 0.19x | 0.86x |
| string/fasta | string | 440 | 1.05x | 0.36x | 1.61x | 0.25x | 1.45x |
| string/json_parse | string | 470 | 0.98x | 0.40x | 0.91x | 0.15x | 0.66x |
| string/string_concat | string | 150 | 0.87x | 0.40x | 1.67x | 0.67x | 1.33x |
| table/array_access | table | 750 | 0.84x | 0.33x | 2.61x | 0.17x | 1.77x |
| table/table_insert | table | 1130 | 0.97x | 0.44x | 0.38x | 0.34x | 0.35x |
| table/table_ops | table | 1420 | 0.99x | 0.44x | 0.73x | 0.36x | 0.44x |

## Memory Usage (Peak RSS)

| Benchmark | lua (KB) | lua55 (KB) | luajit (KB) | quickjs (KB) | v8 (KB) | v8-nojit (KB) |
|-----------|----------:|----------:|----------:|----------:|----------:|----------:|
| alloc/binary_trees | 20160 | 33600 | 30240 | 19360 | 48960 | 40000 |
| alloc/gc_stress | 370400 | 385280 | 252960 | 225120 | 104160 | 119840 |
| alloc/object_churn | 2240 | 2240 | 2400 | 3040 | 27840 | 20160 |
| call/ackermann | 3360 | 3520 | 2880 | 8640 | 25760 | 18560 |
| call/closure | 2240 | 2240 | 2400 | 3040 | 29280 | 20160 |
| call/fibonacci | 2240 | 2240 | 2560 | 3040 | 24800 | 17600 |
| call/method_dispatch | 2080 | 2240 | 2400 | 3040 | 28320 | 20160 |
| call/queens | 2080 | 2080 | 2400 | 3040 | 25920 | 17760 |
| call/tak | 2240 | 2080 | 2400 | 3040 | 24960 | 17600 |
| compute/fannkuch | 2240 | 2400 | 2400 | 3040 | 26080 | 17920 |
| compute/mandelbrot | 2400 | 2400 | 2560 | 3040 | 27040 | 20480 |
| compute/matrix | 6400 | 4640 | 4320 | 6560 | 29280 | 23200 |
| compute/nbody | 2400 | 2400 | 2560 | 3040 | 27840 | 20480 |
| compute/sieve | 34784 | 38044 | 166080 | 104600 | 89440 | 87840 |
| compute/spectral_norm | 2400 | 2400 | 2400 | 3040 | 27840 | 20640 |
| coroutine/scheduler | 2240 | 2240 | 2400 | 3200 | 28320 | 20160 |
| string/fasta | 2400 | 2400 | 2560 | 3040 | 29120 | 20160 |
| string/json_parse | 48520 | 48660 | 51904 | 35200 | 85988 | 75840 |
| string/string_concat | 142720 | 75680 | 77600 | 85920 | 107928 | 95388 |
| table/array_access | 526400 | 296900 | 264480 | 315520 | 103840 | 95840 |
| table/table_insert | 112192 | 112184 | 81856 | 109600 | 97100 | 88816 |
| table/table_ops | 222252 | 215620 | 184304 | 187840 | 117956 | 143868 |