#!/bin/bash
###################################################
# AI Code Agents Installer
#
# Installs various AI code agents and tools
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  info "Installing AI code agents..."

  # Define AI code agents to install
  local agents="@qwen-code/qwen-code @iflow-ai/iflow-cli @google/gemini-cli @anthropic-ai/claude-code"

  # Install agents using npm
  npm_install_lib ${agents}

  # Install cursor agent CLI
  info "Installing Cursor agent CLI..."
  if curl https://cursor.com/install -fsS | bash; then
    success "Cursor agent CLI installed successfully"
  else
    warn "Failed to install Cursor agent CLI"
  fi

  success "AI code agents installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
