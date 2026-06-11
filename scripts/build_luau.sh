#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

LUAU_SRC="$SRC_DIR/luau"
LUAU_BIN_DIR="$ENGINES_DIR/luau/bin"
LUAU_BIN="$LUAU_BIN_DIR/luau"

if [[ -x "$LUAU_BIN" ]]; then
    log_info "Luau already built, skipping. (use 'make rebuild' to force)"
    exit 0
fi

if [[ ! -d "$LUAU_SRC" ]]; then
    log_error "Luau source not found at $LUAU_SRC"
    log_info "Run 'make download-luau' first."
    exit 1
fi

log_info "Building Luau ..."

cd "$LUAU_SRC"
rm -rf build
mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DLUAU_BUILD_TESTS=OFF
cmake --build . --target Luau.Repl.CLI --config Release -j"$LJB_NPROC"

ensure_dir "$LUAU_BIN_DIR"
cp luau "$LUAU_BIN"

log_ok "Luau built: $LUAU_BIN"
echo 'print(_VERSION)' | "$LUAU_BIN" || true
