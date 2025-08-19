#!/bin/bash
###################################################
# pyenv Python Version Manager Installer
# https://github.com/pyenv/pyenv
#
# Installs pyenv with enhanced setup and verification
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  if [[ -d "$HOME/.pyenv" ]]; then
    info "pyenv already installed at $HOME/.pyenv"
    exit 0
  fi

  info "Installing pyenv Python version manager..."
  if curl -fsSL https://pyenv.run | bash; then
    success "pyenv installed successfully"

    # Add to shell configuration
    local shell_config
    shell_config=$(current_shell_config)
    if ! grep -q 'pyenv init' "$shell_config" 2>/dev/null; then
      info "Adding pyenv to shell configuration"
      {
        echo '# pyenv configuration'
        echo 'export PYENV_ROOT="$HOME/.pyenv"'
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
        echo 'eval "$(pyenv init -)"'
      } >>"$shell_config"
    fi
  else
    error "Failed to install pyenv"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
