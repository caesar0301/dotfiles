#!/bin/bash
# Format shell scripts with shfmt, excluding zsh-specific files
# Zsh files use syntax that shfmt doesn't support (e.g., glob qualifiers, zsh parameter expansion)

# Find and format shell scripts, excluding zsh files
find . -type f \( -name "*.sh" -o -name "*.bash" \) \
  ! -path "*/zsh/*" \
  ! -path "*/.git/*" \
  ! -path "*/node_modules/*" \
  ! -name "*.zsh" \
  -exec shfmt -w -i 2 {} +

# Format Lua files for Neovim
stylua nvim
