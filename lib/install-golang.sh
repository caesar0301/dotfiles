#!/bin/bash
###################################################
# Go Programming Language Installer
# https://go.dev/
#
# Installs Go with platform-specific binary selection
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  if checkcmd go; then
    info "Go already installed: $(go version)"
    exit 0
  fi

  info "Installing Go..."
  local godl="https://go.dev/dl"
  local gover=${1:-"1.24.2"}
  local custom_goroot="$HOME/.local/go"

  create_dir "$(dirname "$custom_goroot")"

  local GO_RELEASE
  if is_macos; then
    if is_x86_64; then
      GO_RELEASE="go${gover}.darwin-amd64"
    elif is_arm64; then
      GO_RELEASE="go${gover}.darwin-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  else # is_linux
    if is_x86_64; then
      GO_RELEASE="go${gover}.linux-amd64"
    elif is_arm64; then
      GO_RELEASE="go${gover}.linux-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  fi

  local link="${godl}/${GO_RELEASE}.tar.gz"
  info "Downloading Go from $link"
  curl -k -L --progress-bar "$link" | tar -xz -C "$(dirname "$custom_goroot")"
  success "Go installed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
