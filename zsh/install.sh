#!/bin/bash
###################################################
# Zsh Development Environment Setup
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Modern Zsh configuration with XDG compliance
# - Zinit plugin manager installation
# - Shell proxy configuration
# - Custom plugin management
# - Development environment integration
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
readonly XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
readonly ZSH_CONFIG_HOME="$XDG_CONFIG_HOME/zsh"
readonly ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
readonly PROXY_CONFIG="$HOME/.config/proxy"

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Configuration files to install
readonly INSTALL_FILES=(
  "init.zsh"
  "_helper.zsh"
)

# Install custom Zsh plugins
install_zsh_plugins() {
  local plugins_dir="$THISDIR/plugins"
  local target_plugins_dir="$ZSH_CONFIG_HOME/plugins"

  [[ -d "$plugins_dir" ]] || {
    info "No custom plugins directory found"
    return 0
  }

  info "Installing custom Zsh plugins..."
  create_dir "$target_plugins_dir"

  # Find and install plugin directories
  find "$plugins_dir" -name "*.plugin.zsh" -print0 2>/dev/null | while IFS= read -r -d '' plugin_file; do
    local plugin_dir
    plugin_dir=$(dirname "$plugin_file")
    local plugin_name
    plugin_name=$(basename "$plugin_dir")
    install_file_pair "$plugin_dir" "$target_plugins_dir/$plugin_name"
  done

  # Comment out to skip custom development plugins of my self
  if [ ! -e "$target_plugins_dir/zsh-caesardev" ]; then
    git clone --depth=1 https://github.com/caesar0301/zsh-caesardev.git "$target_plugins_dir/zsh-caesardev"
  fi

  success "Custom plugins installed"
}

# Configure shell proxy settings with validation
handle_shell_proxy() {
  info "Configuring shell proxy settings..."

  local proxy_source="$THISDIR/config/proxy-config"

  # Validate source file exists
  [[ -f "$proxy_source" ]] || {
    warn "Proxy configuration file not found: $proxy_source"
    return 0
  }

  # Check if proxy config already exists and is not a symlink
  if [[ -f "$PROXY_CONFIG" && ! -L "$PROXY_CONFIG" ]]; then
    warn "Proxy configuration already exists: $PROXY_CONFIG"
    warn "Skipping to preserve existing settings"
    return 0
  fi

  # Create config directory
  create_dir "$(dirname "$PROXY_CONFIG")"

  # Install proxy configuration
  install_file_pair "$proxy_source" "$PROXY_CONFIG"
  success "Proxy configuration installed"
}

# Install Zsh configuration files with enhanced validation
handle_zsh_config() {
  info "Installing Zsh configuration..."

  # Create Zsh config directory
  create_dir "$ZSH_CONFIG_HOME"

  # Install main .zshrc file
  if [ ! -e $HOME/.zshrc ]; then
    install_file_pair "$THISDIR/zshrc" "$HOME/.zshrc"
  fi

  # Install configuration files
  for config_file in "${INSTALL_FILES[@]}"; do
    local src_path="$THISDIR/$config_file"
    local dest_path="$ZSH_CONFIG_HOME/$config_file"

    if [[ -f "$src_path" ]]; then
      install_file_pair "$src_path" "$dest_path"
    else
      warn "Configuration file not found: $src_path"
    fi
  done

  # Change default shell to zsh if not already
  change_shell_to_zsh

  success "Zsh configuration installed"
}

# Remove Zsh configuration and plugins
cleanse_zsh() {
  info "Cleansing Zsh configuration..."
  if [ -e $HOME/.zshrc ]; then
    cp -L $HOME/.zshrc $HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
  fi

  local items_to_remove=(
    "$HOME/.zshrc"
    "$ZINIT_HOME"
    "$PROXY_CONFIG"
    "$ZSH_CONFIG_HOME"
  )

  for item in "${items_to_remove[@]}"; do
    if [[ -e "$item" ]]; then
      rm -rf "$item"
      info "Removed: $item"
    fi
  done

  success "Zsh configuration cleansed successfully"
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_zsh && exit 0 ;;
  h | ?)
    usage_me "install.sh"
    exit 0
    ;;
  esac
done

# Main installation sequence
main() {
  info "Starting Zsh environment setup..."

  # Core dependencies
  local core_deps=(
    "install_zsh"         # Zsh shell binary
    "install_zinit"       # Zinit plugin manager
    "install_zsh_plugins" # Zsh plugins
    "install_pyenv"       # Python version manager
  )

  # Add homebrew if INSTALL_HOMEBREW=1 is set
  if [[ "${INSTALL_HOMEBREW:-0}" == "1" ]]; then
    core_deps+=("install_homebrew")
    info "Homebrew installation enabled via INSTALL_HOMEBREW=1"
  fi

  if [[ "${INSTALL_EXTRA_VENV:-0}" == "1" ]]; then
    core_deps+=("install_jenv" "install_gvm" "install_nvm")
    info "Development environment installation enabled via INSTALL_EXTRA_VENV=1"
  fi

  # Install AI code agents if available
  if [[ "${INSTALL_AI_CODE_AGENTS:-0}" == "1" ]]; then
    core_deps+=("install_ai_code_agents")
    info "AI code agents installation enabled via INSTALL_AI_CODE_AGENTS=1"
  fi

  # Installation steps
  handle_shell_proxy
  handle_zsh_config

  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Zsh configuration: $ZSH_CONFIG_HOME"
  info "Plugin manager: $ZINIT_HOME"
  info "Proxy configuration: $PROXY_CONFIG"

  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Restart your shell or run: %bexec zsh%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Plugins will be installed automatically on first run\n"
  printf "  3. Configure proxy settings in: %b$PROXY_CONFIG%b\n" "$COLOR_CYAN" "$COLOR_RESET"

  success "Zsh development environment setup completed successfully!"
}

# Execute main function
main
