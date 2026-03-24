#!/bin/bash
###################################################
# OpenCode AI Agent Installer
#
# Installs OpenCode CLI and related configurations
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

usage() {
  cat <<EOF
OpenCode AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --autostart    Enable pm2 autostart for opencode-web
  -h, --help     Show this help message and exit

Examples:
  $(basename "$0")                   # Install OpenCode (no autostart)
  $(basename "$0") --autostart       # Install with pm2 autostart for opencode-web

Note: OpenCode requires Node.js >= 20 and npm >= 20
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

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

# Install OpenCode CLI (always installs latest version)
install_opencode_cli() {
  # Check if OpenCode CLI is already installed
  if command -v opencode >/dev/null 2>&1; then
    info "OpenCode CLI already installed, updating to latest version..."
  else
    info "Installing OpenCode CLI..."
  fi

  # Install opencode and chrome-devtools-mcp via npm
  if npm_install_lib "opencode-ai@latest" "chrome-devtools-mcp@latest"; then
    success "OpenCode CLI installed/updated successfully"
  else
    error "Failed to install/update OpenCode CLI"
    return 1
  fi
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
  local enable_autostart=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
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

  info "Installing OpenCode AI agent..."

  # Install OpenCode CLI
  install_opencode_cli

  # Install opencode config file and plugin directory
  install_opencode_config
  install_opencode_plugin

  # Setup pm2 autostart if enabled
  if [[ "$enable_autostart" == "true" ]]; then
    setup_opencode_autostart
  else
    info "Skipping pm2 autostart setup (use --autostart to enable)"
  fi

  success "OpenCode AI agent installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
