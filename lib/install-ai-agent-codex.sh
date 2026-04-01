#!/bin/bash
###################################################
# OpenAI Codex AI Agent Installer
#
# Installs OpenAI Codex CLI and oh-my-codex
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

usage() {
  cat <<EOF
OpenAI Codex AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help     Show this help message and exit

Examples:
  $(basename "$0")                   # Install OpenAI Codex and oh-my-codex

Note: OpenAI Codex requires Node.js >= 20 and npm >= 20
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

# Install OpenAI Codex CLI and oh-my-codex
install_codex_cli() {
  info "Installing OpenAI Codex CLI and oh-my-codex..."

  # Install both packages in one command
  if npm install -g @openai/codex oh-my-codex; then
    success "OpenAI Codex CLI and oh-my-codex installed successfully"
    return 0
  else
    error "Failed to install OpenAI Codex CLI and oh-my-codex"
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

  info "Installing OpenAI Codex AI agent..."

  # Install Codex CLI and oh-my-codex
  install_codex_cli

  success "OpenAI Codex AI agent installation completed"
  echo ""
  info "Post-installation steps:"
  echo ""
  info "1. Setup oh-my-codex:"
  echo "   omx setup"
  echo ""
  info "2. Configure with recommended settings:"
  echo "   omx --madmax --high"
  echo ""
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi