#!/bin/bash
###################################################
# Essential Development Tools Installer
# https://github.com/caesar0301/cool-dotfiles
#
# Installs essential development tools and utilities for a productive development environment.
#
# Features:
# - Python version management (pyenv)
# - Homebrew package manager (optional)
# - Development environment version managers
# - Language Server Protocol (LSP) support
# - Language formatters and linters
# - Hack Nerd Font for development icons
# - AI code agents support
# - Enhanced error handling and user feedback
#
# Usage:
#   Basic installation (utility scripts + pyenv):
#     ./lib/install-essentials.sh
#
#   With optional components:
#     INSTALL_EXTRA_VENV=1 ./lib/install-essentials.sh
#
#   AI code agents are installed by default (requires Node.js >= 20
#   and npm >= 20) when supported by the system.
#
# Environment Variables:
#   INSTALL_EXTRA_VENV=1    Install jenv, gvm, nvm version managers
#
# What Gets Installed:
#   - pyenv: Python version manager (always installed)
#   - fzf: Fuzzy finder (always installed)
#   - universal-ctags: Code navigation tool (always installed)
#   - cargo: Rust toolchain (always installed)
#   - Homebrew: Package manager (always installed)
#   - LSP servers: Language Server Protocol support (always installed)
#   - Hack Nerd Font: Icon font for development (always installed)
#   - Language formatters: Code formatting tools (always installed)
#   - jenv, gvm, nvm: Java/Go/Node version managers (if INSTALL_EXTRA_VENV=1)
#   - AI code agents: AI-powered development tools (installed by default,
#     requires npm >= 20)
#
# Post-Installation:
#   Utility scripts in ~/.dotfiles/bin are automatically added to PATH
#   via zsh/init.zsh. Restart your shell or run: exec $SHELL
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

# Configuration constants
readonly LOCAL_BIN_DIR="$HOME/.local/bin" # kept for compatibility

# Verify bin directory exists and is accessible
verify_bin_path() {
  local bin_dir="$SCRIPT_DIR/../bin"

  if [[ -d "$bin_dir" ]]; then
    info "Utility scripts directory: $bin_dir"
    local script_count
    script_count=$(find "$bin_dir" -type f ! -name "README.md" | wc -l | tr -d ' ')
    success "Found $script_count utility scripts (accessible via PATH after shell restart)"
  else
    warn "Utility scripts directory not found: $bin_dir"
  fi
}

# Install AI code agents
install_ai_code_agents() {
  # Check if system supports modern plugins (npm >= 20)
  if ! SUPPORTS_MODERN_PLUGINS; then
    warn "npm version 20 or higher is required for AI code agents installation"
    warn "Current npm version: $(npm --version 2>/dev/null || echo 'not installed')"
    warn "Please upgrade npm to continue with AI code agents installation"
    return 1
  fi

  success "System supports modern plugins (npm >= 20), proceeding with AI code agents installation"

  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-ai-code-agents.sh"
}

# Main installation function
main() {
  info "Starting essential development tools installation..."

  # Verify utility scripts directory
  verify_bin_path

  # Core dependencies - order matters! Homebrew must be installed before tools that depend on it
  local core_deps=(
    "install_pyenv"           # Python version manager
    "install_fzf"             # Fuzzy finder
    "install_homebrew"        # Homebrew package manager (always installed)
    "install_universal_ctags" # Universal ctags (required by Tagbar, may use Homebrew)
    "install_cargo"           # Rust and Cargo (conditionally based on kernel version)
    "install_lsp"             # Language Server Protocol (LSP) servers
    "install_hack_nerd_font"  # Hack Nerd Font (required by nvim-web-devicons)
    "install_lang_formatters" # Language formatters and linters
  )

  # Add extra version managers if INSTALL_EXTRA_VENV=1 is set
  if [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]]; then
    core_deps+=("install_jenv" "install_gvm" "install_nvm" "install_rbenv")
    info "Development environment installation enabled via INSTALL_EXTRA_VENV=1"
  fi

  # Always attempt to install AI code agents (best-effort, depends on npm >= 20)
  core_deps+=("install_ai_code_agents")

  # Install core dependencies
  for dep_func in "${core_deps[@]}"; do
    if declare -f "$dep_func" >/dev/null; then
      info "Installing dependency: ${dep_func#install_}"
      if ! "$dep_func"; then
        warn "Failed to install ${dep_func#install_}, continuing..."
      fi
    else
      warn "Dependency function not found: $dep_func"
    fi
  done

  # Configure Homebrew mirrors if Homebrew was successfully installed
  if command -v brew >/dev/null 2>&1; then
    configure_homebrew_mirrors
  fi

  printf "\n%bInstalled Tools:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  • Utility scripts: %b~/.dotfiles/bin%b (in PATH)\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  • Homebrew: Package manager\n"
  printf "  • pyenv: Python version manager\n"
  printf "  • fzf: Fuzzy finder\n"
  printf "  • universal-ctags: Code navigation tool\n"
  printf "  • LSP servers: Language Server Protocol support\n"
  printf "  • Language formatters: Code formatting tools\n"
  printf "  • cargo: Rust toolchain\n"
  printf "  • Hack Nerd Font: Icon font for development\n"

  [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]] && printf "  • jenv, gvm, nvm: Java/Go/Node version managers\n"
  printf "  • AI code agents\n"

  success "Essential development tools installation completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
