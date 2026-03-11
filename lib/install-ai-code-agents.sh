#!/bin/bash
###################################################
# AI Code Agents Installer
#
# Installs various AI code agents and tools
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

usage() {
  cat <<EOF
AI Code Agents Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --claude       Install Claude Code and claude-code-router
  --opencode     Install opencode
  --cursor       Install Cursor agent
  --all          Install all agents (default if no options specified)
  --autostart    Enable pm2 autostart for ccr and opencode-web (independent of --all)
  -h, --help     Show this help message and exit

Examples:
  $(basename "$0")                      # Install all agents (no autostart)
  $(basename "$0") --all                # Install all agents (no autostart)
  $(basename "$0") --claude             # Install only Claude Code and router
  $(basename "$0") --all --autostart    # Install all agents with autostart
  $(basename "$0") --claude --opencode  # Install Claude and opencode only

Note: --autostart is not included in --all and must be specified separately
EOF
}

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

  # Try primary installation method (curl)
  if curl -fsSL https://claude.ai/install.sh | bash; then
    success "Claude code CLI installed/updated successfully via curl"
    return 0
  fi

  # Fallback to npm installation if curl fails
  warn "Curl installation failed, trying npm installation as fallback..."
  if npm install -g @anthropic-ai/claude-code; then
    success "Claude code CLI installed/updated successfully via npm"
  else
    error "Failed to install/update Claude code CLI via both curl and npm"
    return 1
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

# Setup pm2 autostart for opencode-web
# This configures opencode web server to start automatically on system boot
setup_opencode_autostart() {
  # Check if pm2 is available
  if ! command -v pm2 >/dev/null 2>&1; then
    info "Installing pm2 globally..."
    if npm install -g pm2; then
      success "pm2 installed successfully"
    else
      warn "Failed to install pm2, skipping opencode autostart setup"
      return 0
    fi
  fi

  # Check if opencode is available
  if ! command -v opencode >/dev/null 2>&1; then
    warn "opencode command not found, skipping autostart setup"
    return 0
  fi

  # Check if opencode-web is already managed by pm2
  if pm2 describe opencode-web >/dev/null 2>&1; then
    info "opencode-web is already managed by pm2, checking status..."
    pm2 status
    info "To restart: pm2 restart opencode-web"
    info "To delete: pm2 delete opencode-web"
    return 0
  fi

  info "Setting up pm2 autostart for opencode-web..."

  # Start opencode-web with pm2
  if pm2 start "opencode web --hostname 0.0.0.0 --port 14096" --name "opencode-web"; then
    success "opencode-web started with pm2"
    pm2 status
  else
    warn "Failed to start opencode-web with pm2"
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

  info "To check opencode-web status: pm2 status"
  info "To view opencode-web logs: pm2 logs opencode-web"
  info "To restart opencode-web: pm2 restart opencode-web"
  info "To delete opencode-web: pm2 delete opencode-web"
}

# Main installation function
main() {
  local install_claude=false
  local install_opencode=false
  local install_cursor=false
  local enable_autostart=false
  local any_agent_specified=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --claude)
      install_claude=true
      any_agent_specified=true
      shift
      ;;
    --opencode)
      install_opencode=true
      any_agent_specified=true
      shift
      ;;
    --cursor)
      install_cursor=true
      any_agent_specified=true
      shift
      ;;
    --all)
      install_claude=true
      install_opencode=true
      install_cursor=true
      any_agent_specified=true
      shift
      ;;
    --autostart)
      enable_autostart=true
      shift
      ;;
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

  # If no agent specified, default to installing all agents
  if [[ "$any_agent_specified" == "false" ]]; then
    info "No specific agents specified, installing all agents by default..."
    install_claude=true
    install_opencode=true
    install_cursor=true
  fi

  info "Installing AI code agents..."

  # Install cursor agent CLI
  if [[ "$install_cursor" == "true" ]]; then
    install_cursor_agent_cli
  fi

  # Install claude code CLI and router
  if [[ "$install_claude" == "true" ]]; then
    install_claude_code_cli

    # Install claude-code-router via npm
    npm_install_lib "@musistudio/claude-code-router"

    # Install claude-code-router config file
    install_claude_code_router_config
  fi

  # Install opencode
  if [[ "$install_opencode" == "true" ]]; then
    # Install opencode via npm
    npm_install_lib "opencode-ai@latest" "chrome-devtools-mcp@latest"

    # Install opencode config file and plugin directory
    install_opencode_config
    install_opencode_plugin
  fi

  # Setup pm2 autostart if enabled
  if [[ "$enable_autostart" == "true" ]]; then
    info "Enabling pm2 autostart for services..."

    # Setup pm2 autostart for ccr (only if claude is installed)
    if [[ "$install_claude" == "true" ]]; then
      setup_ccr_autostart
    fi

    # Setup pm2 autostart for opencode-web (only if opencode is installed)
    if [[ "$install_opencode" == "true" ]]; then
      setup_opencode_autostart
    fi
  else
    info "Skipping pm2 autostart setup (use --autostart to enable)"
  fi

  success "AI code agents installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
