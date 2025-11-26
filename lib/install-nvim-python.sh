#!/bin/bash
###################################################
# Neovim Python Provider Setup
# https://github.com/caesar0301/cool-dotfiles
#
# Sets up a dedicated pyenv virtualenv for Neovim
# to avoid conflicts with other Python projects.
#
# This script:
# 1. Creates a pyenv virtualenv named 'neovim'
# 2. Installs/updates pynvim to the latest version
# 3. Sets up the environment for optimal Neovim usage
#
# Maintainer: xiaming.chen
###################################################

set -euo pipefail

# Resolve script location
THISDIR=$(dirname "$(realpath "$0")")

# Load common utilities
source "$THISDIR/shmisc.sh" || {
  echo "Error: Failed to load shmisc.sh"
  exit 1
}

# Configuration
readonly NVIM_VENV_NAME="neovim"
readonly DEFAULT_PYTHON_VERSION="3.11"
readonly PYNVIM_PACKAGE="pynvim"

# Function to detect available Python version
detect_python_version() {
  local pyenv_root detected_version

  # Try to get pyenv root
  if [[ -n "${PYENV_ROOT:-}" ]]; then
    pyenv_root="$PYENV_ROOT"
  else
    pyenv_root="$HOME/.pyenv"
  fi

  # Check if pyenv is available and initialized
  if command -v pyenv &>/dev/null; then
    # Try to get the global or local Python version
    detected_version=$(pyenv version-name 2>/dev/null || echo "")
    if [[ -n "$detected_version" && "$detected_version" != "system" ]]; then
      # Extract just the version number (remove virtualenv suffix)
      detected_version=$(echo "$detected_version" | cut -d'/' -f1)
      printf "%s" "$detected_version"
      return 0
    fi

    # Try to find the latest installed 3.11.x version
    if [[ -d "$pyenv_root/versions" ]]; then
      detected_version=$(ls -1 "$pyenv_root/versions" 2>/dev/null | grep "^3\.11\." | sort -V | tail -1 || echo "")
      if [[ -n "$detected_version" ]]; then
        printf "%s" "$detected_version"
        return 0
      fi
    fi
  fi

  # Fallback to default
  printf "%s" "$DEFAULT_PYTHON_VERSION"
}

# Detect Python version to use
PYTHON_VERSION=$(detect_python_version)

# Function to check if pyenv is available
check_pyenv() {
  if ! checkcmd pyenv; then
    error "pyenv is not installed. Please install pyenv first."
    info "You can install it using: $THISDIR/install-pyenv.sh"
    return 1
  fi
  return 0
}

# Function to get pyenv root
get_pyenv_root() {
  local pyenv_root
  if [[ -n "${PYENV_ROOT:-}" ]]; then
    pyenv_root="$PYENV_ROOT"
  else
    pyenv_root="$HOME/.pyenv"
  fi

  if [[ ! -d "$pyenv_root" ]]; then
    error "pyenv root directory not found: $pyenv_root"
    return 1
  fi

  printf "%s" "$pyenv_root"
}

# Function to check if Python version is installed
check_python_version() {
  local version=$1
  local pyenv_root
  pyenv_root=$(get_pyenv_root)

  if [[ -d "$pyenv_root/versions/$version" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to install Python version if not present
install_python_version() {
  local version=$1

  if check_python_version "$version"; then
    info "Python $version is already installed"
    return 0
  fi

  info "Installing Python $version with pyenv..."
  if pyenv install "$version"; then
    success "Successfully installed Python $version"
    return 0
  else
    error "Failed to install Python $version"
    return 1
  fi
}

# Function to check if virtualenv exists
check_virtualenv() {
  local venv_name=$1
  local pyenv_root
  pyenv_root=$(get_pyenv_root)

  if [[ -d "$pyenv_root/versions/$venv_name" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to create virtualenv
create_virtualenv() {
  local venv_name=$1
  local python_version=$2
  local pyenv_root
  pyenv_root=$(get_pyenv_root)

  if check_virtualenv "$venv_name"; then
    info "Virtualenv '$venv_name' already exists"
    return 0
  fi

  info "Creating virtualenv '$venv_name' with Python $python_version..."
  if pyenv virtualenv "$python_version" "$venv_name"; then
    success "Successfully created virtualenv '$venv_name'"
    return 0
  else
    error "Failed to create virtualenv '$venv_name'"
    return 1
  fi
}

# Function to get virtualenv Python path
get_venv_python_path() {
  local venv_name=$1
  local pyenv_root
  pyenv_root=$(get_pyenv_root)
  printf "%s" "$pyenv_root/versions/$venv_name/bin/python3"
}

# Function to install/update pynvim
install_pynvim() {
  local venv_name=$1
  local pyenv_root python_path
  pyenv_root=$(get_pyenv_root)
  python_path=$(get_venv_python_path "$venv_name")

  if [[ ! -f "$python_path" ]]; then
    error "Python executable not found: $python_path"
    return 1
  fi

  info "Installing/updating $PYNVIM_PACKAGE in virtualenv '$venv_name'..."

  # Use the virtualenv's pip to install pynvim
  if "$python_path" -m pip install --upgrade "$PYNVIM_PACKAGE" --quiet; then
    # Verify installation
    local pynvim_version
    pynvim_version=$("$python_path" -m pip show "$PYNVIM_PACKAGE" 2>/dev/null | grep "^Version:" | awk '{print $2}' || echo "unknown")
    success "Successfully installed/updated $PYNVIM_PACKAGE (version: $pynvim_version)"
    return 0
  else
    error "Failed to install/update $PYNVIM_PACKAGE"
    return 1
  fi
}

# Function to display setup information
display_setup_info() {
  local venv_name=$1
  local python_path
  python_path=$(get_venv_python_path "$venv_name")

  info "================================================"
  info "Neovim Python Provider Setup Complete"
  info "================================================"
  info "Virtualenv: $venv_name"
  info "Python path: $python_path"
  info ""
  info "To use this Python provider, set the following in your shell:"
  info "  export NVIM_PYTHON3=\"$(dirname "$(dirname "$python_path")")\""
  info ""
  info "Or add it to your shell configuration file:"
  info "  echo 'export NVIM_PYTHON3=\"$(dirname "$(dirname "$python_path")")\"' >> ~/.$(basename "$(current_shell_config)")"
  info ""
  info "The Neovim configuration will auto-detect this if NVIM_PYTHON3 is set."
  info "================================================"
}

# Main setup function
setup_nvim_python() {
  info "Setting up Neovim Python provider..."
  info "Detected Python version: $PYTHON_VERSION"

  # Check pyenv
  if ! check_pyenv; then
    return 1
  fi

  # Initialize pyenv (if not already in PATH)
  if ! command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
  fi

  # Install Python version if needed
  if ! install_python_version "$PYTHON_VERSION"; then
    error "Failed to install Python $PYTHON_VERSION"
    return 1
  fi

  # Create virtualenv if needed
  if ! create_virtualenv "$NVIM_VENV_NAME" "$PYTHON_VERSION"; then
    error "Failed to create virtualenv"
    return 1
  fi

  # Install/update pynvim
  if ! install_pynvim "$NVIM_VENV_NAME"; then
    error "Failed to install pynvim"
    return 1
  fi

  # Display setup information
  display_setup_info "$NVIM_VENV_NAME"

  success "Neovim Python provider setup completed successfully!"
  return 0
}

# Run setup
setup_nvim_python
