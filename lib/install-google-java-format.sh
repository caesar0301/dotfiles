#!/bin/bash
###################################################
# google-java-format Installer
# https://github.com/google/google-java-format
#
# Installs google-java-format for Java code formatting
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  info "Installing google-java-format..."
  local dpath="$HOME/.local/share/google-java-format"
  local fmtdl="https://github.com/google/google-java-format/releases/download/v1.17.0/google-java-format-1.17.0-all-deps.jar"

  if ! compgen -G "$dpath/google-java-format*.jar" >/dev/null; then
    create_dir "$dpath"
    curl -L --progress-bar --create-dirs "$fmtdl" -o "$dpath/google-java-format-all-deps.jar"
    success "google-java-format installed successfully"
  else
    info "$dpath/google-java-format-all-deps.jar already installed"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
