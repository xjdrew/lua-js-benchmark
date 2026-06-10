#!/bin/bash
set -euo pipefail

ENGINE_NAME="$1"
ENGINE_BIN="$2"
ENGINE_ARGS="$3"
SCRIPT="$4"
SCRIPT_ARGS="${5:-}"
OUTPUT_FILE="$6"
TIME_FILE="$7"

OS="$(uname -s)"

run_with_time() {
    if [[ "$OS" == "Linux" ]]; then
        /usr/bin/time -v -o "$TIME_FILE" \
            "$ENGINE_BIN" $ENGINE_ARGS "$SCRIPT" $SCRIPT_ARGS \
            > "$OUTPUT_FILE" 2>&1
    elif [[ "$OS" == "Darwin" ]]; then
        /usr/bin/time -l -o "$TIME_FILE" \
            "$ENGINE_BIN" $ENGINE_ARGS "$SCRIPT" $SCRIPT_ARGS \
            > "$OUTPUT_FILE" 2>&1
    else
        echo "Unsupported OS: $OS" >&2
        exit 1
    fi
}

parse_time_linux() {
    local wall_clock user_time sys_time peak_rss
    wall_clock=$(grep "Elapsed (wall clock)" "$TIME_FILE" | sed 's/.*: //')
    user_time=$(grep "User time" "$TIME_FILE" | sed 's/.*: //')
    sys_time=$(grep "System time" "$TIME_FILE" | sed 's/.*: //')
    peak_rss=$(grep "Maximum resident" "$TIME_FILE" | sed 's/.*: //')

    local wall_ms
    if echo "$wall_clock" | grep -q ':'; then
        local mins secs
        mins=$(echo "$wall_clock" | cut -d: -f1)
        secs=$(echo "$wall_clock" | cut -d: -f2)
        wall_ms=$(echo "$mins $secs" | awk '{printf "%.2f", ($1 * 60 + $2) * 1000}')
    else
        wall_ms=$(echo "$wall_clock" | awk '{printf "%.2f", $1 * 1000}')
    fi

    local user_ms sys_ms
    user_ms=$(echo "$user_time" | awk '{printf "%.2f", $1 * 1000}')
    sys_ms=$(echo "$sys_time" | awk '{printf "%.2f", $1 * 1000}')

    echo "${wall_ms},${user_ms},${sys_ms},${peak_rss}"
}

parse_time_darwin() {
    local wall_ms user_ms sys_ms peak_rss

    local real_line
    real_line=$(grep "real " "$TIME_FILE" | head -1)
    wall_ms=$(echo "$real_line" | awk '{printf "%.2f", $1 * 1000}')

    local user_line
    user_line=$(grep "user " "$TIME_FILE" | head -1)
    user_ms=$(echo "$user_line" | awk '{printf "%.2f", $1 * 1000}')

    local sys_line
    sys_line=$(grep "sys " "$TIME_FILE" | head -1)
    sys_ms=$(echo "$sys_line" | awk '{printf "%.2f", $1 * 1000}')

    peak_rss=$(grep "maximum resident" "$TIME_FILE" | awk '{print int($1 / 1024)}')

    echo "${wall_ms},${user_ms},${sys_ms},${peak_rss}"
}

run_with_time

if [[ "$OS" == "Linux" ]]; then
    parse_time_linux
elif [[ "$OS" == "Darwin" ]]; then
    parse_time_darwin
fi
