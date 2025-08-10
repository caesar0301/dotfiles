#!/bin/bash
###################################################
# Install script for
# https://github.com/caesar0301/cool-dotfiles
# Maintainer: xiaming.chen
###################################################
THISDIR=$(dirname "$(realpath "$0")")

source "$THISDIR/../lib/shmisc.sh"

# Function to handle npm configuration
handle_npm() {
  create_dir $HOME/.npm-global/lib
  install_file_pair "$THISDIR/.npmrc" "$HOME/.npmrc"
}

# Function to cleanse npm configuration
cleanse_npm() {
  rm -rf "$HOME/.npmrc"
  info "All npm files cleansed!"
}

# Change to 0 to install a copy instead of soft link
LINK_INSTEAD_OF_COPY=1
while getopts fsch opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_npm && exit 0 ;;
  h | ?) usage_me "install.sh" && exit 0 ;;
  esac
done

handle_npm

info "npm configuration installed successfully!"
