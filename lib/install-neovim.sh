#!/bin/bash
###################################################
# Neovim Text Editor Installer
# https://neovim.io/
#
# Installs Neovim with platform-specific binary selection
#
# Arguments:
#   $1 - Neovim version to install (default: 0.11.0)
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  # Check if Neovim is already installed
  if checkcmd nvim; then
    info "Neovim already installed: $(nvim --version | head -1)"
    exit 0
  fi

  info "Installing Neovim..."

  # Set version and create local directory
  local nvimver=${1:-"0.11.0"}
  create_dir "$HOME/.local"

  # Determine Neovim release based on OS and architecture
  local NVIM_RELEASE
  if is_macos; then
    if is_x86_64; then
      NVIM_RELEASE="nvim-macos-x86_64"
    elif is_arm64; then
      NVIM_RELEASE="nvim-macos-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  else # is_linux
    if is_x86_64; then
      NVIM_RELEASE="nvim-linux-x86_64"
    elif is_arm64; then
      NVIM_RELEASE="nvim-linux-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  fi

  # Download and extract Neovim
  local link="https://github.com/neovim/neovim/releases/download/v${nvimver}/${NVIM_RELEASE}.tar.gz"
  info "Downloading Neovim from $link"
  curl -k -L --progress-bar "$link" | tar -xz --strip-components=1 -C "$HOME/.local"
  success "Neovim installed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
