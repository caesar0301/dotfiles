#!/bin/bash
###################################################
# Essential Development Tools Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Local utility scripts (dotme-xxx series)
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

# Configuration constants
readonly LOCAL_BIN_DIR="$HOME/.local/bin"

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Install local utility scripts with validation
install_local_bins() {
  local bin_source_dir="$THISDIR/../bin"

  [[ -d "$bin_source_dir" ]] || {
    warn "Binary source directory not found: $bin_source_dir"
    return 0
  }

  info "Installing local utility scripts..."
  create_dir "$LOCAL_BIN_DIR"

  local installed_count=0
  local failed_count=0

  # Install each script individually with validation
  while IFS= read -r -d '' script_file; do
    local script_name
    script_name=$(basename "$script_file")
    local dest_path="$LOCAL_BIN_DIR/$script_name"

    if cp "$script_file" "$dest_path" && chmod +x "$dest_path"; then
      info "Installed script: $script_name"
      ((++installed_count))
    else
      warn "Failed to install script: $script_name"
      ((++failed_count))
    fi
  done < <(find "$bin_source_dir" -type f -executable -print0 2>/dev/null || true)

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

  # Install local utility scripts first
  install_local_bins

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

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"

  printf "\n%bInstalled Tools:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  • Local utility scripts: %b$LOCAL_BIN_DIR%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  • pyenv: Python version manager\n"
  [[ "$homebrew_installed" == "true" ]] && printf "  • Homebrew: Package manager\n"
  [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]] && printf "  • jenv, gvm, nvm: Java/Go/Node version managers\n"
  [[ "${INSTALL_AI_CODE_AGENTS:-0}" == "1" ]] && printf "  • AI code agents\n"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Add %b$LOCAL_BIN_DIR%b to your PATH if not already added\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Restart your shell or run: %bexec \$SHELL%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. Version managers will be available after shell reload\n"

  success "Essential development tools installation completed successfully!"
}

# Execute main function
main
