#!/bin/bash
###################################################
# Tmux Terminal Multiplexer Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Tmux binary installation from source
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
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Install tmux from source with enhanced error handling
install_tmux() {
  if checkcmd tmux; then
    local current_version
    current_version=$(tmux -V 2>/dev/null | grep -o '[0-9.]\+' | head -1 || echo "unknown")
    info "Tmux already installed (version: $current_version)"
    return 0
  fi

  info "Installing tmux $TMUX_VERSION from source..."

  # Check build dependencies
  local missing_deps=()
  for dep in gcc make libevent-dev ncurses-dev; do
    if ! checkcmd "${dep%%-dev}"; then
      missing_deps+=("$dep")
    fi
  done

  [[ ${#missing_deps[@]} -gt 0 ]] && {
    warn "Missing build dependencies: ${missing_deps[*]}"
    warn "Please install them manually or via package manager"
  }

  # Create build environment
  create_dir "$HOME/.local/bin"
  local build_dir
  build_dir=$(get_temp_dir)

  # Download and extract source
  local download_url="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
  local archive_path="$build_dir/tmux-${TMUX_VERSION}.tar.gz"

  download_file "$download_url" "$archive_path"
  extract_tar "$archive_path" "$build_dir"

  # Build and install
  info "Compiling tmux (this may take a few minutes)..."
  (
    cd "$build_dir/tmux-${TMUX_VERSION}" || error "Failed to enter build directory"

    # Configure with local prefix
    if ! ./configure --prefix="$HOME/.local" --enable-static; then
      error "Configuration failed. Check build dependencies."
    fi

    # Compile
    if ! make -j"$(nproc 2>/dev/null || echo 2)"; then
      error "Compilation failed"
    fi

    # Install
    if ! make install; then
      error "Installation failed"
    fi
  ) || return 1

  # Verify installation
  export PATH="$HOME/.local/bin:$PATH"
  if checkcmd tmux; then
    success "Tmux $TMUX_VERSION installed successfully"
    info "Tmux version: $(tmux -V)"
  else
    error "Tmux installation verification failed"
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
}

# Remove tmux configuration and plugins
cleanse_tmux() {
  local items_to_remove=(
    "$TMUX_CONFIG_HOME/tmux.conf"
    "$TMUX_CONFIG_HOME/tmux.conf.local"
    "$TPM_HOME"
  )

  info "Cleansing tmux configuration..."

  for item in "${items_to_remove[@]}"; do
    if [[ -e "$item" ]]; then
      rm -rf "$item"
      info "Removed: $item"
    fi
  done

  # Remove empty directories
  [[ -d "$TMUX_CONFIG_HOME" ]] && rmdir "$TMUX_CONFIG_HOME" 2>/dev/null || true

  success "Tmux configuration cleansed successfully"
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

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Tmux configuration: $TMUX_CONFIG_HOME"
  info "Plugin manager: $TPM_HOME"
  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Start tmux: %btmux%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Install plugins: %bPrefix + I%b (default: Ctrl-b + I)\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. Reload config: %bPrefix + r%b\n" "$COLOR_CYAN" "$COLOR_RESET"

  success "Tmux installation completed successfully!"
}

# Execute main function
main
