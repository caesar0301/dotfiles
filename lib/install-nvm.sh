#!/bin/bash
###################################################
# Node Version Manager (nvm) Installer
# https://github.com/nvm-sh/nvm
#
# Installs nvm with shell integration
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  if [[ -d "$HOME/.nvm" ]]; then
    info "nvm already installed at $HOME/.nvm"
    exit 0
  fi

  info "Installing Node Version Manager (nvm)..."

  # Get latest nvm version
  local nvm_version
  nvm_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null)
  nvm_version=${nvm_version:-"v0.39.0"} # fallback version

  # Install nvm
  local install_url="https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh"
  if curl -o- "$install_url" | bash; then
    success "nvm installed successfully"

    # Verify installation
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    if command -v nvm >/dev/null 2>&1; then
      info "nvm verification successful: $(nvm --version)"
    else
      warn "nvm installed but not available in current session. Please restart your shell."
    fi
  else
    error "Failed to install nvm"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
