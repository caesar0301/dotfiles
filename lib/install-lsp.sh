#!/bin/bash
###################################################
# Language Server Protocol (LSP) Installer
#
# Installs various LSP servers for Neovim development environment
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Define R LSP server to install
readonly LSP_R="languageserver"

# Install jdt-language-server
install_jdt_language_server() {
  info "Installing jdt-language-server..."
  local dpath="$HOME/.local/share/jdt-language-server"
  local jdtdl="https://download.eclipse.org/jdtls/milestones/1.23.0/jdt-language-server-1.23.0-202304271346.tar.gz"

  if [ ! -e "$dpath/bin/jdtls" ]; then
    create_dir "$dpath"
    curl -L --progress-bar "$jdtdl" | tar zxf - -C "$dpath"
    success "jdt-language-server installed successfully"
  else
    info "$dpath/bin/jdtls already exists"
  fi
}

# Main installation function
main() {
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

  # Install JDTLS if INSTALL_JDTLS=1 is set
  if [[ "${INSTALL_JDTLS:-0}" == "1" ]]; then
    info "JDTLS installation enabled via INSTALL_JDTLS=1"
    install_jdt_language_server
  fi

  info "LSP servers installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
