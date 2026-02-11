#!/bin/bash
###################################################
# Essential Development Tools Installer
# https://github.com/caesar0301/cool-dotfiles
#
# Installs essential development tools and utilities for a productive development environment.
#
# Features:
# - Local utility scripts (dotme-xxx series)
# - Python version management (pyenv)
# - Homebrew package manager (optional)
# - Development environment version managers
# - AI code agents support
# - Enhanced error handling and user feedback
#
# Usage:
#   Basic installation (utility scripts + pyenv):
#     ./lib/install-essentials.sh
#
#   With optional components:
#     INSTALL_HOMEBREW=1 ./lib/install-essentials.sh
#     INSTALL_EXTRA_VENV=1 ./lib/install-essentials.sh
#     INSTALL_AI_CODE_AGENTS=1 ./lib/install-essentials.sh
#
#     Full installation:
#     INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 INSTALL_AI_CODE_AGENTS=1 ./lib/install-essentials.sh
#
# Environment Variables:
#   INSTALL_HOMEBREW=1      Install Homebrew package manager
#   INSTALL_EXTRA_VENV=1    Install jenv, gvm, nvm version managers
#   INSTALL_AI_CODE_AGENTS=1 Install AI code agents (requires Node.js >= 20)
#
# What Gets Installed:
#   - Local utility scripts: dotme-xxx series tools in ~/.local/bin
#   - pyenv: Python version manager (always installed)
#   - fzf: Fuzzy finder (always installed)
#   - universal-ctags: Code navigation tool (always installed)
#   - cargo: Rust toolchain (always installed)
#   - Homebrew: Package manager (if INSTALL_HOMEBREW=1)
#   - jenv, gvm, nvm: Java/Go/Node version managers (if INSTALL_EXTRA_VENV=1)
#   - AI code agents: AI-powered development tools (if INSTALL_AI_CODE_AGENTS=1)
#
# Post-Installation:
#   After installation, ensure ~/.local/bin is in your PATH:
#     export PATH="$HOME/.local/bin:$PATH"
#   Then restart your shell or run: exec $SHELL
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Configuration constants
readonly LOCAL_BIN_DIR="$HOME/.local/bin"

# Install local utility scripts with validation
install_local_bins() {
  local bin_source_dir="$SCRIPT_DIR/../bin"

  [[ -d "$bin_source_dir" ]] || {
    warn "Binary source directory not found: $bin_source_dir"
    return 0
  }

  info "Installing local utility scripts..."
  create_dir "$LOCAL_BIN_DIR"

  local installed_count=0
  local failed_count=0

  # Install each script individually with validation
  # Find all files except README.md and make them executable
  while IFS= read -r -d '' script_file; do
    local script_name
    script_name=$(basename "$script_file")

    # Skip README.md and other non-script files
    [[ "$script_name" == "README.md" ]] && continue

    local dest_path="$LOCAL_BIN_DIR/$script_name"

    if cp "$script_file" "$dest_path" && chmod +x "$dest_path"; then
      info "Installed script: $script_name"
      ((++installed_count))
    else
      warn "Failed to install script: $script_name"
      ((++failed_count))
    fi
  done < <(find "$bin_source_dir" -type f -print0 2>/dev/null || true)

  if [[ $installed_count -gt 0 ]]; then
    success "Installed $installed_count utility scripts"
    info "Scripts location: $LOCAL_BIN_DIR"
  else
    warn "No utility scripts found to install"
  fi

  [[ $failed_count -eq 0 ]] || warn "$failed_count scripts failed to install"
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

  # Install local utility scripts first
  install_local_bins

  # Core dependencies - order matters! Homebrew must be installed before tools that depend on it
  local core_deps=(
    "install_pyenv"           # Python version manager
    "install_fzf"             # Fuzzy finder
  )

  # Add homebrew EARLY if INSTALL_HOMEBREW=1 is set (before tools that depend on it)
  if [[ "${INSTALL_HOMEBREW:-0}" == "1" ]]; then
    core_deps+=("install_homebrew")
    info "Homebrew installation enabled via INSTALL_HOMEBREW=1"
  fi

  # Add tools that may depend on Homebrew
  core_deps+=(
    "install_universal_ctags" # Universal ctags (required by Tagbar, may use Homebrew)
    "install_cargo"           # Rust and Cargo (conditionally based on kernel version)
  )

  # Add extra version managers if INSTALL_EXTRA_VENV=1 is set
  if [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]]; then
    core_deps+=("install_jenv" "install_gvm" "install_nvm" "install_rbenv")
    info "Development environment installation enabled via INSTALL_EXTRA_VENV=1"
  fi

  # Install AI code agents if INSTALL_AI_CODE_AGENTS=1 is set
  if [[ "${INSTALL_AI_CODE_AGENTS:-0}" == "1" ]]; then
    core_deps+=("install_ai_code_agents")
    info "AI code agents installation enabled via INSTALL_AI_CODE_AGENTS=1"
  fi

  # Install core dependencies
  local homebrew_installed=false
  for dep_func in "${core_deps[@]}"; do
    if [[ "$dep_func" == "install_homebrew" ]]; then
      homebrew_installed=true
    fi

    if declare -f "$dep_func" >/dev/null; then
      info "Installing dependency: ${dep_func#install_}"
      if ! "$dep_func"; then
        warn "Failed to install ${dep_func#install_}, continuing..."
      fi
    else
      warn "Dependency function not found: $dep_func"
    fi
  done

  # Configure Homebrew mirrors if Homebrew was installed
  if [[ "$homebrew_installed" == "true" ]] && command -v brew >/dev/null 2>&1; then
    configure_homebrew_mirrors
  fi

  printf "\n%bInstalled Tools:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  • Local utility scripts: %b$LOCAL_BIN_DIR%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  • pyenv: Python version manager\n"
  printf "  • fzf: Fuzzy finder\n"
  printf "  • universal-ctags: Code navigation tool\n"
  printf "  • cargo: Rust toolchain\n"
  [[ "$homebrew_installed" == "true" ]] && printf "  • Homebrew: Package manager\n"
  [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]] && printf "  • jenv, gvm, nvm: Java/Go/Node version managers\n"
  [[ "${INSTALL_AI_CODE_AGENTS:-0}" == "1" ]] && printf "  • AI code agents\n"

  success "Essential development tools installation completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
