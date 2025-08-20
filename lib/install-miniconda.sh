#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Miniconda Installer (Linux + macOS, auto-detect version)
# =========================================================

# Default install prefix
PREFIX="${MINICONDA_PREFIX:-$HOME/.local/share/miniconda3}"

# Detect platform
OS="$(uname -s)"
ARCH="$(uname -m)"

# Normalize arch names
case "$ARCH" in
    x86_64|amd64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# Detect correct installer
if [ "$OS" = "Darwin" ]; then
    PLATFORM="MacOSX"
elif [ "$OS" = "Linux" ]; then
    PLATFORM="Linux"
else
    echo "Unsupported OS: $OS" >&2
    exit 1
fi

INSTALLER="Miniconda3-latest-${PLATFORM}-${ARCH}.sh"
URL="https://repo.anaconda.com/miniconda/${INSTALLER}"

# Download installer
echo "Downloading $URL ..."
curl -fsSL "$URL" -o "/tmp/$INSTALLER"

# Run installer silently (-b), install to $PREFIX (-p)
bash "/tmp/$INSTALLER" -b -p "$PREFIX"

# Clean up
rm -f "/tmp/$INSTALLER"

# Initialize conda (for current shell only)
eval "$("$PREFIX/bin/conda" shell.bash hook)"

# Prevent auto-activation of base environment
"$PREFIX/bin/conda" config --system --set auto_activate_base false

echo "✅ Miniconda installed at $PREFIX"
echo "👉 Restart your shell or run: source ~/.bashrc"
echo "   Then use: conda activate <env>"