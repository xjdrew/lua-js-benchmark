#!/bin/bash
set -euo pipefail

RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$RUNNER_DIR/config.sh"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$RESULTS_DIR/$TIMESTAMP"
mkdir -p "$RUN_DIR"

collect_system_info() {
    local info_file="$RUN_DIR/system_info.txt"
    {
        echo "=== System Information ==="
        echo "Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
        echo "OS: $(uname -s)"
        echo "Kernel: $(uname -r)"
        echo "Architecture: $(uname -m)"

        if [[ "$(uname -s)" == "Linux" ]]; then
            echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
            echo "CPU Cores: $(nproc)"
            echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
        elif [[ "$(uname -s)" == "Darwin" ]]; then
            echo "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo unknown)"
            echo "CPU Cores: $(sysctl -n hw.ncpu)"
            echo "Memory: $(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024) "GB"}')"
        fi

        echo ""
        echo "=== Engine Versions ==="
        for engine in $(get_available_engines); do
            local bin="${ENGINE_BIN[$engine]}"
            local args="${ENGINE_ARGS[$engine]}"
            echo -n "$engine: "
            case "$engine" in
                lua)       "$bin" -v 2>&1 || true ;;
                luajit)    "$bin" -v 2>&1 | head -1 || true ;;
                quickjs)   "$bin" --help 2>&1 | head -1 || true ;;
                v8|v8-nojit) "$bin" $args --version 2>&1 || echo "unknown" ;;
            esac
        done

        echo ""
        echo "=== Benchmark Config ==="
        echo "RUNS: $RUNS"
        echo "WARMUP: $WARMUP"
        echo "ENGINES: $ENGINES"
        echo "CATEGORY: ${CATEGORY:-all}"
    } > "$info_file"

    echo "[INFO]  System info saved to $info_file"
}

CSV_FILE="$RUN_DIR/raw.csv"
echo "engine,benchmark,category,run,wall_ms,user_ms,sys_ms,peak_rss_kb" > "$CSV_FILE"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

run_benchmark() {
    local engine="$1"
    local bench="$2"
    local lang="${ENGINE_LANG[$engine]}"
    local bin="${ENGINE_BIN[$engine]}"
    local args="${ENGINE_ARGS[$engine]}"
    local category="${bench%%/*}"
    local name="${bench#*/}"

    local script
    script=$(get_benchmark_script "$lang" "$bench")
    if [[ -z "$script" ]]; then
        return 1
    fi

    local script_args=""
    local meta_file
    meta_file="$(dirname "$script")/$(basename "$script" | sed 's/\.\(lua\|js\)$/.args/')"
    if [[ -f "$meta_file" ]]; then
        script_args=$(cat "$meta_file")
    fi

    local output_file="$TMP_DIR/output.txt"
    local time_file="$TMP_DIR/time.txt"

    for ((w = 1; w <= WARMUP; w++)); do
        bash "$RUNNER_DIR/measure.sh" "$engine" "$bin" "$args" "$script" "$script_args" \
            "$output_file" "$time_file" >/dev/null 2>&1 || true
    done

    local expected_file
    expected_file=$(get_expected_output "$bench")
    local all_ok=true

    for ((r = 1; r <= RUNS; r++)); do
        local metrics
        metrics=$(bash "$RUNNER_DIR/measure.sh" "$engine" "$bin" "$args" "$script" "$script_args" \
            "$output_file" "$time_file" 2>/dev/null) || {
            echo "[FAIL]  $engine / $bench (run $r) — execution error"
            all_ok=false
            continue
        }

        if [[ -n "$expected_file" && -f "$expected_file" ]]; then
            if ! diff -q "$output_file" "$expected_file" &>/dev/null; then
                echo "[WARN]  $engine / $bench (run $r) — output mismatch"
            fi
        fi

        echo "$engine,$bench,$category,$r,$metrics" >> "$CSV_FILE"
    done

    if $all_ok; then
        local wall_ms
        wall_ms=$(grep "^$engine,$bench," "$CSV_FILE" | tail -1 | cut -d, -f5)
        printf "  %-12s %-30s %s ms\n" "$engine" "$bench" "$wall_ms"
    fi
}

echo "============================================"
echo "  lua-js-benchmark - Benchmark Runner"
echo "============================================"
echo ""
echo "Config: RUNS=$RUNS, WARMUP=$WARMUP"
echo "Engines: $(get_available_engines)"
echo "Category: ${CATEGORY:-all}"
echo ""

collect_system_info
echo ""

all_benchmarks=$(discover_benchmarks "lua")
js_benchmarks=$(discover_benchmarks "js")
all_benchmarks=$(echo -e "$all_benchmarks\n$js_benchmarks" | sort -u)

if [[ -z "$all_benchmarks" ]]; then
    echo "[WARN]  No benchmarks found."
    echo "        Make sure benchmark scripts exist in benchmarks/lua/ and benchmarks/js/"
    exit 0
fi

echo "=== Running Benchmarks ==="
echo ""
printf "  %-12s %-30s %s\n" "ENGINE" "BENCHMARK" "TIME"
echo "  -------------------------------------------------------"

TOTAL=0
FAILED=0

for bench in $all_benchmarks; do
    for engine in $(get_available_engines); do
        lang="${ENGINE_LANG[$engine]}"
        script=$(get_benchmark_script "$lang" "$bench")
        if [[ -z "$script" ]]; then
            continue
        fi

        TOTAL=$((TOTAL + 1))
        if ! run_benchmark "$engine" "$bench"; then
            FAILED=$((FAILED + 1))
        fi
    done
done

echo ""
echo "=== Summary ==="
echo "Total runs: $TOTAL (failed: $FAILED)"
echo "Results: $CSV_FILE"
echo ""
echo "To generate report: make report"
