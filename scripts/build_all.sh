#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "=== Building engines ==="
echo ""

FAILED=()
SUCCEEDED=()

try_build() {
    local engine="$1"
    local script="$SCRIPT_DIR/build_${engine}.sh"

    if [[ ! -f "$script" ]]; then
        log_error "Build script not found: $script"
        FAILED+=("$engine")
        return
    fi

    if bash "$script"; then
        SUCCEEDED+=("$engine")
    else
        log_error "Failed to build $engine"
        FAILED+=("$engine")
    fi
    echo ""
}

for engine in $ENGINES; do
    if engine_enabled "$engine"; then
        try_build "$engine"
    fi
done

echo "=== Build Summary ==="
if [[ ${#SUCCEEDED[@]} -gt 0 ]]; then
    log_ok "Successfully built: ${SUCCEEDED[*]}"
fi
if [[ ${#FAILED[@]} -gt 0 ]]; then
    log_error "Failed to build: ${FAILED[*]}"
    log_info "You can retry individually: make build-<engine>"
    exit 1
fi
