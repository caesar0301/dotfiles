#!/bin/bash
###################################################
# Zellij Binary Installer
# https://github.com/caesar0301/cool-dotfiles
#
# Installs zellij from GitHub releases when Homebrew is not available.
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

readonly ZELLIJ_VERSION="0.44.3"

detect_zellij_target() {
  local arch os

  case "$(uname -m)" in
  x86_64 | amd64) arch="x86_64" ;;
  arm64 | aarch64) arch="aarch64" ;;
  *)
    error "Unsupported architecture for zellij: $(uname -m)"
    ;;
  esac

  if is_macos; then
    os="apple-darwin"
  elif is_linux; then
    os="unknown-linux-musl"
  else
    error "Unsupported operating system for zellij binary install"
  fi

  printf '%s' "zellij-${arch}-${os}"
}

main() {
  if checkcmd zellij; then
    info "Zellij already installed (version: $(zellij --version 2>/dev/null || echo unknown))"
    exit 0
  fi

  info "Installing zellij ${ZELLIJ_VERSION} from GitHub releases..."

  create_dir "$HOME/.local/bin"
  local build_dir target archive_path download_url
  build_dir=$(get_temp_dir_no_cleanup)
  target=$(detect_zellij_target)
  archive_path="$build_dir/${target}.tar.gz"
  download_url="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/${target}.tar.gz"

  download_file "$download_url" "$archive_path"
  extract_tar "$archive_path" "$build_dir"

  local binary_path="$build_dir/zellij"
  [[ -f "$binary_path" ]] || error "Zellij binary not found in archive"

  install -m 755 "$binary_path" "$HOME/.local/bin/zellij"
  export PATH="$HOME/.local/bin:$PATH"

  if checkcmd zellij; then
    success "Zellij ${ZELLIJ_VERSION} installed successfully"
    info "Zellij version: $(zellij --version)"
  else
    error "Zellij installation verification failed"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
