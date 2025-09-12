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

# Install Zinit plugin manager with enhanced validation
install_zinit() {
  info "Installing Zinit plugin manager..."

  if [[ -d "$ZINIT_HOME/.git" ]]; then
    info "Zinit already installed, updating..."
    if git -C "$ZINIT_HOME" pull --quiet; then
      success "Zinit updated successfully"
    else
      warn "Failed to update Zinit, continuing with existing installation"
    fi
    return 0
  fi

  # Check git availability
  checkcmd git || error "Git is required to install Zinit"

  # Create Zinit directory
  create_dir "$(dirname "$ZINIT_HOME")"

  # Clone Zinit repository
  if git clone --depth 1 --quiet https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"; then
    success "Zinit installed successfully"
    info "Zinit location: $ZINIT_HOME"
  else
    error "Failed to clone Zinit repository"
  fi
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

install_zsh() {
  # Check if zsh is executable
  if command -v zsh >/dev/null 2>&1; then
    info "Zsh already installed: $(zsh --version)"
    return 0
  fi

  # Zsh not found, provide installation instructions
  error "Zsh is not installed or not in PATH"
  printf "\n%bInstallation Instructions:%b\n" "$COLOR_BOLD$COLOR_YELLOW" "$COLOR_RESET"
  printf "Please install Zsh from: %bhttps://sourceforge.net/projects/zsh/files/%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "\nQuick installation options:\n"
  printf "  • %bUbuntu/Debian:%b sudo apt install zsh\n" "$COLOR_GREEN" "$COLOR_RESET"
  printf "  • %bCentOS/RHEL:%b sudo yum install zsh\n" "$COLOR_GREEN" "$COLOR_RESET"
  printf "  • %bmacOS:%b brew install zsh\n" "$COLOR_GREEN" "$COLOR_RESET"
  printf "  • %bSource:%b Download from SourceForge and build from source\n" "$COLOR_GREEN" "$COLOR_RESET"

  exit 1
}

# Install Zsh configuration files with enhanced validation
handle_zsh_config() {
  info "Installing Zsh configuration..."

  # Create Zsh config directory
  create_dir "$ZSH_CONFIG_HOME"

  # Install main .zshrc file
  install_file_pair "$THISDIR/zshrc" "$HOME/.zshrc"

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

  # Install custom plugins
  install_zsh_plugins

  success "Zsh configuration installed"
}

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
  while IFS= read -r -d '' plugin_file; do
    local plugin_dir
    plugin_dir=$(dirname "$plugin_file")
    local plugin_name
    plugin_name=$(basename "$plugin_dir")

    install_file_pair "$plugin_dir" "$target_plugins_dir/$plugin_name"
  done < <(find "$plugins_dir" -name "*.plugin.zsh" -print0 2>/dev/null || true)

  # Comment out to skip custom development plugins of my self
  if [ ! -e $target_plugins_dir/zsh-caesardev ]; then
    git clone --depth=1 https://github.com/caesar0301/zsh-caesardev.git $target_plugins_dir/zsh-caesardev
  fi

  success "Custom plugins installed"
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

# Install development environment dependencies
install_dev_environment() {
  info "Installing development environment dependencies..."

  # Core dependencies
  local core_deps=(
    "install_zsh"   # Zsh shell binary
    "install_pyenv" # Python version manager
  )

  # Optional dependencies (commented out by default)
  local optional_deps=(
    # "install_jenv"     # Java version manager
    # "install_gvm"      # Go version manager
    # "install_nvm"      # Node version manager
  )

  # Install core dependencies
  for dep_func in "${core_deps[@]}"; do
    if declare -f "$dep_func" >/dev/null; then
      info "Installing dependency: ${dep_func#install_}"
      if ! "$dep_func"; then
        warn "Failed to install ${dep_func#install_}, continuing..."
      fi
    else
      warn "Dependency function not found: $dep_func"
    fi
  done

  # Install AI code agents if available
  if declare -f "install_ai_code_agents" >/dev/null; then
    info "Installing AI code agents..."
    install_ai_code_agents || warn "Failed to install AI code agents"
  fi

  success "Development environment dependencies installed"
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
  info "Starting Zsh development environment setup..."

  # Installation steps
  install_dev_environment
  install_zinit
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
