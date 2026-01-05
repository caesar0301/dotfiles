#!/bin/bash
###################################################
# rbenv Ruby Version Manager Installer
# https://github.com/rbenv/rbenv
#
# Installs rbenv with platform detection and shell integration
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  if checkcmd rbenv; then
    info "rbenv already installed: $(rbenv version-name 2>/dev/null || echo 'installed')"
    exit 0
  fi

  info "Installing rbenv Ruby version manager..."

  if is_macos; then
    if checkcmd brew; then
      brew install rbenv ruby-build || error "Failed to install rbenv via Homebrew"
    else
      error "Homebrew not found, required for rbenv installation on macOS"
    fi
  elif is_linux; then
    if [[ ! -d "$HOME/.rbenv" ]]; then
      git clone --depth 1 https://github.com/rbenv/rbenv.git "$HOME/.rbenv" || error "Failed to clone rbenv repository"
      export PATH="$HOME/.rbenv/bin:$PATH"

      # Install ruby-build plugin
      if [[ ! -d "$HOME/.rbenv/plugins/ruby-build" ]]; then
        info "Installing ruby-build plugin..."
        mkdir -p "$HOME/.rbenv/plugins"
        git clone --depth 1 https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build" || error "Failed to clone ruby-build plugin"
      fi

      # Add to shell configuration
      local shell_config
      shell_config=$(current_shell_config)
      if ! grep -q 'rbenv init' "$shell_config" 2>/dev/null; then
        info "Adding rbenv to shell configuration"
        {
          echo '# rbenv configuration'
          echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
          echo 'eval "$(rbenv init -)"'
        } >>"$shell_config"
      fi
    fi
  else
    error "Unsupported platform for rbenv installation"
  fi

  # Initialize rbenv in current session
  eval "$(rbenv init -)" 2>/dev/null || warn "Failed to initialize rbenv in current session"
  success "rbenv installed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
