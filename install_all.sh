#!/bin/bash
###################################################
# Master Installation Script
# https://github.com/caesar0301/cool-dotfiles
#
# Orchestrates installation of all dotfile components
# with enhanced error handling and progress tracking.
#
# Usage: ./install_all.sh [options]
# Options: -f (force), -s (symlink), -c (clean)
#
# Author: Xiaming Chen
# License: MIT
###################################################

# Enable strict mode for better error handling
set -euo pipefail

# Resolve script directory with enhanced error checking
THISDIR=$(dirname "$(realpath "$0")")

# Load common utilities with validation
source "$THISDIR/lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Component installation order (dependencies first)
readonly COMPONENTS=(
  "zsh"       # Z shell configuration
  "tmux"      # Terminal multiplexer
  "nvim"      # Neovim development environment
  "vifm"      # Vi file manager
  "emacs"     # Emacs configuration
  "misc"      # Utility scripts and configurations
  # "lisp"      # Common Lisp development environment
  # "alacritty" # Terminal emulator
)

# Track installation statistics
INSTALL_SUCCESS=0
INSTALL_FAILED=0
INSTALL_SKIPPED=0

# Enhanced component installation with progress tracking
install_component() {
  local component=$1
  local component_script="$THISDIR/$component/install.sh"

  # Validate component script exists
  [[ -f "$component_script" ]] || {
    warn "Component script not found: $component_script"
    ((INSTALL_SKIPPED++))
    return 0
  }

  info "Installing component: $component"

  # Execute component installation with timeout and error handling
  local start_time=$(date +%s)

  # Use gtimeout on macOS, timeout on Linux
  local timeout_cmd="timeout"
  if [[ "$OSTYPE" == "darwin"* ]] && command -v gtimeout >/dev/null 2>&1; then
    timeout_cmd="gtimeout"
  fi

  if $timeout_cmd 300 bash "$component_script" "$@" 2>&1; then
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    success "Component '$component' installed successfully (${duration}s)"
    ((INSTALL_SUCCESS++))
  else
    local exit_code=$?
    if [[ $exit_code -eq 124 ]]; then
      error "Component '$component' installation timed out (5 minutes)"
    else
      error "Component '$component' installation failed (exit code: $exit_code)"
    fi
    ((INSTALL_FAILED++))
    return $exit_code
  fi
}

# Display installation summary
show_installation_summary() {
  local total=$((INSTALL_SUCCESS + INSTALL_FAILED + INSTALL_SKIPPED))

  printf "\n%b=== Installation Summary ===%b\n" "$COLOR_BOLD$COLOR_CYAN" "$COLOR_RESET"
  printf "  %b✓%b Successful: %d/%d\n" "$COLOR_GREEN" "$COLOR_RESET" "$INSTALL_SUCCESS" "$total"

  if [[ $INSTALL_FAILED -gt 0 ]]; then
    printf "  %b✗%b Failed: %d/%d\n" "$COLOR_RED" "$COLOR_RESET" "$INSTALL_FAILED" "$total"
  fi

  if [[ $INSTALL_SKIPPED -gt 0 ]]; then
    printf "  %b⚠%b Skipped: %d/%d\n" "$COLOR_YELLOW" "$COLOR_RESET" "$INSTALL_SKIPPED" "$total"
  fi

  printf "\n"

  if [[ $INSTALL_FAILED -eq 0 ]]; then
    success "🎉 All components installed successfully!"
  else
    warn "⚠️  Some components failed to install. Check the logs above."
    return 1
  fi
}

# Main installation process
main() {
  info "Starting dotfiles installation..."
  info "Components to install: ${#COMPONENTS[@]}"

  # Install each component
  for component in "${COMPONENTS[@]}"; do
    install_component "$component" "$@" || {
      warn "Continuing with remaining components..."
    }
  done

  # Show final summary
  show_installation_summary
}

# Execute main function with all arguments
main "$@"
