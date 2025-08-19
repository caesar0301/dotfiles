#!/bin/bash
###################################################
# fzf Fuzzy Finder Installer
# https://github.com/junegunn/fzf
#
# Installs fzf with shell integration
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  # Check if fzf is already installed
  if [ -e "$HOME/.fzf" ]; then
    info "fzf already installed at $HOME/.fzf"
    exit 0
  fi

  info "Installing fzf to $HOME/.fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all

  # Get current shell configuration file
  local shellconfig
  shellconfig=$(current_shell_config)

  # Check if fzf is already sourced in shell config
  if ! grep -r "source.*\.fzf\.zsh" "$shellconfig" >/dev/null; then
    # Add fzf sourcing to shell configuration
    local config='[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
    echo >>"$shellconfig"
    echo "# automatic configs by cool-dotfiles nvim installer" >>"$shellconfig"
    echo "$config" >>"$shellconfig"
    success "fzf shell integration configured"
  fi

  success "fzf installed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
