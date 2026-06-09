#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "============================================"
echo "  lua-js-benchmark - Environment Setup"
echo "============================================"
echo ""
echo "Engines: $ENGINES"
echo ""

echo "--- Step 1/4: Detecting platform ---"
source "$SCRIPT_DIR/detect_platform.sh" --print
echo ""

echo "--- Step 2/4: Checking dependencies ---"
bash "$SCRIPT_DIR/check_deps.sh"

echo "--- Step 3/4: Downloading sources ---"
bash "$SCRIPT_DIR/download_sources.sh"

echo "--- Step 4/4: Building engines ---"
bash "$SCRIPT_DIR/build_all.sh"

echo ""
echo "============================================"
echo "  Setup complete!"
echo ""
echo "  Next steps:"
echo "    make bench    - Run benchmarks"
echo "    make report   - Generate report"
echo "    make all      - Run everything"
echo "============================================"
