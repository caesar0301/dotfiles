#!/bin/bash
###################################################
# jenv Java Version Manager Installer
# https://github.com/jenv/jenv
#
# Installs jenv with platform detection and shell integration
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  if checkcmd jenv; then
    info "jenv already installed: $(jenv version-name 2>/dev/null || echo 'installed')"
    exit 0
  fi

  info "Installing jenv Java version manager..."

  if is_macos; then
    if checkcmd brew; then
      brew install jenv || error "Failed to install jenv via Homebrew"
    else
      error "Homebrew not found, required for jenv installation on macOS"
    fi
  elif is_linux; then
    if [[ ! -d "$HOME/.jenv" ]]; then
      git clone --depth 1 https://github.com/jenv/jenv.git "$HOME/.jenv" || error "Failed to clone jenv repository"
      export PATH="$HOME/.jenv/bin:$PATH"

      # Add to shell configuration
      local shell_config
      shell_config=$(current_shell_config)
      if ! grep -q 'jenv init' "$shell_config" 2>/dev/null; then
        info "Adding jenv to shell configuration"
        {
          echo '# jenv configuration'
          echo 'export PATH="$HOME/.jenv/bin:$PATH"'
          echo 'eval "$(jenv init -)"'
        } >>"$shell_config"
      fi
    fi
  else
    error "Unsupported platform for jenv installation"
  fi

  # Initialize jenv in current session
  eval "$(jenv init -)" 2>/dev/null || warn "Failed to initialize jenv in current session"
  success "jenv installed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
