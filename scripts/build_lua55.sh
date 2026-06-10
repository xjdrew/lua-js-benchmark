#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

LUA55_VERSION="${LUA55_VERSION:-5.5.0}"
LUA55_SRC="$SRC_DIR/lua-${LUA55_VERSION}"
LUA55_BIN_DIR="$ENGINES_DIR/lua55/bin"
LUA55_BIN="$LUA55_BIN_DIR/lua"

if [[ -x "$LUA55_BIN" ]]; then
    log_info "Lua 5.5 already built, skipping. (use 'make rebuild' to force)"
    exit 0
fi

if [[ ! -d "$LUA55_SRC" ]]; then
    log_error "Lua 5.5 source not found at $LUA55_SRC"
    log_info "Run 'make download-lua55' first."
    exit 1
fi

log_info "Building Lua $LUA55_VERSION ..."

case "$LJB_OS" in
    linux)  PLAT="linux" ;;
    darwin) PLAT="macosx" ;;
    *)      PLAT="posix" ;;
esac

cd "$LUA55_SRC"
make clean &>/dev/null || true
make "$PLAT" MYCFLAGS="-O2" -j"$LJB_NPROC"

ensure_dir "$LUA55_BIN_DIR"
cp src/lua "$LUA55_BIN"

log_ok "Lua $LUA55_VERSION built: $LUA55_BIN"
"$LUA55_BIN" -v
