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

# Install claude-code-router config file
# Supports soft link or copy based on global LINK_INSTEAD_OF_COPY
# Only installs if the destination file doesn't exist
install_claude_code_router_config() {
  local config_src="$SCRIPT_DIR/claude-code-router.json"
  local config_dest="$HOME/.claude-code-router/config.json"

  [[ -e "$config_src" ]] || {
    warn "claude-code-router.json not found at $config_src, skipping config installation"
    return 0
  }

  # Only install if destination doesn't exist
  if [[ -e "$config_dest" ]]; then
    info "claude-code-router config already exists at $config_dest, skipping installation"
    return 0
  fi

  info "Installing claude-code-router config..."
  install_file_pair "$config_src" "$config_dest"
}

# Install opencode config file
# Only installs if the destination file doesn't exist
install_opencode_config() {
  local config_src="$SCRIPT_DIR/opencode.json"
  local config_dest="$HOME/.config/opencode/opencode.json"

  [[ -e "$config_src" ]] || {
    warn "opencode.json not found at $config_src, skipping config installation"
    return 0
  }

  # Only install if destination doesn't exist
  if [[ -e "$config_dest" ]]; then
    info "opencode config already exists at $config_dest, skipping installation"
    return 0
  fi

  info "Installing opencode config..."
  install_file_pair "$config_src" "$config_dest"
}

# Main installation function
main() {
  info "Installing AI code agents..."

  # Define AI code agents to install
  local agents="@anthropic-ai/claude-code \
    @musistudio/claude-code-router \
    opencode-ai@latest"

  # Install agents using npm
  npm_install_lib ${agents}

  # Install cursor agent CLI
  info "Installing Cursor agent CLI..."
  if curl https://cursor.com/install -fsS | bash; then
    success "Cursor agent CLI installed successfully"
  else
    warn "Failed to install Cursor agent CLI"
  fi

  # Install claude-code-router config file
  install_claude_code_router_config
  info "To use claude-code plugin in vscode via ccr, you could set claudeCode.environmentVariables:"
  info "  - DISABLE_PROMPT_CACHING: 0"
  info "  - ANTHROPIC_API_KEY: 1234"
  info "  - ANTHROPIC_BASE_URL: http://127.0.0.1:3456"
  info ""
  info "Or set claude code wrapper to $HOME/.local/bin/ccr_wrapper.sh"

  # Install opencode config file
  install_opencode_config

  success "AI code agents installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
