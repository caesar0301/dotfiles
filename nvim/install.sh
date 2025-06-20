#!/bin/bash
###################################################
# Neovim Development Environment Setup
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
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
readonly FORMATTERS_NPM="neovim yaml-language-server js-beautify @johnnymorganz/stylua-bin tree-sitter-cli"
readonly FORMATTERS_GO="github.com/google/yamlfmt/cmd/yamlfmt@latest"

# LSP packages for each package manager
readonly LSP_PIP="pyright cmake-language-server"
readonly LSP_R="languageserver"
readonly LSP_GO="golang.org/x/tools/gopls@latest github.com/jstemmer/gotags@latest"

function check_dependencies {
  local missing_deps=()

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

  # Install npm formatters
  if ! npm_install_lib ${FORMATTERS_NPM}; then
    warn "Failed to install some npm formatters"
  fi

  # Install Go formatters
  if ! go_install_lib ${FORMATTERS_GO}; then
    warn "Failed to install some Go formatters"
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

function setup_ctags {
  local ctags_home="$HOME/.ctags.d"
  create_dir "$ctags_home"

  if [ ! -d "$THISDIR/../ctags" ]; then
    error "Ctags configuration directory not found"
    return 1
  fi

  local config_files=($(find "$THISDIR/../ctags" -maxdepth 1 -type f -name "*.ctags"))
  if [ ${#config_files[@]} -eq 0 ]; then
    warn "No ctags configuration files found"
    return 0
  fi

  # Install each ctags configuration file
  local success=true
  for config_file in "${config_files[@]}"; do
    if ! install_file_pair "$config_file" "$ctags_home/$(basename "$config_file")"; then
      warn "Failed to install ctags config: $(basename "$config_file")"
      success=false
    fi
  done

  if [ "$success" = true ]; then
    info "Ctags configuration completed"
  else
    warn "Some ctags configurations failed to install"
    return 1
  fi
}

# Function to handle Neovim installation and configuration
function handle_neovim {
  # Install plugin manager
  local packer_home="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
  if [ ! -e "$packer_home" ]; then
    info "Installing plugin manager Packer..."
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$packer_home"
  fi
  install_file_pair "$THISDIR" "$XDG_CONFIG_HOME/"
}

function post_install {
  warn "**********Post installation*************"
  warn "Run following commands in Neovim to install plugins:"
  warn ":PackerInstall"
  warn "****************************************"
}

# Function to cleanse all Neovim-related files
function cleanse_all {
  rm -rf "$HOME/.ctags"
  rm -rf "$XDG_CONFIG_HOME/nvim"
  rm -rf "$XDG_DATA_HOME/nvim/site/pack"
  info "All Neovim files cleansed!"
}

# Function to display usage information
function usage {
  echo "Usage: install.sh [-f] [-s] [-e] [-c]"
  echo "  -f copy and install"
  echo "  -s soft link install"
  echo "  -e install dependencies"
  echo "  -c cleanse install"
}

# Change to 0 to install a copy instead of soft link
LINK_INSTEAD_OF_COPY=1
WITHDEPS=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  e) WITHDEPS=1 ;;
  c) cleanse_all && exit 0 ;;
  h | ?) usage && exit 0 ;;
  esac
done

install_neovim
handle_neovim

if [ "x$WITHDEPS" == "x1" ]; then
  install_lsp_deps
  install_jdt_language_server
  install_hack_nerd_font # Required by nvim-web-devicons
  install_lang_formatters
  install_fzf
  setup_ctags
fi

post_install
info "Success! Run :PackerInstall to install Neovim plugins"
