#!/bin/bash
###################################################
# Basic Installation Script
# https://github.com/caesar0301/cool-dotfiles
#
# Installs essential dotfile components for a minimal
# but functional development environment.
#
# Usage: ./install_basics.sh [options]
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
source "$THISDIR/lib/shlib.sh" || {
  printf "\033[0;31m✗ Failed to load shlib.sh\033[0m\n" >&2
  exit 1
}

# Basic component installation order (dependencies first)
readonly COMPONENTS=(
  "zsh"    # Z shell configuration
  "tmux"   # Terminal multiplexer
  "zellij" # Terminal workspace
  "nvim"   # Neovim development environment
)

# Track installation statistics
INSTALL_SUCCESS=0
INSTALL_FAILED=0
INSTALL_SKIPPED=0

# Resolve a portable timeout command: gtimeout on macOS, timeout on Linux.
# Prints nothing when neither is available.
get_timeout_cmd() {
  if [[ "$OSTYPE" == "darwin"* ]] && command -v gtimeout >/dev/null 2>&1; then
    printf "gtimeout"
  elif command -v timeout >/dev/null 2>&1; then
    printf "timeout"
  fi
}

# Install essential development tools as a prerequisite
# For basic installation, use default settings (no optional features)
install_essentials_prerequisite() {
  local essentials_script="$THISDIR/lib/install-essentials.sh"

  [[ -f "$essentials_script" ]] || {
    warn "Essentials installer not found: $essentials_script"
    return 1
  }

  info "Installing essential development tools (prerequisite)..."

  # Execute essentials installation under a timeout so a hanging tool
  # (e.g. an interactive installer prompt) cannot stall the whole run.
  local timeout_cmd
  timeout_cmd=$(get_timeout_cmd)
  local essentials_rc=0
  if [[ -n "$timeout_cmd" ]]; then
    $timeout_cmd 900 bash "$essentials_script" "$@" 2>&1 || essentials_rc=$?
  else
    bash "$essentials_script" "$@" 2>&1 || essentials_rc=$?
  fi

  if [[ $essentials_rc -eq 0 ]]; then
    success "Essential development tools installed successfully"
  else
    warn "Some essential tools failed to install (exit code: $essentials_rc), continuing..."
  fi

  # Re-source PATH for tools installed by the essentials subprocess.
  # The subprocess runs in a separate shell, so PATH changes are lost.
  # We re-detect installed tools here so component installers find them.

  # Homebrew
  if [[ -x "$HOME/.local/homebrew/bin/brew" ]]; then
    eval "$("$HOME/.local/homebrew/bin/brew" shellenv)" 2>/dev/null || true
  elif [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
  fi

  # pyenv
  if [[ -d "${PYENV_ROOT:-$HOME/.pyenv}" ]]; then
    export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - --no-rehash 2>/dev/null)" || true
  fi

  # cargo
  if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
  fi

  # X11 tools (fontconfig for font installation)
  if [[ -d "/opt/X11/bin" ]] && [[ ":$PATH:" != *":/opt/X11/bin:"* ]]; then
    export PATH="/opt/X11/bin:$PATH"
  fi
}

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

  local timeout_cmd
  timeout_cmd=$(get_timeout_cmd)

  # Capture the real exit code: reading $? after an `if` would yield the
  # status of the condition, not of the installer.
  local install_rc=0
  if [[ -n "$timeout_cmd" ]]; then
    $timeout_cmd 300 bash "$component_script" "$@" 2>&1 || install_rc=$?
  else
    # Fallback without timeout if command not available
    bash "$component_script" "$@" 2>&1 || install_rc=$?
  fi

  if [[ $install_rc -eq 0 ]]; then
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    success "Component '$component' installed successfully (${duration}s)"
    ((INSTALL_SUCCESS++))
  else
    if [[ $install_rc -eq 124 ]]; then
      error "Component '$component' installation timed out (5 minutes)"
    else
      error "Component '$component' installation failed (exit code: $install_rc)"
    fi
    ((INSTALL_FAILED++))
    return $install_rc
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
    success "🎉 Basic components installed successfully!"
  else
    warn "⚠️  Some components failed to install. Check the logs above."
    return 1
  fi
}

# Main installation process
main() {
  info "Starting basic dotfiles installation..."
  info "Components to install: ${#COMPONENTS[@]}"

  # Install essential development tools as a prerequisite (with default settings)
  install_essentials_prerequisite "$@" || {
    warn "Essential development tools installation failed, continuing with components..."
  }

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
