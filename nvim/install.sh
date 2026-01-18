#!/bin/bash
###################################################
# Neovim Development Environment Setup
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Lazy.nvim plugin manager with auto-installation
# - Language formatters and linters
# - Language Server Protocol (LSP) support
# - Code navigation tools (ctags, ripgrep)
# - Syntax highlighting and completion
#
# Maintainer: xiaming.chen
###################################################

set -euo pipefail

# Resolve script location
THISDIR=$(dirname "$(realpath "$0")")
LAZY_HOME="$HOME/.local/share/nvim/lazy/lazy.nvim"

# Load common utilities
source "$THISDIR/../lib/shmisc.sh" || {
  echo "Error: Failed to load shmisc.sh"
  exit 1
}

function check_dependencies {
  local missing_deps=()
  local kernel_version

  # Get kernel version for compatibility checks
  if is_linux; then
    kernel_version=$(get_kernel_version)
    info "Detected kernel version: $kernel_version"

    # Check if kernel version meets modern plugin requirements
    if [[ $(echo "$kernel_version < 5.0" | bc -l 2>/dev/null || echo "1") == "1" ]]; then
      warn "Kernel version $kernel_version < 5.0 detected"
      warn "Some modern plugins (avante.nvim, rust features) will be disabled for compatibility"
    fi
  fi

  # Check ripgrep for telescope.nvim
  if ! checkcmd rg; then
    warn "ripgrep not found, telescope.nvim functionality will be limited"
  fi

  # Check bc for version comparison (install if missing on Linux)
  install_bc
}

# Function to handle Neovim installation and configuration
function handle_neovim {
  # Install plugin manager
  if [ ! -e "$LAZY_HOME" ]; then
    info "Installing plugin manager Lazy.nvim..."
    git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_HOME"
  fi
  if [ -e "$XDG_CONFIG_HOME/nvim" ]; then
    warn "Neovim configuration directory already exists, skipping installation"
  else
    install_file_pair "$THISDIR" "$XDG_CONFIG_HOME/nvim"
  fi

  install_nvim_python

  if ! npm_install_lib neovim; then
    warn "Failed to install neovim"
  fi
}

# Function to cleanse all Neovim-related files
function cleanse_all {
  rm -rf "$HOME/.ctags"
  rm -rf "$XDG_CONFIG_HOME/nvim"
  rm -rf "$XDG_DATA_HOME/nvim/lazy"
  info "All Neovim files cleansed!"
}

function main {
  # Parse command line options
  # Change to 0 to install a copy instead of soft link
  LINK_INSTEAD_OF_COPY=1
  while getopts fsech opt; do
    case $opt in
    f) LINK_INSTEAD_OF_COPY=0 ;;
    s) LINK_INSTEAD_OF_COPY=1 ;;
    c) cleanse_all && exit 0 ;;
    h | ?)
      usage_me "install.sh"
      exit 0
      ;;
    esac
  done

  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi

  # Check required dependencies
  check_dependencies

  # Install Neovim and configure
  install_neovim && handle_neovim

  # Install LSP servers
  "$script_dir/../lib/install-lsp.sh"

  # Required by nvim-web-devicons
  "$script_dir/../lib/install-hack-nerd-font.sh"

  # Install language formatters
  "$script_dir/../lib/install-lang-formatters.sh"

  # Install additional tools
  install_fzf
  install_universal_ctags # Required by Tagbar
  install_cargo           # Conditionally based on kernel version

  warn "================================================"
  warn "Plugins will auto-install on first Neovim startup with Lazy.nvim:"
  warn "Run :checkhealth to validate overall health"
  warn "================================================"
}

main "$@"
