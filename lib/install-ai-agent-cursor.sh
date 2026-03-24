#!/bin/bash
###################################################
# Cursor AI Agent Installer
#
# Installs Cursor agent CLI
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

usage() {
  cat <<EOF
Cursor AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help     Show this help message and exit

Examples:
  $(basename "$0")                   # Install Cursor agent CLI

Note: Cursor agent requires a compatible environment
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

# Install Cursor agent CLI (always installs latest version)
install_cursor_agent_cli() {
  # Check if Cursor agent is already installed
  if command -v cursor-agent >/dev/null 2>&1; then
    info "Cursor agent CLI already installed, updating to latest version..."
  else
    info "Installing Cursor agent CLI..."
  fi

  # Try to install Cursor agent via official installer
  if curl https://cursor.com/install -fsS | bash; then
    success "Cursor agent CLI installed/updated successfully"
    return 0
  else
    error "Failed to install/update Cursor agent CLI"
    return 1
  fi
}

# Main installation function
main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      usage
      exit 1
      ;;
    esac
  done

  info "Installing Cursor AI agent..."

  # Install Cursor agent CLI
  install_cursor_agent_cli

  success "Cursor AI agent installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
