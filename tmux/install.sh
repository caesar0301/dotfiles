#!/bin/bash
###################################################
# Install script for
# https://github.com/caesar0301/cool-dotfiles
# Maintainer: xiaming.chen
###################################################
THISDIR=$(dirname "$(realpath "$0")")
XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

TMUX_VERSION="3.5a"

# Load common utils
source "$THISDIR/../lib/shmisc.sh"

# Function to install tmux
function install_tmux {
  info "Installing tmux..."
  if ! checkcmd tmux; then
    create_dir "$HOME/.local/bin"
    create_dir "/tmp/build-tmux"
    local link="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
    curl -k -L --progress-bar "$link" | tar xvz -C "/tmp/build-tmux/"
    (
      cd "/tmp/build-tmux/tmux-${TMUX_VERSION}" && ./configure --prefix "$HOME/.local" && make && make install
    )
    rm -rf "/tmp/build-tmux"
  else
    info "tmux binary already installed"
  fi
}

# Function to install TPM (Tmux Plugin Manager)
function install_tpm {
  info "Installing TPM..."
  create_dir "$XDG_CONFIG_HOME/tmux/plugins"
  if [ ! -e "$XDG_CONFIG_HOME/tmux/plugins/tpm" ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$XDG_CONFIG_HOME/tmux/plugins/tpm"
  fi
}

# Function to handle tmux configuration
function handle_tmux {
  create_dir "$XDG_CONFIG_HOME/tmux"
  if [ x"$SOFTLINK" == "x1" ]; then
    ln -sf "$THISDIR/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
    ln -sf "$THISDIR/tmux.conf.local" "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
  else
    cp "$THISDIR/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
    cp "$THISDIR/tmux.conf.local" "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
  fi
}

# Function to cleanse tmux configuration
function cleanse_tmux {
  rm -rf "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
  rm -rf "$XDG_CONFIG_HOME/tmux/tmux.conf"
  rm -rf "$XDG_CONFIG_HOME/tmux/plugins/tpm"
  info "All tmux files cleansed!"
}

# Change to 0 to install a copy instead of soft link
SOFTLINK=1
while getopts fsech opt; do
  case $opt in
  f) SOFTLINK=0 ;;
  s) SOFTLINK=1 ;;
  c) cleanse_tmux && exit 0 ;;
  h | ?) usage_me "install.sh" && exit 0 ;;
  esac
done

install_tmux
install_tpm
handle_tmux

info "Tmux installed successfully!"
