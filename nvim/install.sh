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

readonly FORMATTERS_PIP="pynvim cmake_format"
readonly LSP_R="languageserver"

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

function install_lang_formatters {
  info "Installing language formatters..."

  # Install pip formatters
  if ! pip_install_lib ${FORMATTERS_PIP}; then
    warn "Failed to install some pip formatters"
  fi

  # Install formatters via brew (preferred) or fallback to npm/go/pip/script
  local formatter_packages=(
    "stylua"
    "js-beautify"
    "yaml-language-server"
    "yamlfmt"
    "shfmt"
    "google-java-format"
    "black"
    "sqlparse"
  )

  for pkg in "${formatter_packages[@]}"; do
    if checkcmd "$pkg"; then
      info "$pkg already installed"
      continue
    fi

    if checkcmd brew; then
      if brew install "$pkg" 2>/dev/null; then
        success "Installed $pkg via brew"
        continue
      fi
    fi

    # Fallback to npm/go/script for specific packages
    case "$pkg" in
    stylua)
      if ! npm_install_lib @johnnymorganz/stylua-bin; then
        warn "Failed to install stylua"
      fi
      ;;
    js-beautify | yaml-language-server)
      if ! npm_install_lib "$pkg"; then
        warn "Failed to install $pkg"
      fi
      ;;
    yamlfmt)
      if ! go_install_lib github.com/google/yamlfmt/cmd/yamlfmt@latest; then
        warn "Failed to install yamlfmt"
      fi
      ;;
    shfmt)
      if ! install_shfmt; then
        warn "Failed to install shfmt"
      fi
      ;;
    google-java-format)
      if ! install_google_java_format; then
        warn "Failed to install google-java-format"
      fi
      ;;
    black | sqlparse)
      if ! pip_install_lib "$pkg"; then
        warn "Failed to install $pkg"
      fi
      ;;
    esac
  done

  info "Language formatters installation completed"
}

function install_lsp_deps {
  info "Installing LSP servers..."

  # Install R LSP server
  if ! rlang_install_lib ${LSP_R}; then
    warn "Failed to install R language server"
  fi

  # Install LSP servers via brew (preferred) or fallback to pip/go
  local lsp_packages=(
    "pyright"
    "cmake-language-server"
    "gopls"
    "gotags"
  )

  for pkg in "${lsp_packages[@]}"; do
    if checkcmd "$pkg"; then
      info "$pkg already installed"
      continue
    fi

    if checkcmd brew; then
      if brew install "$pkg" 2>/dev/null; then
        success "Installed $pkg via brew"
        continue
      fi
    fi

    # Fallback to pip/go for specific packages
    case "$pkg" in
    pyright | cmake-language-server)
      if ! pip_install_lib "$pkg"; then
        warn "Failed to install $pkg"
      fi
      ;;
    gopls)
      if ! go_install_lib "golang.org/x/tools/gopls@latest"; then
        warn "Failed to install gopls"
      fi
      ;;
    gotags)
      if ! go_install_lib "github.com/jstemmer/gotags@latest"; then
        warn "Failed to install gotags"
      fi
      ;;
    esac
  done

  info "LSP servers installation completed"
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

  # Install Neovim and configure
  install_neovim && handle_neovim

  # Check required dependencies
  check_dependencies

  # Install LSP servers
  install_lsp_deps

  # Install JDTLS if INSTALL_JDTLS=1 is set
  if [[ "${INSTALL_JDTLS:-0}" == "1" ]]; then
    info "JDTLS installation enabled via INSTALL_JDTLS=1"
    install_jdt_language_server
  fi

  # Install fonts and formatters
  install_hack_nerd_font # Required by nvim-web-devicons
  install_lang_formatters

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
