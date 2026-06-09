#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

LUAJIT_SRC="$SRC_DIR/LuaJIT"
LUAJIT_PREFIX="$ENGINES_DIR/luajit"
LUAJIT_BIN="$LUAJIT_PREFIX/bin/luajit"

if [[ -x "$LUAJIT_BIN" ]]; then
    log_info "LuaJIT already built, skipping. (use 'make rebuild' to force)"
    exit 0
fi

if [[ ! -d "$LUAJIT_SRC" ]]; then
    log_error "LuaJIT source not found at $LUAJIT_SRC"
    log_info "Run 'make download-luajit' first."
    exit 1
fi

log_info "Building LuaJIT ..."

cd "$LUAJIT_SRC"
make clean &>/dev/null || true

MAKE_ARGS=(
    PREFIX="$LUAJIT_PREFIX"
    XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT"
    -j"$LJB_NPROC"
)

if [[ "$LJB_OS" == "darwin" && "$LJB_ARCH" == "arm64" ]]; then
    MAKE_ARGS+=(MACOSX_DEPLOYMENT_TARGET=11.0)
fi

make "${MAKE_ARGS[@]}"
make install PREFIX="$LUAJIT_PREFIX"

log_ok "LuaJIT built: $LUAJIT_BIN"
"$LUAJIT_BIN" -v
