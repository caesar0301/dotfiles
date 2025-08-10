#!/bin/bash
#############################################
# Install script for
# https://github.com/caesar0301/cool-dotfiles
# Maintainer: xiaming.chen
#############################################
THISDIR=$(dirname $(realpath $0))
source $THISDIR/lib/shmisc.sh

components=(alacritty tmux zsh nvim vifm emacs npm misc)
components+=(lisp rlwrap)

for key in "${components[@]}"; do
  info "➜ START INSTALLING $key"
  sh $THISDIR/$key/install.sh $@
  if [ $? -eq 0 ]; then
    info "✔ FINISH INSTALLING $key"
  else
    error "✖ ERROR INSTALLING $key"
  fi
done

info "🎉 All installed successfully!"
