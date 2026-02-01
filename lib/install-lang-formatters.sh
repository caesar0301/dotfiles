#!/bin/bash
###################################################
# Language Formatters Installer
#
# Installs various language formatters and linters
# for Neovim development environment
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Define pip formatters to install
readonly FORMATTERS_PIP="pynvim cmake_format"

# Install shfmt (shell formatter)
# Arguments:
#   $1 - shfmt version to install (default: v3.7.0)
install_shfmt() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-shfmt.sh" "$@"
}

# Install google-java-format
install_google_java_format() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-google-java-format.sh"
}

# Main installation function
main() {
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
    "prettier"
    "prettierd"
    "taplo"
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
    js-beautify | yaml-language-server | prettier)
      if ! npm_install_lib "$pkg"; then
        warn "Failed to install $pkg"
      fi
      ;;
    prettierd)
      if ! npm_install_lib @fsouza/prettierd; then
        warn "Failed to install prettierd"
      fi
      ;;
    taplo)
      if ! npm_install_lib @taplo/cli; then
        warn "Failed to install taplo"
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

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
