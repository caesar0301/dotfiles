#!/bin/bash
###################################################
# Rust and Cargo Installer
# https://rustup.rs/
#
# Installs Rust and Cargo with kernel version compatibility check
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shmisc.sh"

# Main installation function
main() {
  # Check if cargo is already installed
  if checkcmd cargo; then
    info "Cargo already installed: $(cargo --version)"
    exit 0
  fi

  # Check kernel version for compatibility
  local kernel_version
  kernel_version=$(get_kernel_version)
  if is_linux && [[ $(echo "$kernel_version < 5.0" | bc -l 2>/dev/null || echo "1") == "1" ]]; then
    warn "Kernel version $kernel_version < 5.0, skipping Cargo installation for compatibility"
    exit 0
  fi

  info "Installing Rust and Cargo..."

  # Choose download method
  local download_cmd
  if checkcmd curl; then
    download_cmd="curl -sSf"
  elif checkcmd wget; then
    download_cmd="wget -qO-"
  else
    error "curl or wget is required to install Rust/Cargo"
  fi

  # Install rustup with non-interactive mode
  if $download_cmd https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
    success "Rust and Cargo installed successfully"

    # Source environment in current session
    # shellcheck disable=SC1090
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

    # Add to shell configuration if not present
    local shell_config
    shell_config=$(current_shell_config)
    if ! grep -q 'cargo/env' "$shell_config" 2>/dev/null; then
      info "Adding Cargo to shell configuration"
      echo '# Cargo configuration' >>"$shell_config"
      echo '[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"' >>"$shell_config"
    fi

    # Verify installation
    if checkcmd cargo; then
      info "Cargo verification successful: $(cargo --version)"
    else
      warn "Cargo installed but not available in current session. Please restart your shell."
    fi
  else
    error "Rust/Cargo installation failed"
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
