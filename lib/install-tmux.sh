#!/bin/bash
###################################################
# Tmux Source Installer
# https://github.com/caesar0301/cool-dotfiles
#
# Builds and installs tmux from source when Homebrew is not available.
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

readonly TMUX_VERSION="3.6"

main() {
  if checkcmd tmux; then
    local current_version
    current_version=$(tmux -V 2>/dev/null | grep -o '[0-9.]\+' | head -1 || echo "unknown")
    info "Tmux already installed (version: $current_version)"
    exit 0
  fi

  info "Installing tmux $TMUX_VERSION from source..."

  # Check build dependencies
  local missing_deps=()
  for dep in gcc make; do
    if ! checkcmd "$dep"; then
      missing_deps+=("$dep")
    fi
  done

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    warn "Missing build dependencies: ${missing_deps[*]}"
    warn "Please install them manually or via package manager"
  fi

  create_dir "$HOME/.local/bin"
  local build_dir
  build_dir=$(get_temp_dir_no_cleanup)

  local download_url="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
  local archive_path="$build_dir/tmux-${TMUX_VERSION}.tar.gz"

  download_file "$download_url" "$archive_path"
  extract_tar "$archive_path" "$build_dir"

  info "Compiling tmux (this may take a few minutes)..."
  (
    cd "$build_dir/tmux-${TMUX_VERSION}" || error "Failed to enter build directory"

    git config --global --add safe.directory "$build_dir/tmux-${TMUX_VERSION}" 2>/dev/null || true
    if ! ./configure --prefix="$HOME/.local" --enable-static; then
      error "Configuration failed. Check build dependencies."
    fi

    if ! make -j"$(nproc 2>/dev/null || echo 2)"; then
      error "Compilation failed"
    fi

    if ! make install; then
      error "Installation failed"
    fi
  ) || return 1

  export PATH="$HOME/.local/bin:$PATH"
  if checkcmd tmux; then
    success "Tmux $TMUX_VERSION installed successfully"
    info "Tmux version: $(tmux -V)"
  else
    error "Tmux installation verification failed"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
