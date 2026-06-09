#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

V8_SRC="$SRC_DIR/v8"
DEPOT_TOOLS="$SRC_DIR/depot_tools"
V8_BIN_DIR="$ENGINES_DIR/v8/bin"
V8_BIN="$V8_BIN_DIR/d8"

if [[ -x "$V8_BIN" ]]; then
    log_info "V8 (d8) already built, skipping. (use 'make rebuild' to force)"
    exit 0
fi

if [[ ! -d "$V8_SRC/src" ]]; then
    log_error "V8 source not found at $V8_SRC"
    log_info "Run 'make download-v8' first."
    exit 1
fi

export PATH="$DEPOT_TOOLS:$PATH"

log_info "Building V8 (d8) ..."
log_warn "This may take 30-60 minutes on first build."

cd "$V8_SRC"

GN_ARGS="is_debug=false"
GN_ARGS+=" target_cpu=\"$LJB_ARCH\""
GN_ARGS+=" v8_monolithic=true"
GN_ARGS+=" v8_enable_webassembly=false"
GN_ARGS+=" v8_enable_i18n_support=false"
GN_ARGS+=" v8_use_external_startup_data=false"
GN_ARGS+=" symbol_level=0"

gn gen out/release --args="$GN_ARGS"

local_nproc="$LJB_NPROC"
if [[ "$local_nproc" -gt 8 ]]; then
    local_nproc=8
fi

ninja -C out/release d8 -j"$local_nproc"

ensure_dir "$V8_BIN_DIR"
cp out/release/d8 "$V8_BIN"

log_ok "V8 (d8) built: $V8_BIN"
"$V8_BIN" --version || true
