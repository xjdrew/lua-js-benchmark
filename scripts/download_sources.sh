#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

LUA_VERSION="${LUA_VERSION:-5.4.7}"
LUA55_VERSION="${LUA55_VERSION:-5.5.0}"
LUA_URL="https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz"
LUA55_URL="https://www.lua.org/ftp/lua-${LUA55_VERSION}.tar.gz"
LUAJIT_REPO="https://github.com/LuaJIT/LuaJIT.git"
QUICKJS_REPO="https://github.com/bellard/quickjs.git"

ensure_dir "$SRC_DIR"

FAILED=()

download_lua() {
    local dest="$SRC_DIR/lua-${LUA_VERSION}"
    if [[ -d "$dest" && -f "$dest/Makefile" ]]; then
        log_info "Lua $LUA_VERSION source already exists, skipping."
        return 0
    fi

    log_info "Downloading Lua $LUA_VERSION ..."
    local tarball="$SRC_DIR/lua-${LUA_VERSION}.tar.gz"

    if command -v curl &>/dev/null; then
        curl -fSL --retry 3 -o "$tarball" "$LUA_URL"
    else
        wget -q -O "$tarball" "$LUA_URL"
    fi

    tar xzf "$tarball" -C "$SRC_DIR"
    rm -f "$tarball"

    if [[ -d "$dest" && -f "$dest/Makefile" ]]; then
        log_ok "Lua $LUA_VERSION source ready at $dest"
    else
        log_error "Lua source extraction failed"
        return 1
    fi
}

download_lua55() {
    local dest="$SRC_DIR/lua-${LUA55_VERSION}"
    if [[ -d "$dest" && -f "$dest/Makefile" ]]; then
        log_info "Lua $LUA55_VERSION source already exists, skipping."
        return 0
    fi

    log_info "Downloading Lua $LUA55_VERSION ..."
    local tarball="$SRC_DIR/lua-${LUA55_VERSION}.tar.gz"

    if command -v curl &>/dev/null; then
        curl -fSL --retry 3 -o "$tarball" "$LUA55_URL"
    else
        wget -q -O "$tarball" "$LUA55_URL"
    fi

    tar xzf "$tarball" -C "$SRC_DIR"
    rm -f "$tarball"

    if [[ -d "$dest" && -f "$dest/Makefile" ]]; then
        log_ok "Lua $LUA55_VERSION source ready at $dest"
    else
        log_error "Lua 5.5 source extraction failed"
        return 1
    fi
}

download_luajit() {
    local dest="$SRC_DIR/LuaJIT"
    if [[ -d "$dest" && -f "$dest/Makefile" ]]; then
        log_info "LuaJIT source already exists, skipping."
        return 0
    fi

    log_info "Cloning LuaJIT ..."
    rm -rf "$dest"
    git clone --depth 1 "$LUAJIT_REPO" "$dest"
    log_ok "LuaJIT source ready at $dest"
}

download_quickjs() {
    local dest="$SRC_DIR/quickjs"
    if [[ -d "$dest" && -f "$dest/Makefile" ]]; then
        log_info "QuickJS source already exists, skipping."
        return 0
    fi

    log_info "Cloning QuickJS ..."
    rm -rf "$dest"
    git clone --depth 1 "$QUICKJS_REPO" "$dest"
    log_ok "QuickJS source ready at $dest"
}

download_v8() {
    local depot_tools_dir="$SRC_DIR/depot_tools"
    local v8_dir="$SRC_DIR/v8"

    if [[ -d "$v8_dir/src" ]]; then
        log_info "V8 source already exists, skipping."
        return 0
    fi

    echo ""
    log_warn "V8 source is very large (>10GB). This may take 10-30 minutes."
    log_warn "If download fails, you can retry with: make download-v8"
    echo ""

    if [[ ! -d "$depot_tools_dir" ]]; then
        log_info "Cloning depot_tools ..."
        git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "$depot_tools_dir"
    fi

    export PATH="$depot_tools_dir:$PATH"

    if [[ ! -d "$v8_dir" ]]; then
        log_info "Fetching V8 source (this will take a while) ..."
        cd "$SRC_DIR"
        fetch v8
    fi

    cd "$v8_dir"
    log_info "Running gclient sync ..."
    gclient sync

    log_ok "V8 source ready at $v8_dir"
}

echo "=== Downloading engine sources ==="
echo ""

if engine_enabled lua; then
    download_lua || FAILED+=("lua")
fi

if engine_enabled lua55; then
    download_lua55 || FAILED+=("lua55")
fi

if engine_enabled luajit; then
    download_luajit || FAILED+=("luajit")
fi

if engine_enabled quickjs; then
    download_quickjs || FAILED+=("quickjs")
fi

if engine_enabled v8; then
    download_v8 || FAILED+=("v8")
fi

echo ""
if [[ ${#FAILED[@]} -gt 0 ]]; then
    log_error "Failed to download: ${FAILED[*]}"
    log_info "You can retry individually: make download-lua / make download-v8 / etc."
    log_info "Or manually place source code in $SRC_DIR/"
    exit 1
fi

log_ok "All source downloads complete."
