#!/bin/bash
###################################################
# uv Python Package Manager Installer
# https://github.com/astral-sh/uv
#
# Installs uv Python package manager with verification
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  checkcmd uv && {
    info "uv already installed: $(uv --version)"
    exit 0
  }

  info "Installing uv Python package manager..."
  if curl -LsSf https://astral.sh/uv/install.sh | sh; then
    success "uv installed successfully"
    # Verify installation
    export PATH="$HOME/.cargo/bin:$PATH"
    checkcmd uv && info "uv version: $(uv --version)"
  else
    error "Failed to install uv"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
