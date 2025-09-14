#!/bin/bash
###################################################
# SSH Manager Installer
# https://github.com/Adembc/lazyssh
#
# Installs lazyssh with comprehensive setup and verification
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  if checkcmd lazyssh; then
    info "lazyssh already installed"
    exit 0
  fi

  info "Installing lazyssh..."

  # Detect latest version
  LATEST_TAG=$(curl -fsSL https://api.github.com/repos/Adembc/lazyssh/releases/latest | jq -r .tag_name)

  # Download the correct binary for your system
  curl -LJO "https://github.com/Adembc/lazyssh/releases/download/${LATEST_TAG}/lazyssh_$(uname)_$(uname -m).tar.gz"

  # Extract the binary
  tar -xzf lazyssh_$(uname)_$(uname -m).tar.gz

  # Move to /usr/local/bin or another directory in your PATH
  sudo mv lazyssh $HOME/.local/bin

  rm -rf lazyssh_$(uname)_$(uname -m).tar.gz

  # Verify installation
  if command -v lazyssh >/dev/null 2>&1; then
    info "lazyssh verification successful"
  else
    error "lazyssh installation verification failed"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
