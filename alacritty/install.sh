#!/bin/bash
###################################################
# Alacritty Terminal Emulator Configuration Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Alacritty configuration with themes
# - Theme repository management
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
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
readonly ALACRITTY_CONFIG_HOME="$XDG_CONFIG_HOME/alacritty"
readonly ALACRITTY_THEMES_DIR="$ALACRITTY_CONFIG_HOME/themes"
readonly ALACRITTY_CONFIG_FILE="$ALACRITTY_CONFIG_HOME/alacritty.toml"

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Check Alacritty availability
check_alacritty_binary() {
  if ! checkcmd alacritty; then
    warn "Alacritty not found in PATH"
    warn "Please install Alacritty first:"

    if is_linux; then
      warn "  Download from: https://github.com/alacritty/alacritty/releases"
      warn "  Or install via package manager (alacritty)"
    elif is_macos; then
      warn "  macOS: brew install --cask alacritty"
    fi

    warn "Configuration will be installed anyway for future use"
  else
    local alacritty_version
    alacritty_version=$(alacritty --version 2>/dev/null | head -1 || echo "unknown")
    info "Found Alacritty: $alacritty_version"
  fi
}

# Install Alacritty themes repository
install_alacritty_themes() {
  info "Installing Alacritty themes..."

  if [[ -d "$ALACRITTY_THEMES_DIR/.git" ]]; then
    info "Themes already installed, updating..."
    if git -C "$ALACRITTY_THEMES_DIR" pull --quiet; then
      success "Themes updated successfully"
    else
      warn "Failed to update themes, continuing with existing installation"
    fi
    return 0
  fi

  # Check git availability
  checkcmd git || {
    warn "Git not found, skipping theme installation"
    return 0
  }

  # Clone themes repository
  if git clone --depth 1 --quiet https://github.com/alacritty/alacritty-theme "$ALACRITTY_THEMES_DIR"; then
    success "Alacritty themes installed successfully"
    info "Themes location: $ALACRITTY_THEMES_DIR"

    # Count available themes
    local theme_count
    theme_count=$(find "$ALACRITTY_THEMES_DIR" -name "*.toml" | wc -l 2>/dev/null || echo "unknown")
    info "Available themes: $theme_count"
  else
    warn "Failed to install Alacritty themes"
  fi
}

# Install Alacritty configuration with validation
handle_alacritty_config() {
  info "Installing Alacritty configuration..."
  create_dir "$ALACRITTY_CONFIG_HOME"

  local config_source="$THISDIR/alacritty.toml"

  # Validate source configuration exists
  [[ -f "$config_source" ]] || {
    error "Alacritty configuration file not found: $config_source"
  }

  # Install themes first
  install_alacritty_themes

  # Install main configuration
  install_file_pair "$config_source" "$ALACRITTY_CONFIG_FILE"
  success "Alacritty configuration installed"

  # Validate configuration
  if checkcmd alacritty && alacritty --print-events --config-file "$ALACRITTY_CONFIG_FILE" >/dev/null 2>&1; then
    info "Configuration validated successfully"
  else
    warn "Configuration validation failed or Alacritty not available"
  fi
}

# Remove Alacritty configuration and themes
cleanse_alacritty() {
  info "Cleansing Alacritty configuration..."

  local items_to_remove=(
    "$ALACRITTY_CONFIG_FILE"
    "$ALACRITTY_THEMES_DIR"
  )

  local removed_count=0
  for item in "${items_to_remove[@]}"; do
    if [[ -e "$item" ]]; then
      rm -rf "$item"
      info "Removed: $(basename "$item")"
      ((removed_count++))
    fi
  done

  # Remove empty configuration directory
  [[ -d "$ALACRITTY_CONFIG_HOME" ]] && rmdir "$ALACRITTY_CONFIG_HOME" 2>/dev/null || true

  if [[ $removed_count -gt 0 ]]; then
    success "Alacritty configuration cleansed ($removed_count items removed)"
  else
    info "No Alacritty configuration found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_alacritty && exit 0 ;;
  h | ?)
    usage_me "install.sh"
    exit 0
    ;;
  esac
done

# Main installation sequence
main() {
  info "Starting Alacritty configuration installation..."

  # Check dependencies
  check_alacritty_binary

  # Install configuration
  handle_alacritty_config

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Configuration file: $ALACRITTY_CONFIG_FILE"
  info "Themes directory: $ALACRITTY_THEMES_DIR"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Launch Alacritty to test the configuration\n"
  printf "  2. Browse themes in: %b%s%b\n" "$COLOR_CYAN" "$ALACRITTY_THEMES_DIR" "$COLOR_RESET"
  printf "  3. Edit configuration: %b%s%b\n" "$COLOR_CYAN" "$ALACRITTY_CONFIG_FILE" "$COLOR_RESET"
  printf "  4. Reload config: Ctrl+Shift+R (or restart Alacritty)\n"

  success "Alacritty configuration installation completed successfully!"
}

# Execute main function
main
