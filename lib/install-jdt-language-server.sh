#!/bin/bash
###################################################
# jdt-language-server Installer
# https://github.com/eclipse/eclipse.jdt.ls
#
# Installs jdt-language-server for Java development
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  info "Installing jdt-language-server..."
  local dpath="$HOME/.local/share/jdt-language-server"
  local jdtdl="https://download.eclipse.org/jdtls/milestones/1.23.0/jdt-language-server-1.23.0-202304271346.tar.gz"

  if [ ! -e "$dpath/bin/jdtls" ]; then
    create_dir "$dpath"
    curl -L --progress-bar "$jdtdl" | tar zxf - -C "$dpath"
    success "jdt-language-server installed successfully"
  else
    info "$dpath/bin/jdtls already exists"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
