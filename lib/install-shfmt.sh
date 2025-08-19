#!/bin/bash
###################################################
# shfmt Shell Formatter Installer
# https://github.com/mvdan/sh
#
# Installs shfmt for shell script formatting
#
# Arguments:
#   $1 - shfmt version to install (default: v3.7.0)
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  # Check if shfmt is already installed
  if checkcmd shfmt; then
    info "shfmt already installed: $(shfmt --version)"
    exit 0
  fi

  info "Installing shfmt..."

  # Set version and filename based on OS
  local shfmtver=${1:-"v3.7.0"}
  local shfmtfile="shfmt_${shfmtver}_linux_amd64"
  if [ "$(uname)" == "Darwin" ]; then
    shfmtfile="shfmt_${shfmtver}_darwin_amd64"
  fi

  # Create bin directory and download shfmt
  create_dir "$HOME/.local/bin"
  curl -L --progress-bar "https://github.com/mvdan/sh/releases/download/${shfmtver}/$shfmtfile" -o "$HOME/.local/bin/shfmt"

  # Make shfmt executable
  chmod +x "$HOME/.local/bin/shfmt"
  success "shfmt installed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
