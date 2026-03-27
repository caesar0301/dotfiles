#!/bin/bash
###################################################
# Claude AI Agent Installer
#
# Installs Claude Code CLI and claude-code-router (CCR)
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

usage() {
  cat <<EOF
Claude AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --autostart    Enable pm2 autostart for ccr
  -h, --help     Show this help message and exit

Examples:
  $(basename "$0")                   # Install Claude Code and CCR (no autostart)
  $(basename "$0") --autostart       # Install with pm2 autostart for ccr

Note: Claude Code CLI requires Node.js >= 20 and npm >= 20
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

  info "Installing Claude AI agent..."

  # Install Claude code CLI
  install_claude_code_cli

  # Install claude-code-router via npm
  npm_install_lib "@musistudio/claude-code-router"

  # Install claude-code-router config file
  install_claude_code_router_config

  # Setup pm2 autostart if enabled
  if [[ "$enable_autostart" == "true" ]]; then
    setup_ccr_autostart
  else
    info "Skipping pm2 autostart setup (use --autostart to enable)"
  fi

  success "Claude AI agent installation completed"
  echo ""
  info "Post-installation steps:"
  echo ""
  info "1. Add the following to your bashrc or zshrc:"
  echo "   eval \"\$(ccr activate)\""
  echo ""
  info "2. Set essential environment variables for claude-code-router:"
  echo "   export DASHSCOPE_BASE_URL=\"your-dashscope-base-url\""
  echo "   export DASHSCOPE_API_KEY=\"your-dashscope-api-key\""
  echo "   export DASHSCOPE_CP_BASE_URL=\"your-coding-plan-base-url\""
  echo "   export DASHSCOPE_CP_API_KEY=\"your-coding-plan-api-key\""
  echo "   export GEMINI_API_KEY=\"your-gemini-api-key\""
  echo ""
  info "3. Restart ccr to apply the installed configuration:"
  echo "   ccr restart"
  echo ""
  info "4. Verify ccr is running:"
  echo "   ccr status"
  echo ""
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
