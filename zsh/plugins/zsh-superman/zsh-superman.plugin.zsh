#!/usr/bin/bash
# shellcheck disable=SC1090,SC2154

# Caesardev Zsh Plugin Loader
# Loads all utility scripts for the development environment
# Ensures all required files are sourced, with error checks

# Handle $0 according to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Define the files to load in order of dependency
local -a plugin_files=(
  "docker.zsh"       # Docker development utilities
  "git.zsh"          # Git utilities
  "superman.zsh"     # Superman utilities (decryption, etc.)
  "venv.zsh"         # Development environment setup
)

local plugin_dir="${0:h}"

for f in "${plugin_files[@]}"; do
  if [ -f "${plugin_dir}/$f" ]; then
    source "${plugin_dir}/$f"
  else
    echo "[caesardev.plugin.zsh] Warning: ${plugin_dir}/$f not found, skipping." >&2
  fi

done
