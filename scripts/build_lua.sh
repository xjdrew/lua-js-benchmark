#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

LUA_VERSION="${LUA_VERSION:-5.4.7}"
LUA_SRC="$SRC_DIR/lua-${LUA_VERSION}"
LUA_BIN_DIR="$ENGINES_DIR/lua/bin"
LUA_BIN="$LUA_BIN_DIR/lua"

if [[ -x "$LUA_BIN" ]]; then
    log_info "Lua already built, skipping. (use 'make rebuild' to force)"
    exit 0
fi

if [[ ! -d "$LUA_SRC" ]]; then
    log_error "Lua source not found at $LUA_SRC"
    log_info "Run 'make download-lua' first."
    exit 1
fi

log_info "Building Lua $LUA_VERSION ..."

case "$LJB_OS" in
    linux)  PLAT="linux" ;;
    darwin) PLAT="macosx" ;;
    *)      PLAT="posix" ;;
esac

cd "$LUA_SRC"
make clean &>/dev/null || true
make "$PLAT" MYCFLAGS="-O2" -j"$LJB_NPROC"

ensure_dir "$LUA_BIN_DIR"
cp src/lua "$LUA_BIN"

log_ok "Lua $LUA_VERSION built: $LUA_BIN"
"$LUA_BIN" -v
