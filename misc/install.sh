#!/bin/bash
###################################################
# Miscellaneous Tools and Configurations Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Local utility scripts installation
# - SBCL completion configuration
# - Kitty terminal configuration
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
readonly LOCAL_BIN_DIR="$HOME/.local/bin"
readonly KITTY_CONFIG_HOME="$XDG_CONFIG_HOME/kitty"
readonly SBCL_COMPLETIONS="$HOME/.sbcl_completions"

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
      ((installed_count++))
    else
      warn "Failed to install script: $script_name"
      ((failed_count++))
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

# Configure SBCL auto-completion with rlwrap
handle_rlwrap_completions() {
  local completions_source="$THISDIR/../rlwrap/sbcl_completions"

  [[ -f "$completions_source" ]] || {
    warn "SBCL completions file not found: $completions_source"
    return 0
  }

  info "Installing SBCL auto-completion..."

  # Check if file exists and is not a symlink
  if [[ -f "$SBCL_COMPLETIONS" && ! -L "$SBCL_COMPLETIONS" ]]; then
    warn "SBCL completions already exist: $SBCL_COMPLETIONS"
    warn "Skipping to preserve existing configuration"
    return 0
  fi

  # Install completions file
  install_file_pair "$completions_source" "$SBCL_COMPLETIONS"
  success "SBCL auto-completion configured"

  # Check if rlwrap is available
  if ! checkcmd rlwrap; then
    warn "rlwrap not found in PATH"
    warn "Install rlwrap to enable SBCL auto-completion"
  fi
}

# Install Kitty terminal configuration
handle_kitty_config() {
  local kitty_source="$THISDIR/../kitty/kitty.conf"
  local kitty_dest="$KITTY_CONFIG_HOME/kitty.conf"

  [[ -f "$kitty_source" ]] || {
    warn "Kitty configuration file not found: $kitty_source"
    return 0
  }

  info "Installing Kitty terminal configuration..."
  create_dir "$KITTY_CONFIG_HOME"

  # Install configuration file
  install_file_pair "$kitty_source" "$kitty_dest"
  success "Kitty configuration installed"

  # Check if Kitty is available
  if ! checkcmd kitty; then
    warn "Kitty terminal not found in PATH"
    warn "Install Kitty to use this configuration:"

    if is_linux; then
      warn "  Download from: https://sw.kovidgoyal.net/kitty/binary/"
    elif is_macos; then
      warn "  macOS: brew install --cask kitty"
    fi
  else
    local kitty_version
    kitty_version=$(kitty --version 2>/dev/null | head -1 || echo "unknown")
    info "Found Kitty: $kitty_version"
  fi
}

# Remove Kitty configuration
cleanse_kitty() {
  local kitty_config="$KITTY_CONFIG_HOME/kitty.conf"

  if [[ -f "$kitty_config" ]]; then
    rm -f "$kitty_config"
    info "Removed Kitty configuration"

    # Remove empty directory
    [[ -d "$KITTY_CONFIG_HOME" ]] && rmdir "$KITTY_CONFIG_HOME" 2>/dev/null || true
  else
    info "No Kitty configuration found to remove"
  fi
}

# Remove all miscellaneous configurations
cleanse_all() {
  info "Cleansing miscellaneous configurations..."

  local removed_count=0

  # Remove utility scripts
  local bin_source_dir="$THISDIR/../bin"
  if [[ -d "$bin_source_dir" ]]; then
    while IFS= read -r -d '' script_file; do
      local script_name
      script_name=$(basename "$script_file")
      local installed_script="$LOCAL_BIN_DIR/$script_name"

      if [[ -f "$installed_script" ]]; then
        rm -f "$installed_script"
        info "Removed script: $script_name"
        ((removed_count++))
      fi
    done < <(find "$bin_source_dir" -type f -executable -print0 2>/dev/null || true)
  fi

  # Remove SBCL completions
  if [[ -f "$SBCL_COMPLETIONS" ]]; then
    rm -f "$SBCL_COMPLETIONS"
    info "Removed SBCL completions"
    ((removed_count++))
  fi

  # Remove Kitty configuration
  cleanse_kitty
  [[ -f "$KITTY_CONFIG_HOME/kitty.conf" ]] || ((removed_count++))

  # Remove empty directories
  [[ -d "$LOCAL_BIN_DIR" ]] && rmdir "$LOCAL_BIN_DIR" 2>/dev/null || true

  if [[ $removed_count -gt 0 ]]; then
    success "Miscellaneous configurations cleansed ($removed_count items removed)"
  else
    info "No miscellaneous configurations found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_all && exit 0 ;;
  h | ?) usage_me "install.sh" && exit 0 ;;
  esac
done

# Main installation sequence
main() {
  info "Starting miscellaneous tools installation..."

  # Installation steps
  install_local_bins
  handle_rlwrap_completions
  handle_kitty_config

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Utility scripts: $LOCAL_BIN_DIR"
  info "SBCL completions: $SBCL_COMPLETIONS"
  info "Kitty configuration: $KITTY_CONFIG_HOME"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Add %b$LOCAL_BIN_DIR%b to your PATH if not already added\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Use rlwrap with SBCL: %brlwrap sbcl%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. Launch Kitty to use the new configuration\n"

  success "Miscellaneous tools installation completed successfully!"
}

# Execute main function
main
