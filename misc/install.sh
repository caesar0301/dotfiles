#!/bin/bash
#############################################
# Install script for
# https://github.com/caesar0301/cool-dotfiles
# Maintainer: xiaming.chen
#############################################
THISDIR=$(dirname $(realpath $0))
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

source $THISDIR/../lib/shmisc.sh

function install_local_bins {
  create_dir $HOME/.local/bin
  cp $THISDIR/../bin/* $HOME/.local/bin
}

# auto completion of SBCL with rlwrap
function handle_rlwrap {
  if [ ! -e $HOME/.sbcl_completions ] || [ -L $HOME/.sbcl_completions ]; then
    install_file_pair "$THISDIR/../rlwrap/sbcl_completions" "$HOME/.sbcl_completions"
  else
    warn "$HOME/.sbcl_completions existed, skip without rewriting"
  fi
}

function handle_kitty {
  create_dir $XDG_CONFIG_HOME/kitty
  install_file_pair "$THISDIR/../kitty/kitty.conf" "$XDG_CONFIG_HOME/kitty/kitty.conf"
}

function cleanse_kitty {
  rm -rf $XDG_CONFIG_HOME/kitty/kitty.conf
  info "kitty cleansed!"
}

function cleanse_all {
  for i in $(ls $THISDIR/../bin/); do
    bname=$(basename $i)
    if [ -e $HOME/.local/bin/$bname ]; then
      rm -f $HOME/.local/bin/$bname
    fi
  done
  rm -rf $HOME/.sbcl_completions
  cleanse_kitty
  info "All cleansed!"
}

# Change to 0 to install a copy instead of soft link
LINK_INSTEAD_OF_COPY=1
while getopts fsech opt; do
  case $opt in
  f) LINK_INSTEAD_OF_COPY=0 ;;
  s) LINK_INSTEAD_OF_COPY=1 ;;
  c) cleanse_all && exit 0 ;;
  h | ?) usage_me "install.sh" && exit 0 ;;
  esac
done

install_local_bins
handle_rlwrap
handle_kitty

info "Misc installed successfully!"
