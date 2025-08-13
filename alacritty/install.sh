#!/bin/bash
###################################################
# Install script for Alacritty
# https://github.com/caesar0301/cool-dotfiles
# Maintainer: xiaming.chen
###################################################
THISDIR=$(dirname "$(realpath "$0")")
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

# Load common utils
source "$THISDIR/../lib/shmisc.sh"

# Function to handle Alacritty configuration
function handle_alacritty {
  info "Installing Alacritty configuration..."
  create_dir "$XDG_CONFIG_HOME/alacritty"
  install_file_pair "$THISDIR/alacritty.toml" "$XDG_CONFIG_HOME/alacritty/alacritty.toml"

  # install alacritty themes
  if [ ! -e $XDG_CONFIG_HOME/alacritty/theme ]; then
    git clone https://github.com/alacritty/alacritty-theme $XDG_CONFIG_HOME/alacritty/themes
  else
    warn "$XDG_CONFIG_HOME/alacritty/theme already exists, skip"
  fi
}

# Function to cleanse Alacritty configuration
function cleanse_alacritty {
  rm -rf "$XDG_CONFIG_HOME/alacritty/alacritty.toml"
  info "Alacritty configuration cleansed!"
}

# Change to 0 to install a copy instead of soft link
LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_alacritty && exit 0 ;;
  h | ?) usage_me "install.sh" && exit 0 ;;
  esac
done

handle_alacritty

info "Alacritty configuration installed successfully!"
