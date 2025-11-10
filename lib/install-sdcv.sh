#!/usr/bin/env bash
###################################################
# StarDict CLI (sdcv) Installer
# https://github.com/Dushistov/sdcv
#
# Installs sdcv and downloads dictionaries
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

set -euo pipefail

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Install sdcv via brew
install_sdcv() {
  if checkcmd sdcv; then
    info "sdcv is already installed."
    return
  fi

  if ! checkcmd brew; then
    error "Homebrew is not installed. Please install Homebrew first."
  fi

  info "Installing sdcv via Homebrew..."
  brew install sdcv
  success "sdcv installed successfully."
}

# Get dictionary directory based on OS
get_dict_dir() {
  local os=$1
  if [[ "$os" == "linux" ]]; then
    echo "/usr/share/stardict/dic"
  elif [[ "$os" == "darwin" ]]; then
    echo "/Applications/StarDict.app/Contents/Resources/share/stardict/dic"
  else
    error "Unsupported OS: $os"
  fi
}

# Create dictionary directory (with sudo if needed)
create_dict_dir() {
  local dict_dir=$1

  if [[ -d "$dict_dir" ]]; then
    info "Dictionary directory already exists: $dict_dir"
    return
  fi

  info "Creating dictionary directory: $dict_dir"

  # Check if we need sudo (system directories)
  if [[ "$dict_dir" == /usr/* ]] || [[ "$dict_dir" == /Applications/* ]]; then
    check_sudo_access
    sudo mkdir -p "$dict_dir"
  else
    create_dir "$dict_dir"
  fi

  success "Dictionary directory created: $dict_dir"
}

# Extract dictionary archive
extract_dict() {
  local temp_file=$1
  local dict_dir=$2
  local filename=$3

  info "Extracting $filename to $dict_dir..."

  # Check if we need sudo (system directories)
  if [[ "$dict_dir" == /usr/* ]] || [[ "$dict_dir" == /Applications/* ]]; then
    check_sudo_access
    if sudo tar -xjf "$temp_file" -C "$dict_dir"; then
      rm -f "$temp_file"
      success "Successfully installed dictionary: $filename"
      return 0
    else
      rm -f "$temp_file"
      warn "Failed to extract dictionary: $filename"
      return 1
    fi
  else
    if tar -xjf "$temp_file" -C "$dict_dir"; then
      rm -f "$temp_file"
      success "Successfully installed dictionary: $filename"
      return 0
    else
      rm -f "$temp_file"
      warn "Failed to extract dictionary: $filename"
      return 1
    fi
  fi
}

# Download and install a dictionary
install_dict() {
  local url=$1
  local dict_dir=$2
  local filename=$(basename "$url")
  local temp_file="/tmp/$filename"

  info "Downloading dictionary: $filename"

  # Download using curl or wget (with error handling to allow continuation)
  if checkcmd curl; then
    if ! curl -fsSL --progress-bar "$url" -o "$temp_file"; then
      warn "Failed to download dictionary: $filename from $url"
      return 1
    fi
  elif checkcmd wget; then
    if ! wget -q --show-progress "$url" -O "$temp_file"; then
      warn "Failed to download dictionary: $filename from $url"
      return 1
    fi
  else
    error "Neither curl nor wget is available. Please install one of them."
  fi

  # Extract the downloaded dictionary
  extract_dict "$temp_file" "$dict_dir" "$filename"
}

# Main installation function
main() {
  info "Starting StarDict CLI (sdcv) installation..."

  # Detect OS
  local os
  os=$(get_os_name)
  info "Detected OS: $os"

  # Install sdcv
  install_sdcv

  # Get dictionary directory
  local dict_dir
  dict_dir=$(get_dict_dir "$os")

  # Create dictionary directory
  create_dict_dir "$dict_dir"

  # Dictionary URLs
  local -a dict_urls=(
    "https://stardict.uber.space/dict.org/stardict-dictd_www.dict.org_wn-2.4.2.tar.bz2"
    "https://stardict.uber.space/dict.org/stardict-oald-2.4.2.tar.bz2"
    "https://stardict.uber.space/zh_CN/stardict-oald-cn-2.4.2.tar.bz2"
    "https://stardict.uber.space/dict.org/stardict-longman-2.4.2.tar.bz2"
    "https://stardict.uber.space/dict.org/stardict-merrianwebster-2.4.2.tar.bz2"
  )

  # Install dictionaries
  info "Installing dictionaries..."
  local failed_dicts=0

  for url in "${dict_urls[@]}"; do
    if ! install_dict "$url" "$dict_dir"; then
      ((failed_dicts++))
    fi
  done

  # Summary
  echo ""
  info "============================================"
  if [[ $failed_dicts -eq 0 ]]; then
    success "Installation completed successfully!"
  else
    warn "Installation completed with $failed_dicts failed dictionary downloads."
  fi
  info "Dictionary location: $dict_dir"
  info "Test with: sdcv word"
  info "============================================"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
