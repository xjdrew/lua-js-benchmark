#!/bin/bash

RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$RUNNER_DIR/.." && pwd)}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/.build}"
ENGINES_DIR="${ENGINES_DIR:-$BUILD_DIR/engines}"

RUNS="${RUNS:-5}"
WARMUP="${WARMUP:-2}"
ENGINES="${ENGINES:-lua lua55 luajit quickjs v8}"
CATEGORY="${CATEGORY:-}"

BENCHMARKS_DIR="$ROOT_DIR/benchmarks"
RESULTS_DIR="$ROOT_DIR/results"

declare -A ENGINE_BIN
ENGINE_BIN[lua]="$ENGINES_DIR/lua/bin/lua"
ENGINE_BIN[lua55]="$ENGINES_DIR/lua55/bin/lua"
ENGINE_BIN[luajit]="$ENGINES_DIR/luajit/bin/luajit"
ENGINE_BIN[quickjs]="$ENGINES_DIR/quickjs/bin/qjs"
ENGINE_BIN[v8]="$ENGINES_DIR/v8/bin/d8"
ENGINE_BIN[v8-nojit]="$ENGINES_DIR/v8/bin/d8"

declare -A ENGINE_LANG
ENGINE_LANG[lua]="lua"
ENGINE_LANG[lua55]="lua"
ENGINE_LANG[luajit]="lua"
ENGINE_LANG[quickjs]="js"
ENGINE_LANG[v8]="js"
ENGINE_LANG[v8-nojit]="js"

declare -A ENGINE_ARGS
ENGINE_ARGS[lua]=""
ENGINE_ARGS[lua55]=""
ENGINE_ARGS[luajit]=""
ENGINE_ARGS[quickjs]="--stack-size 33554432"
ENGINE_ARGS[v8]=""
ENGINE_ARGS[v8-nojit]="--jitless"

declare -A ENGINE_DISPLAY_NAME
ENGINE_DISPLAY_NAME[lua]="Lua 5.4"
ENGINE_DISPLAY_NAME[lua55]="Lua 5.5"
ENGINE_DISPLAY_NAME[luajit]="LuaJIT 2.1"
ENGINE_DISPLAY_NAME[quickjs]="QuickJS"
ENGINE_DISPLAY_NAME[v8]="V8 (JIT)"
ENGINE_DISPLAY_NAME[v8-nojit]="V8 (no-JIT)"

get_engine_version() {
    local engine="$1"
    local bin="${ENGINE_BIN[$engine]}"
    [[ -x "$bin" ]] || { echo "unknown"; return; }
    case "$engine" in
        lua|lua55)   "$bin" -v 2>&1 | head -1 || true ;;
        luajit)      "$bin" -v 2>&1 | head -1 || true ;;
        quickjs)     "$bin" --help 2>&1 | head -1 || true ;;
        v8|v8-nojit) "$bin" --version 2>&1 | head -1 || true ;;
        *)           echo "unknown" ;;
    esac
}

declare -A CATEGORY_DIR_JS
CATEGORY_DIR_JS[compute]="compute"
CATEGORY_DIR_JS[string]="string"
CATEGORY_DIR_JS[alloc]="alloc"
CATEGORY_DIR_JS[table]="object"
CATEGORY_DIR_JS[call]="call"
CATEGORY_DIR_JS[coroutine]="async"
CATEGORY_DIR_JS[startup]="startup"

expand_engines() {
    local result=""
    for e in $ENGINES; do
        if [[ "$e" == "v8" ]]; then
            result="$result v8 v8-nojit"
        else
            result="$result $e"
        fi
    done
    echo "$result"
}

get_available_engines() {
    local available=""
    for engine in $(expand_engines); do
        local bin="${ENGINE_BIN[$engine]}"
        if [[ -x "$bin" ]]; then
            available="$available $engine"
        fi
    done
    echo "$available"
}

discover_benchmarks() {
    local benchdir="$BENCHMARKS_DIR/lua"

    if [[ ! -d "$benchdir" ]]; then
        return
    fi

    for category_dir in "$benchdir"/*/; do
        [[ -d "$category_dir" ]] || continue
        local category
        category=$(basename "$category_dir")

        if [[ -n "$CATEGORY" && "$category" != "$CATEGORY" ]]; then
            continue
        fi

        for script in "$category_dir"*.lua; do
            [[ -f "$script" ]] || continue
            local name
            name=$(basename "$script" .lua)
            echo "$category/$name"
        done
    done | sort -u
}

get_benchmark_script() {
    local lang="$1"
    local bench="$2"
    local category="${bench%%/*}"
    local name="${bench#*/}"

    if [[ "$lang" == "js" ]]; then
        local js_dir="${CATEGORY_DIR_JS[$category]:-$category}"
        local script="$BENCHMARKS_DIR/js/$js_dir/$name.js"
        if [[ -f "$script" ]]; then
            echo "$script"
        fi
    else
        local script="$BENCHMARKS_DIR/lua/$category/$name.lua"
        if [[ -f "$script" ]]; then
            echo "$script"
        fi
    fi
}

get_expected_output() {
    local bench="$1"
    local category="${bench%%/*}"
    local name="${bench#*/}"
    local expected="$BENCHMARKS_DIR/expected/$category/$name.txt"
    if [[ -f "$expected" ]]; then
        echo "$expected"
    fi
}
