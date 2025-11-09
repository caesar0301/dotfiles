#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    echo_error "Unsupported OS: $OSTYPE"
    exit 1
  fi
}

# Install sdcv via brew
install_sdcv() {
  echo_info "Installing sdcv via Homebrew..."

  if ! command -v brew &>/dev/null; then
    echo_error "Homebrew is not installed. Please install Homebrew first."
    exit 1
  fi

  if command -v sdcv &>/dev/null; then
    echo_info "sdcv is already installed."
  else
    brew install sdcv
    echo_info "sdcv installed successfully."
  fi
}

# Get dictionary directory based on OS
get_dict_dir() {
  local os=$1
  if [[ "$os" == "linux" ]]; then
    echo "/usr/share/stardict/dic"
  elif [[ "$os" == "macos" ]]; then
    echo "/Applications/StarDict.app/Contents/Resources/share/stardict/dic"
  fi
}

# Create dictionary directory
create_dict_dir() {
  local dict_dir=$1

  echo_info "Creating dictionary directory: $dict_dir"

  if [[ ! -d "$dict_dir" ]]; then
    sudo mkdir -p "$dict_dir"
    echo_info "Dictionary directory created."
  else
    echo_info "Dictionary directory already exists."
  fi
}

# Download and install a dictionary
install_dict() {
  local url=$1
  local dict_dir=$2
  local filename=$(basename "$url")
  local temp_file="/tmp/$filename"

  echo_info "Downloading $filename..."

  if curl -fsSL "$url" -o "$temp_file"; then
    echo_info "Extracting $filename to $dict_dir..."
    sudo tar -xjf "$temp_file" -C "$dict_dir"
    rm -f "$temp_file"
    echo_info "Successfully installed $filename"
  else
    echo_error "Failed to download $filename from $url"
    return 1
  fi
}

# Main installation function
main() {
  echo_info "Starting StarDict CLI (sdcv) installation..."

  # Detect OS
  os=$(detect_os)
  echo_info "Detected OS: $os"

  # Install sdcv
  install_sdcv

  # Get dictionary directory
  dict_dir=$(get_dict_dir "$os")

  # Create dictionary directory
  create_dict_dir "$dict_dir"

  # Dictionary URLs
  declare -a dict_urls=(
    "https://stardict.uber.space/dict.org/stardict-dictd_www.dict.org_wn-2.4.2.tar.bz2"
    "https://stardict.uber.space/dict.org/stardict-oald-2.4.2.tar.bz2"
    "https://stardict.uber.space/zh_CN/stardict-oald-cn-2.4.2.tar.bz2"
    "https://stardict.uber.space/dict.org/stardict-longman-2.4.2.tar.bz2"
    "https://stardict.uber.space/dict.org/stardict-merrianwebster-2.4.2.tar.bz2"
  )

  # Install dictionaries
  echo_info "Installing dictionaries..."
  failed_dicts=0

  for url in "${dict_urls[@]}"; do
    if ! install_dict "$url" "$dict_dir"; then
      ((failed_dicts++))
    fi
  done

  # Summary
  echo ""
  echo_info "============================================"
  if [[ $failed_dicts -eq 0 ]]; then
    echo_info "✓ Installation completed successfully!"
  else
    echo_warn "Installation completed with $failed_dicts failed dictionary downloads."
  fi
  echo_info "Dictionary location: $dict_dir"
  echo_info "Test with: sdcv word"
  echo_info "============================================"
}

# Run main function
main
