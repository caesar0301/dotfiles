#!/bin/bash
###################################################
# Common Lisp Development Environment Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - Quicklisp package manager installation
# - Allegro CL Express Edition setup
# - Essential Common Lisp libraries
# - SBCL and development tool configuration
# - Enhanced error handling and validation
#
# Author: Xiaming Chen
# License: MIT
###################################################

# Enable strict mode for better error handling
set -euo pipefail

# Resolve script directory
THISDIR=$(dirname "$(realpath "$0")")

# Configuration constants
readonly QUICKLISP_HOME="$HOME/quicklisp"
readonly ACL_HOME="$XDG_DATA_HOME/acl"
readonly CLINIT_FILE="$HOME/.clinit.cl"
readonly SBCLRC_FILE="$HOME/.sbclrc"

# Default Lisp libraries to install
readonly DEFAULT_LISP_LIBS=(
  "quicklisp-slime-helper"
  "alexandria"
  "split-sequence"
  "cl-ppcre"
)

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Check Common Lisp implementation availability
check_lisp_implementation() {
  local found_impl=""
  
  if checkcmd sbcl; then
    found_impl="SBCL $(sbcl --version 2>/dev/null | head -1 || echo 'unknown version')"
  elif checkcmd ccl; then
    found_impl="Clozure CL $(ccl --version 2>/dev/null | head -1 || echo 'unknown version')"
  elif checkcmd clisp; then
    found_impl="CLISP $(clisp --version 2>/dev/null | head -1 || echo 'unknown version')"
  fi
  
  if [[ -z "$found_impl" ]]; then
    error "No Common Lisp implementation found. Please install one of:"
    error "  - SBCL (recommended): https://www.sbcl.org/"
    error "  - Clozure CL: https://ccl.clozure.com/"
    error "  - CLISP: https://clisp.sourceforge.io/"
  fi
  
  info "Found Common Lisp implementation: $found_impl"
}

# Install Quicklisp package manager with enhanced validation
install_quicklisp() {
  info "Installing Quicklisp package manager..."
  
  # Check if already installed
  if [[ -f "$QUICKLISP_HOME/setup.lisp" ]]; then
    info "Quicklisp already installed at $QUICKLISP_HOME"
    
    # Check for updates
    if checkcmd sbcl; then
      info "Checking for Quicklisp updates..."
      sbcl --load "$QUICKLISP_HOME/setup.lisp" \
           --eval '(ql:update-dist "quicklisp")' \
           --quit 2>/dev/null || warn "Failed to check for updates"
    fi
    return 0
  fi
  
  # Download Quicklisp installer
  local quicklisp_setup
  quicklisp_setup=$(get_temp_dir)/quicklisp.lisp
  
  info "Downloading Quicklisp installer..."
  download_file "https://beta.quicklisp.org/quicklisp.lisp" "$quicklisp_setup"
  
  # Install Quicklisp
  info "Installing Quicklisp (this may take a few minutes)..."
  if sbcl --load "$quicklisp_setup" \
          --eval '(quicklisp-quickstart:install)' \
          --eval '(ql:add-to-init-file)' \
          --quit; then
    success "Quicklisp installed successfully"
    info "Quicklisp home: $QUICKLISP_HOME"
  else
    error "Failed to install Quicklisp"
  fi
}

