#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect_platform.sh"

ENGINES="${ENGINES:-lua luajit quickjs v8}"

MISSING_REQUIRED=()
MISSING_OPTIONAL=()

check_cmd() {
    local name="$1"
    local desc="$2"
    local required="${3:-yes}"

    if command -v "$name" &>/dev/null; then
        return 0
    else
        if [[ "$required" == "yes" ]]; then
            MISSING_REQUIRED+=("$name: $desc")
        else
            MISSING_OPTIONAL+=("$name: $desc")
        fi
        return 1
    fi
}

check_either() {
    local desc="$3"
    local required="${4:-yes}"
    if command -v "$1" &>/dev/null || command -v "$2" &>/dev/null; then
        return 0
    else
        if [[ "$required" == "yes" ]]; then
            MISSING_REQUIRED+=("$1 or $2: $desc")
        else
            MISSING_OPTIONAL+=("$1 or $2: $desc")
        fi
        return 1
    fi
}

echo "=== Checking dependencies ==="
echo ""

if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    MISSING_REQUIRED+=("bash >= 4.0: associative arrays (current: $BASH_VERSION)")
fi

check_either curl wget "HTTP download tool" || true
check_cmd git "Version control" || true
check_either gcc clang "C compiler" || true
check_either g++ clang++ "C++ compiler (for V8)" no || true
check_cmd make "Build tool" || true
check_cmd python3 "Report generation" || true

if [[ "$LJB_OS" == "linux" ]]; then
    if [[ ! -x /usr/bin/time ]]; then
        MISSING_REQUIRED+=("/usr/bin/time: GNU time (performance measurement)")
    fi
fi

needs_v8=no
for e in $ENGINES; do
    if [[ "$e" == "v8" ]]; then
        needs_v8=yes
    fi
done

if [[ "$needs_v8" == "yes" ]]; then
    check_cmd ninja "Build tool (required for V8)" no || true
fi

if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]] || [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
    if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
        echo "[ERROR] The following required tools are missing:"
        for item in "${MISSING_REQUIRED[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi

    if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
        echo "[WARN] The following optional tools are missing:"
        for item in "${MISSING_OPTIONAL[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi

    echo "Install instructions for your platform ($LJB_PKG_MANAGER):"
    echo ""
    case "$LJB_PKG_MANAGER" in
        apt)
            echo "  sudo apt update && sudo apt install -y build-essential git curl python3 python3-pip python3-venv time ninja-build"
            ;;
        dnf)
            echo "  sudo dnf install -y gcc gcc-c++ make git curl python3 python3-pip time ninja-build"
            ;;
        yum)
            echo "  sudo yum install -y gcc gcc-c++ make git curl python3 python3-pip time ninja-build"
            ;;
        pacman)
            echo "  sudo pacman -S --needed base-devel git curl python python-pip time ninja"
            ;;
        brew)
            echo "  xcode-select --install"
            echo "  brew install git curl python3 ninja"
            ;;
        *)
            echo "  Please install: gcc, g++, make, git, curl, python3, ninja"
            ;;
    esac
    echo ""

    if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
        echo "Please install the required tools and try again."
        exit 1
    fi
fi

echo "All required dependencies are installed."
echo ""
