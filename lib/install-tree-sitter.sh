#!/bin/bash
###################################################
# tree-sitter CLI Installer
# https://tree-sitter.github.io/tree-sitter/
#
# Installs the tree-sitter CLI, required by Neovim's
# :TSInstallFromGrammar for generating parsers from
# grammar.js sources (:TSInstall uses prebuilt parsers).
#
# Installation strategy (in priority order):
#   1. Homebrew formula (library-only on macOS, but links
#      a `tree-sitter` shim on some Linux distros)
#   2. cargo install tree-sitter-cli (Rust toolchain)
#   3. npm install -g tree-sitter-cli (Node.js)
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

# Main installation function
install_tree_sitter() {
  # Already installed?
  if checkcmd tree-sitter; then
    info "tree-sitter already installed: $(tree-sitter --version 2>/dev/null || echo 'installed')"
    return 0
  fi

  info "Installing tree-sitter CLI..."

  # Strategy 1: Homebrew (works on Linux; on macOS the formula is
  # library-only and does not ship the CLI, so we fall through).
  if checkcmd brew; then
    if is_linux; then
      if brew_install tree-sitter 2>/dev/null && checkcmd tree-sitter; then
        success "tree-sitter installed via Homebrew"
        return 0
      fi
    else
      # On macOS the formula only installs the library; skip silently.
      : # fall through to cargo/npm
    fi
  fi

  # Strategy 2: cargo (preferred on macOS — avoids npm TLS issues)
  if checkcmd cargo; then
    if cargo install tree-sitter-cli 2>/dev/null; then
      # Ensure cargo bin is on PATH for this session
      [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
      if checkcmd tree-sitter; then
        success "tree-sitter installed via cargo: $(tree-sitter --version)"
        return 0
      fi
    fi
    warn "cargo install tree-sitter-cli failed, trying npm fallback"
  else
    warn "cargo not available, skipping cargo install path"
  fi

  # Strategy 3: npm (fallback; may hit TLS cert errors in some envs)
  if checkcmd npm; then
    if npm_install_lib tree-sitter-cli 2>/dev/null && checkcmd tree-sitter; then
      success "tree-sitter installed via npm"
      return 0
    fi
    warn "npm install tree-sitter-cli failed"
  else
    warn "npm not available, skipping npm install path"
  fi

  error "Could not install tree-sitter CLI automatically."
  error "Install manually via one of:"
  error "  cargo install tree-sitter-cli"
  error "  npm install -g tree-sitter-cli"
  error "  brew install tree-sitter  (Linux only)"
  return 1
}

# Main function for standalone execution
main() {
  install_tree_sitter "$@"
  exit $?
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