# Install essential Common Lisp libraries
install_essential_libraries() {
  [[ -f "$QUICKLISP_HOME/setup.lisp" ]] || {
    error "Quicklisp not installed. Cannot install libraries."
  }
  
  info "Installing essential Common Lisp libraries..."
  
  # Create library installation script
  local install_script
  install_script=$(get_temp_dir)/install-libs.lisp
  
  cat > "$install_script" << 'EOF'
(load "~/quicklisp/setup.lisp")
(handler-case
  (progn
    (format t "Installing libraries...~%")
    (ql:quickload '(quicklisp-slime-helper alexandria split-sequence cl-ppcre))
    (format t "All libraries installed successfully!~%"))
  (error (e)
    (format t "Error installing libraries: ~A~%" e)
    (sb-ext:exit :code 1)))
(sb-ext:exit :code 0)
EOF
  
  # Install libraries
  if sbcl --script "$install_script"; then
    success "Essential libraries installed successfully"
    info "Installed libraries: ${DEFAULT_LISP_LIBS[*]}"
  else
    warn "Some libraries may have failed to install"
    warn "You can install them manually later using: (ql:quickload 'library-name)"
  fi
}

# Install Allegro CL Express Edition (optional)
install_allegro_cl() {
  info "Checking Allegro CL installation..."
  
  # Check if already installed
  if [[ -x "$ACL_HOME/alisp" ]]; then
    info "Allegro CL already installed at $ACL_HOME"
    return 0
  fi
  
  # This is an optional installation
  warn "Allegro CL Express Edition installation is optional and requires manual download"
  warn "To install Allegro CL:"
  warn "  1. Visit: https://franz.com/downloads/clp/download"
  warn "  2. Download the appropriate version for your system"
  
  if is_linux; then
    warn "  3. For Linux, extract to: $ACL_HOME"
  elif is_macos; then
    warn "  3. For macOS, mount the DMG and copy contents to: $ACL_HOME"
  fi
  
  warn "  4. Add $ACL_HOME to your PATH"
  warn "Skipping automatic Allegro CL installation"
  
  return 0
}

# Install Common Lisp configuration files
handle_lisp_config() {
  info "Installing Common Lisp configuration files..."
  
  local config_files=(
    "dot-clinit.cl:$CLINIT_FILE"
    "dot-sbclrc:$SBCLRC_FILE"
  )
  
  local installed_count=0
  for config_pair in "${config_files[@]}"; do
    local src_file="${config_pair%:*}"
    local dest_file="${config_pair#*:}"
    local src_path="$THISDIR/$src_file"
    
    if [[ -f "$src_path" ]]; then
      install_file_pair "$src_path" "$dest_file"
      ((installed_count++))
    else
      warn "Configuration file not found: $src_path"
    fi
  done
  
  if [[ $installed_count -gt 0 ]]; then
    success "Common Lisp configuration installed ($installed_count files)"
  else
    warn "No configuration files were installed"
  fi
}

# Remove Common Lisp configuration
cleanse_lisp() {
  info "Cleansing Common Lisp configuration..."
  
  local items_to_remove=(
    "$CLINIT_FILE"
    "$SBCLRC_FILE"
    "$QUICKLISP_HOME"
    "$ACL_HOME"
  )
  
  local removed_count=0
  for item in "${items_to_remove[@]}"; do
    if [[ -e "$item" ]]; then
      rm -rf "$item"
      info "Removed: $(basename "$item")"
      ((removed_count++))
    fi
  done
  
  if [[ $removed_count -gt 0 ]]; then
    success "Common Lisp configuration cleansed ($removed_count items removed)"
  else
    info "No Common Lisp configuration found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsch opt; do
  case $opt in
    f) LINK_INSTEAD_OF_COPY=0 ;;
    s) LINK_INSTEAD_OF_COPY=1 ;;
    c) cleanse_lisp && exit 0 ;;
    h|?) usage_me "install.sh" && exit 0 ;;
  esac
done

# Main installation sequence
main() {
  info "Starting Common Lisp development environment setup..."
  
  # Check prerequisites
  check_lisp_implementation
  
  # Installation steps
  install_quicklisp
  install_essential_libraries
  install_allegro_cl
  handle_lisp_config
  
  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "Quicklisp home: $QUICKLISP_HOME"
  info "Configuration files: $CLINIT_FILE, $SBCLRC_FILE"
  
  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Start SBCL: %bsbcl%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Load libraries: %b(ql:quickload 'library-name)%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. For Emacs integration, install SLIME\n"
  
  success "Common Lisp development environment setup completed successfully!"
}

# Execute main function
main
