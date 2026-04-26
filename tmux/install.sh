#!/bin/bash
###################################################
# Tmux Terminal Multiplexer Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Tmux binary installation (brew preferred, source fallback)
# - TPM (Tmux Plugin Manager) setup
# - Modern configuration with XDG compliance
# - Enhanced error handling and user feedback
#
# Author: Xiaming Chen
# License: MIT
###################################################

# Enable strict mode for better error handling
set -euo pipefail

# Resolve script directory
THISDIR=$(dirname "$(realpath "$0")")

# Configuration constants
readonly TMUX_VERSION="3.6"
readonly XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
readonly TMUX_CONFIG_HOME="$XDG_CONFIG_HOME/tmux"
readonly TPM_HOME="$TMUX_CONFIG_HOME/plugins/tpm"

# Load common utilities with validation
source "$THISDIR/../lib/shlib.sh" || {
  printf "\033[0;31m✗ Failed to load shlib.sh\033[0m\n" >&2
  exit 1
}

# Install tmux via Homebrew, falling back to source build
install_tmux() {
  if checkcmd tmux; then
    local current_version
    current_version=$(tmux -V 2>/dev/null | grep -o '[0-9.]\+' | head -1 || echo "unknown")
    info "Tmux already installed (version: $current_version)"
    return 0
  fi

  info "Installing tmux $TMUX_VERSION..."

  if checkcmd brew; then
    info "Installing tmux via Homebrew..."
    if brew install tmux; then
      export PATH="$(brew --prefix)/bin:$PATH"
      success "Tmux installed via Homebrew"
      info "Tmux version: $(tmux -V)"
      return 0
    else
      warn "Homebrew tmux installation failed, falling back to source build"
    fi
  else
    info "Homebrew not found, building tmux from source"
  fi

  # Fall back to source build
  local script_dir="$THISDIR/../lib"
  if [[ -f "$script_dir/install-tmux.sh" ]]; then
    "$script_dir/install-tmux.sh"
  else
    error "Cannot install tmux: Homebrew not available and source installer not found"
  fi
}

# Install TPM (Tmux Plugin Manager) with validation
install_tpm() {
  info "Installing TPM (Tmux Plugin Manager)..."

  if [[ -d "$TPM_HOME/.git" ]]; then
    info "TPM already installed, updating..."
    if ! git -C "$TPM_HOME" pull --quiet; then
      warn "Failed to update TPM, continuing with existing installation"
    else
      success "TPM updated successfully"
    fi
    return 0
  fi

  # Check git availability
  checkcmd git || error "Git is required to install TPM"

  # Create plugin directory
  create_dir "$(dirname "$TPM_HOME")"

  # Clone TPM repository
  if git clone --depth 1 --quiet https://github.com/tmux-plugins/tpm "$TPM_HOME"; then
    success "TPM installed successfully"
    info "TPM location: $TPM_HOME"
  else
    error "Failed to clone TPM repository"
  fi
}

# Set tmux global environment variables for Unicode support
configure_tmux_locale() {
  info "Configuring tmux locale settings..."

  # Check if tmux server is running
  if ! pgrep -x "tmux" >/dev/null 2>&1; then
    info "No tmux server running, locale will be set on first start"
    return 0
  fi

  # Set locale environment variables in tmux global environment
  # This ensures Unicode displays correctly in tmux sessions over SSH
  local locale_vars=(
    "LANG=en_US.UTF-8"
    "LC_ALL=en_US.UTF-8"
    "LC_CTYPE=en_US.UTF-8"
    "LC_COLLATE=en_US.UTF-8"
    "LC_MESSAGES=en_US.UTF-8"
  )

  for locale_var in "${locale_vars[@]}"; do
    tmux set-environment -g "$locale_var" 2>/dev/null || {
      warn "Failed to set tmux environment: $locale_var"
    }
  done

  success "Tmux locale configured for Unicode support"
}

