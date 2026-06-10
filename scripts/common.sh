#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/.build}"
SRC_DIR="${SRC_DIR:-$BUILD_DIR/src}"
ENGINES_DIR="${ENGINES_DIR:-$BUILD_DIR/engines}"
ENGINES="${ENGINES:-lua lua55 luajit quickjs v8}"

source "$SCRIPT_DIR/detect_platform.sh"

log_info()  { echo "[INFO]  $*"; }
log_warn()  { echo "[WARN]  $*"; }
log_error() { echo "[ERROR] $*"; }
log_ok()    { echo "[OK]    $*"; }

engine_enabled() {
    local engine="$1"
    for e in $ENGINES; do
        [[ "$e" == "$engine" ]] && return 0
    done
    return 1
}

ensure_dir() {
    mkdir -p "$1"
}
