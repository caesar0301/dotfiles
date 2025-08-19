#!/bin/bash
###################################################
# Vifm File Manager Configuration Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Vifm configuration files
# - Custom scripts and color schemes
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
readonly VIFM_CONFIG_HOME="$XDG_CONFIG_HOME/vifm"

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Configuration files to install
readonly INSTALL_FILES=(
  "vifmrc"
  "scripts"
  "colors"
)

# Check Vifm binary availability
check_vifm_binary() {
  if ! checkcmd vifm; then
    warn "Vifm binary not found in PATH"
    warn "Please install vifm first:"

    if is_linux; then
      if checkcmd apt-get; then
        warn "  Ubuntu/Debian: sudo apt-get install vifm"
      elif checkcmd yum; then
        warn "  RHEL/CentOS: sudo yum install vifm"
      elif checkcmd dnf; then
        warn "  Fedora: sudo dnf install vifm"
      elif checkcmd pacman; then
        warn "  Arch: sudo pacman -S vifm"
      fi
    elif is_macos; then
      warn "  macOS: brew install vifm"
    fi

    warn "Skipping vifm configuration installation"
    exit 0
  fi

  local vifm_version
  vifm_version=$(vifm --version 2>/dev/null | head -1 || echo "unknown")
  info "Found vifm: $vifm_version"
}

# Install Vifm configuration files with validation
handle_vifm_config() {
  info "Installing Vifm configuration..."
  create_dir "$VIFM_CONFIG_HOME"

  local installed_count=0
  local failed_count=0

  for config_item in "${INSTALL_FILES[@]}"; do
    local src_path="$THISDIR/$config_item"
    local dest_path="$VIFM_CONFIG_HOME/$config_item"

    if [[ -e "$src_path" ]]; then
      if install_file_pair "$src_path" "$dest_path"; then
        ((installed_count++))
      else
        ((failed_count++))
        warn "Failed to install: $config_item"
      fi
    else
      warn "Source not found: $src_path"
      ((failed_count++))
    fi
  done

  if [[ $failed_count -eq 0 ]]; then
    success "All Vifm configuration files installed ($installed_count items)"
  else
    warn "Installation completed with $failed_count failures"
  fi

  info "Configuration directory: $VIFM_CONFIG_HOME"
}

# Remove Vifm configuration files
cleanse_vifm() {
  info "Cleansing Vifm configuration..."

  local removed_count=0
  for config_item in "${INSTALL_FILES[@]}"; do
    local target_path="$VIFM_CONFIG_HOME/$config_item"
    if [[ -e "$target_path" ]]; then
      rm -rf "$target_path"
      info "Removed: $config_item"
      ((removed_count++))
    fi
  done

  # Remove empty configuration directory
  [[ -d "$VIFM_CONFIG_HOME" ]] && rmdir "$VIFM_CONFIG_HOME" 2>/dev/null || true

  if [[ $removed_count -gt 0 ]]; then
    success "Vifm configuration cleansed ($removed_count items removed)"
  else
    info "No Vifm configuration found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsch opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_vifm && exit 0 ;;
  h | ?) usage_me "install.sh" && exit 0 ;;
  esac
done

# Main installation sequence
main() {
  info "Starting Vifm configuration installation..."

  # Check dependencies
  check_vifm_binary

  # Install configuration
  handle_vifm_config

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Configuration directory: $VIFM_CONFIG_HOME"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Launch vifm: %bvifm%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Press %b?%b for help\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. Customize colors and scripts in: %b$VIFM_CONFIG_HOME%b\n" "$COLOR_CYAN" "$COLOR_RESET"

  success "Vifm configuration installation completed successfully!"
}

# Execute main function
main
