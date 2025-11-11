#!/bin/bash
###################################################
# Universal Ctags Installer
# https://github.com/universal-ctags/ctags
#
# Installs universal-ctags (required by Tagbar)
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  # Check if a compatible ctags is already installed
  if checkcmd ctags; then
    # Verify it's universal-ctags or exuberant-ctags, not BSD/GNU Emacs ctags
    local ctags_version
    ctags_version=$(ctags --version 2>/dev/null || echo "")
    if echo "$ctags_version" | grep -qiE "(universal|exuberant)"; then
      info "universal-ctags or exuberant-ctags already installed"
      info "Version: $(ctags --version | head -n1)"
      exit 0
    else
      warn "Found incompatible ctags: $(ctags --version | head -n1)"
      warn "Installing universal-ctags to replace it..."
    fi
  fi

  if checkcmd brew; then
    info "Installing universal-ctags via Homebrew..."
    if brew install universal-ctags; then
      # Link universal-ctags, overwriting any existing ctags
      if ! brew link --overwrite universal-ctags 2>/dev/null; then
        warn "Failed to link universal-ctags automatically"
        warn "You may need to run: brew link --overwrite universal-ctags"
      fi
      success "universal-ctags installed successfully"
      info "Version: $(ctags --version 2>/dev/null | head -n1 || echo 'unknown')"
      exit 0
    else
      error "Failed to install universal-ctags via Homebrew"
      exit 1
    fi
  fi

  error "Homebrew not found. Please install universal-ctags manually."
  error "On macOS: brew install universal-ctags"
  error "On Linux: See https://github.com/universal-ctags/ctags"
  exit 1
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
