#!/bin/bash
###################################################
# Essential Development Tools Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Python version management (pyenv)
# - Homebrew package manager (optional)
# - Development environment version managers
# - AI code agents support
# - Enhanced error handling and user feedback
#
# Environment Variables:
# - INSTALL_HOMEBREW=1: Install Homebrew package manager
# - INSTALL_EXTRA_VENV=1: Install jenv, gvm, nvm version managers
# - INSTALL_AI_CODE_AGENTS=1: Install AI code agents
#
# Author: Xiaming Chen
# License: MIT
###################################################

# Enable strict mode for better error handling
set -euo pipefail

# Resolve script directory
THISDIR=$(dirname "$(realpath "$0")")

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Process command line options
while getopts h opt; do
  case $opt in
  h | ?)
    usage_me "install.sh"
    exit 0
    ;;
  esac
done

# Main installation sequence
main() {
  info "Starting essential development tools installation..."

  # Core dependencies
  local core_deps=(
    "install_pyenv" # Python version manager
  )

  # Add homebrew if INSTALL_HOMEBREW=1 is set
  if [[ "${INSTALL_HOMEBREW:-0}" == "1" ]]; then
    core_deps+=("install_homebrew")
    info "Homebrew installation enabled via INSTALL_HOMEBREW=1"
  fi

  # Add extra version managers if INSTALL_EXTRA_VENV=1 is set
  if [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]]; then
    core_deps+=("install_jenv" "install_gvm" "install_nvm")
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

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"

  printf "\n%bInstalled Tools:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  • pyenv: Python version manager\n"
  [[ "$homebrew_installed" == "true" ]] && printf "  • Homebrew: Package manager\n"
  [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]] && printf "  • jenv, gvm, nvm: Java/Go/Node version managers\n"
  [[ "${INSTALL_AI_CODE_AGENTS:-0}" == "1" ]] && printf "  • AI code agents\n"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Restart your shell or run: %bexec \$SHELL%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Version managers will be available after shell reload\n"

  success "Essential development tools installation completed successfully!"
}

# Execute main function
main
