#!/bin/bash
###################################################
# Hack Nerd Font Installer
# https://github.com/ryanoasis/nerd-fonts
#
# Installs Hack Nerd Font with font cache update
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  info "Installing Hack Nerd Font and updating font cache..."

  # Check if fontconfig tools are available
  if ! checkcmd fc-list; then
    warn "Fontconfig tools (fc-list, fc-cache) not found."
    exit 0
  fi

  # Set font directory based on OS
  local FONTDIR="$HOME/.local/share/fonts"
  if is_macos; then
    FONTDIR="$HOME/Library/Fonts"
  fi

  # Check if font is already installed
  if ! fc-list | grep "Hack Nerd Font" >/dev/null; then
    # Create font directory and download font
    create_dir "$FONTDIR"
    curl -L --progress-bar "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.tar.xz" | tar xJ -C "$FONTDIR"

    # Update font cache
    fc-cache -f
    success "Hack Nerd Font installed successfully"
  else
    info "Hack Nerd Font already installed"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
