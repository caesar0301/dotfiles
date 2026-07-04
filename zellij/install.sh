#!/bin/bash
###################################################
# Zellij Terminal Multiplexer Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Zellij binary installation (brew preferred, release binary fallback)
# - Modern configuration with XDG compliance
# - Base + local config merge (config.local.kdl overrides)
#
# Author: Xiaming Chen
# License: MIT
###################################################

set -euo pipefail

THISDIR=$(dirname "$(realpath "$0")")

readonly ZELLIJ_VERSION="0.44.3"
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
readonly ZELLIJ_CONFIG_HOME="$XDG_CONFIG_HOME/zellij"

source "$THISDIR/../lib/shlib.sh" || {
  printf "\033[0;31m✗ Failed to load shlib.sh\033[0m\n" >&2
  exit 1
}

install_zellij() {
  if checkcmd zellij; then
    info "Zellij already installed (version: $(zellij --version 2>/dev/null || echo unknown))"
    return 0
  fi

  info "Installing zellij $ZELLIJ_VERSION..."

  if checkcmd brew; then
    info "Installing zellij via Homebrew..."
    if brew install zellij; then
      export PATH="$(brew --prefix)/bin:$PATH"
      success "Zellij installed via Homebrew"
      info "Zellij version: $(zellij --version)"
      return 0
    else
      warn "Homebrew zellij installation failed, falling back to release binary"
    fi
  else
    info "Homebrew not found, installing zellij from GitHub releases"
  fi

  local script_dir="$THISDIR/../lib"
  if [[ -f "$script_dir/install-zellij.sh" ]]; then
    "$script_dir/install-zellij.sh"
  else
    error "Cannot install zellij: Homebrew not available and release installer not found"
  fi
}

merge_zellij_config() {
  local base_file="$1"
  local local_file="$2"
  local dest_file="$3"

  [[ -f "$base_file" ]] || error "Zellij base config not found: $base_file"

  cat "$base_file" >"$dest_file"
  if [[ -f "$local_file" ]]; then
    printf '\n' >>"$dest_file"
    cat "$local_file" >>"$dest_file"
  fi

  if ! grep -q '^copy_command ' "$dest_file"; then
    if is_macos && checkcmd pbcopy; then
      printf '\ncopy_command "pbcopy"\n' >>"$dest_file"
    elif [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] && checkcmd wl-copy; then
      printf '\ncopy_command "wl-copy"\n' >>"$dest_file"
    elif checkcmd xclip; then
      printf '\ncopy_command "xclip -selection clipboard"\n' >>"$dest_file"
    fi
  fi
}

handle_zellij_config() {
  info "Installing zellij configuration..."
  create_dir "$ZELLIJ_CONFIG_HOME"

  local base_src="$THISDIR/config.kdl"
  local local_src="$THISDIR/config.local.kdl"
  local base_dest="$ZELLIJ_CONFIG_HOME/config.kdl.base"
  local local_dest="$ZELLIJ_CONFIG_HOME/config.local.kdl"
  local merged_dest="$ZELLIJ_CONFIG_HOME/config.kdl"

  [[ -f "$base_src" ]] || error "Source file not found: $base_src"

  install_file_pair "$base_src" "$base_dest"
  if [[ -f "$local_src" ]]; then
    install_file_pair "$local_src" "$local_dest"
  fi

  merge_zellij_config "$base_dest" "$local_dest" "$merged_dest"

  success "Zellij configuration installed"
  info "Configuration directory: $ZELLIJ_CONFIG_HOME"
  info "Active config: $merged_dest"
  info "Local overrides: $local_dest"
}

cleanse_zellij() {
  local backup_dir="$HOME/.zellij.backup.$(date +%Y%m%d_%H%M%S)"

  info "Cleansing zellij configuration..."
  create_dir "$backup_dir"

  local files_to_backup=(
    "$ZELLIJ_CONFIG_HOME/config.kdl"
    "$ZELLIJ_CONFIG_HOME/config.kdl.base"
    "$ZELLIJ_CONFIG_HOME/config.local.kdl"
  )

  for backup_file in "${files_to_backup[@]}"; do
    if [[ -e "$backup_file" ]]; then
      local filename
      filename=$(basename "$backup_file")
      if [[ -L "$backup_file" ]]; then
        cp -L "$backup_file" "$backup_dir/$filename" 2>/dev/null || warn "Failed to backup: $backup_file"
      else
        cp "$backup_file" "$backup_dir/$filename" 2>/dev/null || warn "Failed to backup: $backup_file"
      fi
      info "Backed up: $backup_file"
    fi
  done

  local items_to_remove=(
    "$ZELLIJ_CONFIG_HOME/config.kdl"
    "$ZELLIJ_CONFIG_HOME/config.kdl.base"
    "$ZELLIJ_CONFIG_HOME/config.local.kdl"
  )

  for item in "${items_to_remove[@]}"; do
    if [[ -e "$item" ]]; then
      rm -f "$item"
      info "Removed: $item"
    fi
  done

  if [[ -d "$ZELLIJ_CONFIG_HOME/layouts" ]]; then
    rm -rf "$ZELLIJ_CONFIG_HOME/layouts"
    info "Removed: $ZELLIJ_CONFIG_HOME/layouts"
  fi

  if [[ -d "$ZELLIJ_CONFIG_HOME" ]]; then
    rmdir "$ZELLIJ_CONFIG_HOME" 2>/dev/null || {
      info "Configuration directory not empty, preserving: $ZELLIJ_CONFIG_HOME"
    }
  fi

  success "Zellij configuration cleansed successfully"
  info "Backup location: $backup_dir"
}

LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_zellij && exit 0 ;;
  h | ?)
    usage_me "install.sh"
    exit 0
    ;;
  esac
done

main() {
  info "Starting zellij installation..."

  install_zellij
  handle_zellij_config

  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Zellij configuration: $ZELLIJ_CONFIG_HOME"
  info "XDG Base Directory: Pure XDG compliance (~/.config/zellij/config.kdl)"
  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Start zellij: %bzellij%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Attach to session: %bzellij attach%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. Edit local overrides: %bconfig.local.kdl%b then re-run install\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  4. Command palette: %bCtrl-o%b (default preset)\n" "$COLOR_CYAN" "$COLOR_RESET"

  success "Zellij installation completed successfully!"
}

main
