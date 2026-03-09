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
source "$SCRIPT_DIR/shlib.sh"

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

  info "To use claude-code plugin in vscode via ccr, you could set claudeCode.environmentVariables:"
  info "  - DISABLE_PROMPT_CACHING: 0"
  info "  - ANTHROPIC_API_KEY: your-api-secret"
  info "  - ANTHROPIC_BASE_URL: http://127.0.0.1:53456"
  info ""
  info "Or set claude code wrapper to $HOME/.local/bin/ccr_wrapper.sh"
}

# Install opencode config file
# Only installs if the destination file doesn't exist
install_opencode_config() {
  local config_src="$SCRIPT_DIR/../opencode/opencode.json"
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

# Install opencode plugin directory
# Supports soft link or copy based on global LINK_INSTEAD_OF_COPY
install_opencode_plugin() {
  local plugin_src="$SCRIPT_DIR/../opencode/plugin"
  local plugin_dest="$HOME/.config/opencode/plugin"

  [[ -d "$plugin_src" ]] || {
    warn "opencode plugin directory not found at $plugin_src, skipping plugin installation"
    return 0
  }

  info "Installing opencode plugin..."
  install_file_pair "$plugin_src" "$plugin_dest"
}

# Install Cursor agent CLI (always installs latest version)
install_cursor_agent_cli() {
  # Check if Cursor agent is already installed
  if command -v cursor-agent >/dev/null 2>&1; then
    info "Cursor agent CLI already installed, updating to latest version..."
  else
    info "Installing Cursor agent CLI..."
  fi

  if curl https://cursor.com/install -fsS | bash; then
    success "Cursor agent CLI installed/updated successfully"
  else
    warn "Failed to install/update Cursor agent CLI"
  fi
}

# Install Claude code CLI (always installs latest version)
install_claude_code_cli() {
  # Check if Claude code CLI is already installed
  if command -v claude >/dev/null 2>&1; then
    info "Claude code CLI already installed, updating to latest version..."
  else
    info "Installing claude code CLI..."
  fi

  if curl -fsSL https://claude.ai/install.sh | bash; then
    success "Claude code CLI installed/updated successfully"
  else
    warn "Failed to install/update Claude code CLI"
  fi
}

# Setup pm2 autostart for ccr (claude-code-router)
# This configures ccr to start automatically on system boot
setup_ccr_autostart() {
  # Check if pm2 is available
  if ! command -v pm2 >/dev/null 2>&1; then
    info "Installing pm2 globally..."
    if npm install -g pm2; then
      success "pm2 installed successfully"
    else
      warn "Failed to install pm2, skipping ccr autostart setup"
      return 0
    fi
  fi

  # Check if ccr is available
  if ! command -v ccr >/dev/null 2>&1; then
    warn "ccr command not found, skipping autostart setup"
    return 0
  fi

  # Check if ccr is already managed by pm2
  if pm2 describe ccr >/dev/null 2>&1; then
    info "ccr is already managed by pm2, skipping autostart setup"
    return 0
  fi

  info "Setting up pm2 autostart for ccr..."

  # Start ccr with pm2
  if pm2 start ccr --name ccr -- start; then
    success "ccr started with pm2"
  else
    warn "Failed to start ccr with pm2"
    return 0
  fi

  # Save the pm2 process list
  if pm2 save; then
    success "pm2 process list saved"
  else
    warn "Failed to save pm2 process list"
    return 0
  fi

  # Set up startup script for current platform
  info "Configuring pm2 startup for your platform..."
  local startup_command
  startup_command=$(pm2 startup 2>&1 | grep -E "^sudo|^pm2 startup" | head -n1)

  if [[ -n "$startup_command" ]]; then
    info "Run the following command to complete startup configuration:"
    info "  $startup_command"
  else
    # If no sudo required or already configured
    pm2 startup
    success "pm2 startup configured"
  fi

  info "To check ccr status: pm2 status ccr"
  info "To view ccr logs: pm2 logs ccr"
  info "To restart ccr: pm2 restart ccr"
}

# Main installation function
main() {
  info "Installing AI code agents..."

  # Install cursor agent CLI
  install_cursor_agent_cli

  # Install claude code CLI
  install_claude_code_cli

  # Install agents using npm
  npm_install_lib "@musistudio/claude-code-router" "opencode-ai@latest" "chrome-devtools-mcp@latest"

  # Install claude-code-router config file
  install_claude_code_router_config

  # Install opencode config file and plugin directory
  install_opencode_config
  install_opencode_plugin

  # Setup pm2 autostart for ccr
  setup_ccr_autostart

  success "AI code agents installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
