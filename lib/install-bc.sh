#!/bin/bash
###################################################
# bc (Basic Calculator) Installer
# https://www.gnu.org/software/bc/
#
# Installs bc for version comparisons and calculations
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
install_bc() {
  # Check if bc is already installed
  if checkcmd bc; then
    info "bc (basic calculator) already installed: $(bc --version 2>/dev/null | head -1 || echo 'installed')"
    return 0
  fi

  # Only install on Linux (bc is typically pre-installed on macOS)
  if ! is_linux; then
    info "bc installation skipped (not on Linux)"
    return 0
  fi

  info "Installing bc (basic calculator)..."

  if checkcmd apt-get; then
    sudo apt-get update && sudo apt-get install -y bc
  elif checkcmd yum; then
    sudo yum install -y bc
  elif checkcmd dnf; then
    sudo dnf install -y bc
  elif checkcmd pacman; then
    sudo pacman -S --noconfirm bc
  else
    error "Could not install bc automatically, no supported package manager found"
    return 1
  fi

  # Verify installation
  if command -v bc >/dev/null 2>&1; then
    success "bc installed successfully"
    return 0
  else
    error "bc installation verification failed"
    return 1
  fi
}

# Main function for standalone execution
main() {
  install_bc "$@"
  exit $?
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