# Install tmux configuration files with enhanced validation
handle_tmux_config() {
  info "Installing tmux configuration..."
  create_dir "$TMUX_CONFIG_HOME"

  # Configuration files to install
  local config_files=(
    "tmux.conf:tmux.conf"
    "tmux.conf.local:tmux.conf.local"
  )

  for config_pair in "${config_files[@]}"; do
    local src_file="${config_pair%:*}"
    local dest_file="${config_pair#*:}"
    local src_path="$THISDIR/$src_file"
    local dest_path="$TMUX_CONFIG_HOME/$dest_file"

    # Validate source file exists
    [[ -f "$src_path" ]] || {
      warn "Source file not found: $src_path"
      continue
    }

    # Install configuration file
    install_file_pair "$src_path" "$dest_path"
  done

  success "Tmux configuration installed"
  info "Configuration directory: $TMUX_CONFIG_HOME"
  info "XDG config: $TMUX_CONFIG_HOME/tmux.conf"
  info "Local config: $TMUX_CONFIG_HOME/tmux.conf.local"
}

# Remove tmux configuration and plugins with backup support
cleanse_tmux() {
  local backup_dir="$HOME/.tmux.backup.$(date +%Y%m%d_%H%M%S)"

  info "Cleansing tmux configuration..."

  # Create backup directory
  create_dir "$backup_dir"

  # Backup existing configuration files before removal
  local files_to_backup=(
    "$TMUX_CONFIG_HOME/tmux.conf"
    "$TMUX_CONFIG_HOME/tmux.conf.local"
  )

  for backup_file in "${files_to_backup[@]}"; do
    if [[ -e "$backup_file" ]]; then
      local filename=$(basename "$backup_file")
      # Dereference symlinks when backing up
      if [[ -L "$backup_file" ]]; then
        cp -L "$backup_file" "$backup_dir/$filename" 2>/dev/null || {
          warn "Failed to backup: $backup_file"
        }
      else
        cp "$backup_file" "$backup_dir/$filename" 2>/dev/null || {
          warn "Failed to backup: $backup_file"
        }
      fi
      info "Backed up: $backup_file"
    fi
  done

  # Items to remove (including entire plugins directory)
  local items_to_remove=(
    "$TMUX_CONFIG_HOME/tmux.conf"
    "$TMUX_CONFIG_HOME/tmux.conf.local"
    "$TMUX_CONFIG_HOME/plugins"
  )

  for item in "${items_to_remove[@]}"; do
    if [[ -e "$item" ]]; then
      rm -rf "$item"
      info "Removed: $item"
    fi
  done

  # Remove empty directories
  if [[ -d "$TMUX_CONFIG_HOME" ]]; then
    rmdir "$TMUX_CONFIG_HOME" 2>/dev/null || {
      info "Configuration directory not empty, preserving: $TMUX_CONFIG_HOME"
    }
  fi

  # Unset tmux global locale environment variables if server is running
  if pgrep -x "tmux" >/dev/null 2>&1; then
    info "Unsetting tmux locale environment variables..."
    tmux set-environment -gu LANG 2>/dev/null || true
    tmux set-environment -gu LC_ALL 2>/dev/null || true
    tmux set-environment -gu LC_CTYPE 2>/dev/null || true
    tmux set-environment -gu LC_COLLATE 2>/dev/null || true
    tmux set-environment -gu LC_MESSAGES 2>/dev/null || true
  fi

  success "Tmux configuration cleansed successfully"
  info "Backup location: $backup_dir"
  info "To restore: cp $backup_dir/* to original locations"
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_tmux && exit 0 ;;
  h | ?)
    usage_me "install.sh"
    exit 0
    ;;
  esac
done

# Main installation sequence
main() {
  info "Starting tmux installation..."

  # Installation steps
  install_tmux
  install_tpm
  handle_tmux_config
  configure_tmux_locale

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Tmux configuration: $TMUX_CONFIG_HOME"
  info "Plugin manager: $TPM_HOME"
  info "Locale configured: UTF-8 support enabled"
  info "XDG Base Directory: Pure XDG compliance (no ~/.tmux.conf symlink)"
  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Start tmux: %btmux%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Install plugins: %bPrefix + I%b (default: Ctrl-a + I)\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. Reload config: %bPrefix + r%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  4. Verify Unicode: %btmux show-environment -g | grep LANG%b\n" "$COLOR_CYAN" "$COLOR_RESET"

  success "Tmux installation completed successfully!"
}

# Execute main function
main
