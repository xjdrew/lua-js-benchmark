#!/bin/bash
set -euo pipefail

detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "darwin" ;;
        *)       echo "unknown" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  echo "x64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)             echo "unknown" ;;
    esac
}

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "unknown"
    fi
}

detect_nproc() {
    if command -v nproc &>/dev/null; then
        nproc
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        sysctl -n hw.ncpu
    else
        echo 1
    fi
}

export LJB_OS="$(detect_os)"
export LJB_ARCH="$(detect_arch)"
export LJB_PKG_MANAGER="$(detect_pkg_manager)"
export LJB_NPROC="$(detect_nproc)"

if [[ "${1:-}" == "--print" ]]; then
    echo "OS:              $LJB_OS"
    echo "Architecture:    $LJB_ARCH"
    echo "Package Manager: $LJB_PKG_MANAGER"
    echo "CPU Cores:       $LJB_NPROC"
fi
