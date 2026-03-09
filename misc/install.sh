#!/bin/bash
###################################################
# Miscellaneous Tools and Configurations Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - SBCL completion configuration
# - Kitty terminal configuration
# - Alacritty terminal configuration + themes
# - Module-aware installation via -m
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
readonly KITTY_CONFIG_HOME="$XDG_CONFIG_HOME/kitty"
readonly ALACRITTY_CONFIG_HOME="$XDG_CONFIG_HOME/alacritty"
readonly ALACRITTY_THEMES_DIR="$ALACRITTY_CONFIG_HOME/themes"
readonly ALACRITTY_CONFIG_FILE="$ALACRITTY_CONFIG_HOME/alacritty.toml"
readonly SBCL_COMPLETIONS="$HOME/.sbcl_completions"

# Load common utilities with validation
source "$THISDIR/../lib/shlib.sh" || {
  printf "\033[0;31m✗ Failed to load shlib.sh\033[0m\n" >&2
  exit 1
}

# Configure SBCL auto-completion with rlwrap
handle_rlwrap_completions() {
  local completions_source="$THISDIR/../lisp/sbcl_completions"

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
  local kitty_source="$THISDIR/kitty.conf"
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

# Check Alacritty availability
check_alacritty_binary() {
  if ! checkcmd alacritty; then
    warn "Alacritty not found in PATH"
    warn "Configuration will still be installed for future use"
    return 0
  fi

  local alacritty_version
  alacritty_version=$(alacritty --version 2>/dev/null | head -1 || echo "unknown")
  info "Found Alacritty: $alacritty_version"
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

  checkcmd git || {
    warn "Git not found, skipping theme installation"
    return 0
  }

  if git clone --depth 1 --quiet https://github.com/alacritty/alacritty-theme "$ALACRITTY_THEMES_DIR"; then
    success "Alacritty themes installed successfully"
  else
    warn "Failed to install Alacritty themes"
  fi
}

# Install Alacritty configuration
handle_alacritty_config() {
  local config_source="$THISDIR/alacritty.toml"

  [[ -f "$config_source" ]] || {
    warn "Alacritty configuration file not found: $config_source"
    return 0
  }

  info "Installing Alacritty configuration..."
  create_dir "$ALACRITTY_CONFIG_HOME"

  check_alacritty_binary
  install_alacritty_themes
  install_file_pair "$config_source" "$ALACRITTY_CONFIG_FILE"
  success "Alacritty configuration installed"
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

cleanse_alacritty() {
  if [[ -f "$ALACRITTY_CONFIG_FILE" || -L "$ALACRITTY_CONFIG_FILE" ]]; then
    rm -f "$ALACRITTY_CONFIG_FILE"
    info "Removed Alacritty configuration"
  fi

  if [[ -d "$ALACRITTY_THEMES_DIR" ]]; then
    rm -rf "$ALACRITTY_THEMES_DIR"
    info "Removed Alacritty themes"
  fi

  [[ -d "$ALACRITTY_CONFIG_HOME" ]] && rmdir "$ALACRITTY_CONFIG_HOME" 2>/dev/null || true
  return 0
}

is_module_enabled() {
  local module="$1"

  if [[ ${#SELECTED_MODULES[@]} -eq 0 ]]; then
    return 0
  fi

  local selected
  for selected in "${SELECTED_MODULES[@]}"; do
    if [[ "$selected" == "$module" ]]; then
      return 0
    fi
  done

  return 1
}

validate_modules() {
  local module
  for module in "${SELECTED_MODULES[@]}"; do
    case "$module" in
    sbcl | kitty | alacritty) ;;
    *)
      error "Unsupported module: $module (supported: sbcl, kitty, alacritty)"
      ;;
    esac
  done
}

# Remove all miscellaneous configurations
cleanse_all() {
  info "Cleansing miscellaneous configurations..."

  local removed_count=0

  # Remove SBCL completions
  if [[ -f "$SBCL_COMPLETIONS" ]]; then
    rm -f "$SBCL_COMPLETIONS"
    info "Removed SBCL completions"
    ((removed_count++))
  fi

  # Remove Kitty configuration
  cleanse_kitty && true
  [[ -f "$KITTY_CONFIG_HOME/kitty.conf" ]] || ((removed_count++))

  # Remove Alacritty configuration
  cleanse_alacritty && true
  [[ -f "$ALACRITTY_CONFIG_FILE" && -d "$ALACRITTY_THEMES_DIR" ]] || ((removed_count++))

  if [[ $removed_count -gt 0 ]]; then
    success "Miscellaneous configurations cleansed ($removed_count items removed)"
  else
    info "No miscellaneous configurations found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
SELECTED_MODULES=()
while getopts fsechm: opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_all && exit 0 ;;
  m)
    IFS=',' read -r -a SELECTED_MODULES <<<"$OPTARG"
    ;;
  h | ?)
    cat <<'EOF'
Usage: install.sh [-s|-f] [-c] [-m modules]

Modules (comma-separated for -m):
  sbcl,kitty,alacritty

Examples:
  ./install.sh -m kitty
  ./install.sh -m kitty,alacritty
EOF
    exit 0
    ;;
  esac
done

validate_modules

# Main installation sequence
main() {
  info "Starting miscellaneous tools installation..."
  if [[ ${#SELECTED_MODULES[@]} -gt 0 ]]; then
    info "Selected modules: ${SELECTED_MODULES[*]}"
  else
    info "Selected modules: all"
  fi

  # Installation steps
  is_module_enabled sbcl && handle_rlwrap_completions
  is_module_enabled kitty && handle_kitty_config
  is_module_enabled alacritty && handle_alacritty_config

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "SBCL completions: $SBCL_COMPLETIONS"
  info "Kitty configuration: $KITTY_CONFIG_HOME"
  info "Alacritty configuration: $ALACRITTY_CONFIG_HOME"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Use rlwrap with SBCL: %brlwrap sbcl%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Launch Kitty to use the new configuration\n"

  success "Miscellaneous tools installation completed successfully!"
}

# Execute main function
main
