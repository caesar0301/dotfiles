#!/bin/bash
###################################################
# Go Version Manager (GVM) Installer
# https://github.com/moovweb/gvm
#
# Installs GVM with comprehensive setup and verification
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  if checkcmd gvm; then
    info "gvm already installed: $(gvm version 2>/dev/null || echo 'installed')"
    exit 0
  fi

  if [[ -d "$HOME/.gvm" ]]; then
    warn "$HOME/.gvm already exists, skipping installation"
    exit 0
  fi

  info "Installing Go Version Manager (GVM)..."

  # Install GVM
  if bash -c "$(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"; then
    success "GVM installed successfully"
  else
    error "GVM installation failed"
  fi

  # Configure shell integration
  local shell_config gvm_line
  shell_config=$(current_shell_config)
  gvm_line='[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"'

  if ! grep -Fq "$gvm_line" "$shell_config" 2>/dev/null; then
    info "Adding GVM to shell configuration: $(basename "$shell_config")"
    echo "$gvm_line" >>"$shell_config"
  fi

  # Source GVM in current session
  # shellcheck disable=SC1090
  [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

  # Verify installation
  if command -v gvm >/dev/null 2>&1; then
    info "GVM verification successful: $(gvm version 2>/dev/null)"

    # Install default Go version
    local go_version="go1.24.2"
    info "Installing $go_version as default Go version..."
    if gvm install "$go_version" -B && gvm use "$go_version" --default; then
      success "$go_version installed and set as default"
    else
      warn "Failed to install default Go version, but GVM is ready"
    fi
  else
    error "GVM installation verification failed"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
