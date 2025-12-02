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

# Package manager keys and their packages
readonly PKG_PIP="pip"
readonly PKG_NPM="npm"
readonly PKG_GO="go"
readonly PKG_R="r"

# Formatter packages for each package manager
readonly FORMATTERS_PIP="pynvim black sqlparse cmake_format"

# LSP packages for each package manager
readonly LSP_PIP="pyright cmake-language-server"
readonly LSP_R="languageserver"
readonly LSP_GO="golang.org/x/tools/gopls@latest github.com/jstemmer/gotags@latest"

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

  # Check essential package managers
  local required_cmds=(
    "${PKG_PIP}"
    "${PKG_NPM}"
    "${PKG_GO}"
    "${PKG_R}"
  )

  for cmd in "${required_cmds[@]}"; do
    if ! checkcmd "$cmd"; then
      missing_deps+=("$cmd")
    fi
  done

  # Check ripgrep for telescope.nvim
  if ! checkcmd rg; then
    warn "ripgrep not found, telescope.nvim functionality will be limited"
  fi

  # Check bc for version comparison (install if missing on Linux)
  install_bc

  if [ ${#missing_deps[@]} -gt 0 ]; then
    error "Missing required dependencies: ${missing_deps[*]}"
    return 1
  fi
}

function install_lang_formatters {
  info "Installing language formatters..."

  # Install Java formatter
  if ! install_google_java_format; then
    warn "Failed to install google-java-format"
  fi

  # Install shell formatter
  if ! install_shfmt; then
    warn "Failed to install shfmt"
  fi

  # Install pip formatters
  if ! pip_install_lib ${FORMATTERS_PIP}; then
    warn "Failed to install some pip formatters"
  fi

  if ! checkcmd stylua; then
    if ! npm_install_lib @johnnymorganz/stylua-bin; then
      warn "Failed to install stylua"
    fi
  fi

  if ! checkcmd js-beautify; then
    if ! npm_install_lib js-beautify; then
      warn "Failed to install js-beautify"
    fi
  fi

  if ! checkcmd yaml-language-server; then
    if ! npm_install_lib yaml-language-server; then
      warn "Failed to install yaml-language-server"
    fi
  fi

  if ! checkcmd yamlfmt; then
    if ! go_install_lib github.com/google/yamlfmt/cmd/yamlfmt@latest; then
      warn "Failed to install yamlfmt"
    fi
  fi

  info "Language formatters installation completed"
}

function install_lsp_deps {
  info "Installing LSP servers..."

  # Install pip LSP servers
  if ! pip_install_lib ${LSP_PIP}; then
    warn "Failed to install some pip LSP servers"
  fi

  # Install R LSP server
  if ! rlang_install_lib ${LSP_R}; then
    warn "Failed to install R language server"
  fi

  # Install Go LSP servers
  if ! go_install_lib ${LSP_GO}; then
    warn "Failed to install some Go LSP servers"
  fi

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

install_neovim && handle_neovim

check_dependencies

install_lsp_deps
install_jdt_language_server
install_hack_nerd_font # Required by nvim-web-devicons
install_lang_formatters
install_fzf
install_universal_ctags # Required by Tagbar

# Conditionally install cargo based on kernel version (handled in shmisc.sh)
install_cargo

warn "================================================"
warn "Plugins will auto-install on first Neovim startup with Lazy.nvim:"
warn "Run :checkhealth to validate overall health"
warn "================================================"
