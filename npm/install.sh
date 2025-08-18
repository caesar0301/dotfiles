#!/bin/bash
###################################################
# NPM Configuration Installation
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - NPM configuration with optimized settings
# - Global package directory setup
# - Registry and cache configuration
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
readonly NPM_GLOBAL_DIR="$HOME/.npm-global"
readonly NPMRC_FILE="$HOME/.npmrc"

# Load common utilities with validation
source "$THISDIR/../lib/shmisc.sh" || {
  printf "\033[0;31m✗ Failed to load shmisc.sh\033[0m\n" >&2
  exit 1
}

# Check NPM availability and version
check_npm_binary() {
  if ! checkcmd npm; then
    warn "NPM not found in PATH"
    warn "Please install Node.js and NPM first:"
    
    if is_linux; then
      warn "  Via package manager or from: https://nodejs.org/"
      warn "  Or install via nvm (Node Version Manager)"
    elif is_macos; then
      warn "  macOS: brew install node"
      warn "  Or download from: https://nodejs.org/"
    fi
    
    warn "Skipping NPM configuration installation"
    exit 0
  fi
  
  local npm_version node_version
  npm_version=$(npm --version 2>/dev/null || echo "unknown")
  node_version=$(node --version 2>/dev/null || echo "unknown")
  info "Found Node.js: $node_version, NPM: $npm_version"
}

# Install NPM configuration with validation
handle_npm_config() {
  info "Installing NPM configuration..."
  
  # Create global packages directory
  create_dir "$NPM_GLOBAL_DIR/lib"
  
  # Validate source .npmrc file exists
  local npmrc_source="$THISDIR/.npmrc"
  [[ -f "$npmrc_source" ]] || {
    error "NPM configuration file not found: $npmrc_source"
  }
  
  # Backup existing .npmrc if it exists and is not a symlink
  if [[ -f "$NPMRC_FILE" && ! -L "$NPMRC_FILE" ]]; then
    local backup_file="${NPMRC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    info "Creating backup of existing .npmrc: $backup_file"
    cp "$NPMRC_FILE" "$backup_file"
  fi
  
  # Install NPM configuration
  install_file_pair "$npmrc_source" "$NPMRC_FILE"
  
  # Verify configuration
  if npm config list >/dev/null 2>&1; then
    success "NPM configuration installed and validated"
    
    # Show key configuration values
    info "Key NPM settings:"
    printf "  Global directory: %s\n" "$(npm config get prefix 2>/dev/null || echo 'default')"
    printf "  Registry: %s\n" "$(npm config get registry 2>/dev/null || echo 'default')"
    printf "  Cache directory: %s\n" "$(npm config get cache 2>/dev/null || echo 'default')"
  else
    warn "NPM configuration may have issues, please check manually"
  fi
}

# Remove NPM configuration
cleanse_npm() {
  info "Cleansing NPM configuration..."
  
  local items_to_remove=(
    "$NPMRC_FILE"
    "${NPMRC_FILE}.backup."*
  )
  
  local removed_count=0
  for item_pattern in "${items_to_remove[@]}"; do
    # Handle glob patterns for backup files
    if [[ "$item_pattern" == *"*" ]]; then
      for file in $item_pattern 2>/dev/null; do
        [[ -f "$file" ]] || continue
        rm -f "$file"
        info "Removed: $(basename "$file")"
        ((removed_count++))
      done
    else
      if [[ -f "$item_pattern" ]]; then
        rm -f "$item_pattern"
        info "Removed: $(basename "$item_pattern")"
        ((removed_count++))
      fi
    fi
  done
  
  # Note: We don't remove .npm-global directory as it may contain installed packages
  if [[ -d "$NPM_GLOBAL_DIR" ]]; then
    warn "Global NPM directory preserved: $NPM_GLOBAL_DIR"
    warn "Remove manually if needed: rm -rf $NPM_GLOBAL_DIR"
  fi
  
  if [[ $removed_count -gt 0 ]]; then
    success "NPM configuration cleansed ($removed_count items removed)"
  else
    info "No NPM configuration found to remove"
  fi
}

# Process command line options
LINK_INSTEAD_OF_COPY=1
while getopts fsch opt; do
  case $opt in
    f) LINK_INSTEAD_OF_COPY=0 ;;
    s) LINK_INSTEAD_OF_COPY=1 ;;
    c) cleanse_npm && exit 0 ;;
    h|?) usage_me "install.sh" && exit 0 ;;
  esac
done

# Main installation sequence
main() {
  info "Starting NPM configuration installation..."
  
  # Check dependencies
  check_npm_binary
  
  # Install configuration
  handle_npm_config
  
  # Post-installation information
  printf "\n%b=== Installation Complete ===%b\n" "$COLOR_BOLD$COLOR_GREEN" "$COLOR_RESET"
  info "NPM configuration: $NPMRC_FILE"
  info "Global directory: $NPM_GLOBAL_DIR"
  
  printf "\n%bNext Steps:%b\n" "$COLOR_BOLD" "$COLOR_RESET"
  printf "  1. Verify configuration: %bnpm config list%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  2. Install global packages: %bnpm install -g <package>%b\n" "$COLOR_CYAN" "$COLOR_RESET"
  printf "  3. Add %b$NPM_GLOBAL_DIR/bin%b to your PATH if needed\n" "$COLOR_CYAN" "$COLOR_RESET"
  
  success "NPM configuration installation completed successfully!"
}

# Execute main function
main
