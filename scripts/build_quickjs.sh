#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

QUICKJS_SRC="$SRC_DIR/quickjs"
QUICKJS_BIN_DIR="$ENGINES_DIR/quickjs/bin"
QUICKJS_BIN="$QUICKJS_BIN_DIR/qjs"

if [[ -x "$QUICKJS_BIN" ]]; then
    log_info "QuickJS already built, skipping. (use 'make rebuild' to force)"
    exit 0
fi

if [[ ! -d "$QUICKJS_SRC" ]]; then
    log_error "QuickJS source not found at $QUICKJS_SRC"
    log_info "Run 'make download-quickjs' first."
    exit 1
fi

log_info "Building QuickJS ..."

cd "$QUICKJS_SRC"
make clean &>/dev/null || true
make CONFIG_LTO=y -j"$LJB_NPROC"

ensure_dir "$QUICKJS_BIN_DIR"
cp qjs "$QUICKJS_BIN"

log_ok "QuickJS built: $QUICKJS_BIN"
"$QUICKJS_BIN" --help 2>&1 | head -1 || true
