#!/bin/bash
###################################################
# Emacs Configuration Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Modern Emacs configuration with XDG compliance
# - Lisp development environment integration
# - Plugin and package management
# - SLIME integration for Common Lisp
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
readonly EMACS_CONFIG_HOME="$XDG_CONFIG_HOME/emacs"
readonly QUICKLISP_HOME=${QUICKLISP_HOME:-"$HOME/quicklisp"}

# Configuration files to install
readonly INSTALL_FILES=(
  "lisp"
  "plugins"
  "init.el"
)

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Check Emacs availability and version
check_emacs_binary() {
  if ! checkcmd emacs; then
    warn "Emacs not found in PATH"
    warn "Please install Emacs first:"

    if is_linux; then
      if checkcmd apt-get; then
        warn "  Ubuntu/Debian: sudo apt-get install emacs"
      elif checkcmd yum; then
        warn "  RHEL/CentOS: sudo yum install emacs"
      elif checkcmd dnf; then
        warn "  Fedora: sudo dnf install emacs"
      elif checkcmd pacman; then
        warn "  Arch: sudo pacman -S emacs"
      fi
    elif is_macos; then
      warn "  macOS: brew install emacs"
    fi

    warn "Configuration will be installed anyway for future use"
  else
    local emacs_version
    emacs_version=$(emacs --version 2>/dev/null | head -1 || echo "unknown")
    info "Found Emacs: $emacs_version"
  fi
}

# Check SLIME dependencies for Common Lisp development
check_slime_dependencies() {
  info "Checking SLIME dependencies..."

  local slime_helper="$QUICKLISP_HOME/slime-helper.el"
  if [[ -f "$slime_helper" ]]; then
    success "SLIME helper found: $slime_helper"
  else
    warn "SLIME helper not found: $slime_helper"
    warn "To enable SLIME integration:"
    warn "  1. Install Quicklisp (run ../lisp/install.sh)"
    warn "  2. In SBCL, run: (ql:quickload 'quicklisp-slime-helper)"
  fi
}

# Check additional Emacs dependencies
check_additional_dependencies() {
  info "Checking additional dependencies..."

  local optional_deps=(
    "aspell:spell checking"
    "git:version control integration"
    "ripgrep:fast text search"
    "fd:file finding"
  )

  for dep_info in "${optional_deps[@]}"; do
    local dep_name="${dep_info%:*}"
    local dep_desc="${dep_info#*:}"

    if checkcmd "$dep_name"; then
      info "Found $dep_name ($dep_desc)"
    else
      warn "$dep_name not found ($dep_desc)"
    fi
  done
}

# Install Emacs configuration files with validation
handle_emacs_config() {
  info "Installing Emacs configuration..."
  create_dir "$EMACS_CONFIG_HOME"

  local installed_count=0
  local failed_count=0

  for config_item in "${INSTALL_FILES[@]}"; do
    local src_path="$THISDIR/$config_item"
    local dest_path="$EMACS_CONFIG_HOME/$config_item"

    if [[ -e "$src_path" ]]; then
      if install_file_pair "$src_path" "$dest_path"; then
        ((installed_count++))
      else
        ((failed_count++))
        warn "Failed to install: $config_item"
      fi
    else
      warn "Configuration item not found: $src_path"
      ((failed_count++))
    fi
  done

  if [[ $failed_count -eq 0 ]]; then
    success "All Emacs configuration files installed ($installed_count items)"
  else
    warn "Installation completed with $failed_count failures"
  fi

  info "Configuration directory: $EMACS_CONFIG_HOME"

  # Validate configuration syntax if Emacs is available
  if checkcmd emacs && [[ -f "$EMACS_CONFIG_HOME/init.el" ]]; then
    info "Validating Emacs configuration..."
    if emacs --batch --load "$EMACS_CONFIG_HOME/init.el" --eval '(message "Configuration valid")' >/dev/null 2>&1; then
      success "Configuration syntax validated"
    else
      warn "Configuration may have syntax errors"
    fi
  fi
}

# Remove Emacs configuration files
cleanse_emacs() {
  info "Cleansing Emacs configuration..."

  local removed_count=0
  for config_item in "${INSTALL_FILES[@]}"; do
    local target_path="$EMACS_CONFIG_HOME/$config_item"
    if [[ -e "$target_path" ]]; then
      rm -rf "$target_path"
      info "Removed: $config_item"
      ((removed_count++))
    fi
  done

  # Remove empty configuration directory
  [[ -d "$EMACS_CONFIG_HOME" ]] && rmdir "$EMACS_CONFIG_HOME" 2>/dev/null || true

  if [[ $removed_count -gt 0 ]]; then
    success "Emacs configuration cleansed ($removed_count items removed)"
  else
    info "No Emacs configuration found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_emacs && exit 0 ;;
  h | ?)
    usage_me "install.sh"
    exit 0
    ;;
  esac
done

# Main installation sequence
main() {
  info "Starting Emacs configuration installation..."

  # Check dependencies
  check_emacs_binary
  check_additional_dependencies
  check_slime_dependencies

  # Install configuration
  handle_emacs_config

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Configuration directory: $EMACS_CONFIG_HOME"
  info "SLIME helper: $QUICKLISP_HOME/slime-helper.el"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Launch Emacs: %bemacs%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Install packages: %bM-x package-install%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. For Lisp development: %bM-x slime%b (after Quicklisp setup)\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  4. Customize configuration in: %b%s%b\n" "$COLOR_CYAN" "$EMACS_CONFIG_HOME" "$COLOR_RESET"

  success "Emacs configuration installation completed successfully!"
}

# Execute main function
main
