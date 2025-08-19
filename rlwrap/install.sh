#!/bin/bash
###################################################
# Rlwrap Configuration Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Command-line wrapper configuration
# - Lisp and SBCL completion files
# - XDG base directory compliance
# - Enhanced error handling and validation
#
# Author: Xiaming Chen
# License: MIT
###################################################

# Enable strict mode for better error handling
set -euo pipefail

# Resolve script directory
THISDIR=$(dirname "$(realpath "$0")")

# Configuration constants
readonly XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
readonly RLWRAP_HOME="$XDG_CONFIG_HOME/rlwrap"

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Check rlwrap availability
check_rlwrap_binary() {
  if ! checkcmd rlwrap; then
    warn "Rlwrap not found in PATH"
    warn "Please install rlwrap first:"

    if is_linux; then
      if checkcmd apt-get; then
        warn "  Ubuntu/Debian: sudo apt-get install rlwrap"
      elif checkcmd yum; then
        warn "  RHEL/CentOS: sudo yum install rlwrap"
      elif checkcmd dnf; then
        warn "  Fedora: sudo dnf install rlwrap"
      elif checkcmd pacman; then
        warn "  Arch: sudo pacman -S rlwrap"
      fi
    elif is_macos; then
      warn "  macOS: brew install rlwrap"
    fi

    warn "Configuration will be installed anyway for future use"
  else
    local rlwrap_version
    rlwrap_version=$(rlwrap --version 2>/dev/null | head -1 || echo "unknown")
    info "Found rlwrap: $rlwrap_version"
  fi
}

# Install rlwrap configuration files with validation
handle_rlwrap_config() {
  info "Installing rlwrap configuration..."
  create_dir "$RLWRAP_HOME"

  # Configuration files to install
  local config_files=(
    "lisp_completions"
    "sbcl_completions"
  )

  local installed_count=0
  local failed_count=0

  for config_file in "${config_files[@]}"; do
    local src_path="$THISDIR/$config_file"
    local dest_path="$RLWRAP_HOME/$config_file"

    if [[ -f "$src_path" ]]; then
      if install_file_pair "$src_path" "$dest_path"; then
        ((installed_count++))
      else
        ((failed_count++))
        warn "Failed to install: $config_file"
      fi
    else
      warn "Configuration file not found: $src_path"
      ((failed_count++))
    fi
  done

  if [[ $failed_count -eq 0 ]]; then
    success "All rlwrap configuration files installed ($installed_count items)"
  else
    warn "Installation completed with $failed_count failures"
  fi

  info "Configuration directory: $RLWRAP_HOME"

  # Provide usage examples
  if checkcmd rlwrap; then
    info "Usage examples:"
    printf "  SBCL with completion: %brlwrap -f %s sbcl%b\n" "$COLOR_CYAN" "$RLWRAP_HOME/sbcl_completions" "$COLOR_RESET"
    printf "  Generic Lisp: %brlwrap -f %s <lisp-command>%b\n" "$COLOR_CYAN" "$RLWRAP_HOME/lisp_completions" "$COLOR_RESET"
  fi
}

# Remove rlwrap configuration files
cleanse_rlwrap() {
  info "Cleansing rlwrap configuration..."

  local config_files=(
    "$RLWRAP_HOME/lisp_completions"
    "$RLWRAP_HOME/sbcl_completions"
  )

  local removed_count=0
  for config_file in "${config_files[@]}"; do
    if [[ -f "$config_file" ]]; then
      rm -f "$config_file"
      info "Removed: $(basename "$config_file")"
      ((removed_count++))
    fi
  done

  # Remove empty configuration directory
  [[ -d "$RLWRAP_HOME" ]] && rmdir "$RLWRAP_HOME" 2>/dev/null || true

  if [[ $removed_count -gt 0 ]]; then
    success "Rlwrap configuration cleansed ($removed_count items removed)"
  else
    info "No rlwrap configuration found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsch opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_rlwrap && exit 0 ;;
  h | ?) usage_me "install.sh" && exit 0 ;;
  esac
done

# Main installation sequence
main() {
  info "Starting rlwrap configuration installation..."

  # Check dependencies
  check_rlwrap_binary

  # Install configuration
  handle_rlwrap_config

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Configuration directory: $RLWRAP_HOME"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Use with SBCL: %brlwrap -f %s sbcl%b\n" "$COLOR_CYAN" "$RLWRAP_HOME/sbcl_completions" "$COLOR_RESET"
  printf "  2. Use with other Lisps: %brlwrap -f %s <command>%b\n" "$COLOR_CYAN" "$RLWRAP_HOME/lisp_completions" "$COLOR_RESET"
  printf "  3. Create aliases in your shell configuration for convenience\n"

  success "Rlwrap configuration installation completed successfully!"
}

# Execute main function
main
