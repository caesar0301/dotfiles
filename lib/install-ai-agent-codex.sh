#!/bin/bash
###################################################
# OpenAI Codex AI Agent Installer
#
# Installs OpenAI Codex CLI with custom configuration support
#
# Copyright (c) 2024, 2026 Xiaming Chen
# License: MIT
###################################################

usage() {
  cat <<EOF
OpenAI Codex AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --api-key KEY        Set OpenAI API key via login command
  --base-url URL       Set custom API base URL in config.toml
  --model MODEL        Set default model (default: gpt-4)
  -h, --help           Show this help message and exit

Examples:
  $(basename "$0")                              # Install with defaults
  $(basename "$0") --api-key sk-xxx            # Install and set API key
  $(basename "$0") --base-url https://xxx      # Use custom API endpoint
  $(basename "$0") --model gpt-4-turbo         # Set default model

Note: OpenAI Codex requires Node.js >= 20 and npm >= 20
      Configuration stored in ~/.codex/config.toml (TOML format)
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

# Install OpenAI Codex CLI
install_codex_cli() {
  info "Installing OpenAI Codex CLI..."

  if npm install -g @openai/codex; then
    success "OpenAI Codex CLI installed successfully"
    return 0
  else
    error "Failed to install OpenAI Codex CLI"
    return 1
  fi
}

# Configure Codex API key via login command
configure_api_key() {
  local api_key="$1"

  if [[ -z "$api_key" ]]; then
    return 0
  fi

  info "Setting OpenAI API key via codex login..."
  if echo "$api_key" | codex login --with-api-key; then
    success "API key configured successfully"
    return 0
  else
    warn "Failed to set API key via login command"
    return 1
  fi
}

# Configure Codex settings in config.toml
configure_codex_toml() {
  local base_url="$1"
  local model="$2"
  local config_file="$HOME/.codex/config.toml"

  # Create config directory if it doesn't exist
  mkdir -p "$HOME/.codex"

  # Build TOML config entries
  local toml_entries=""

  if [[ -n "$base_url" ]]; then
    toml_entries+="base_url = \"$base_url\"\n"
  fi

  if [[ -n "$model" ]]; then
    toml_entries+="model = \"$model\"\n"
  fi

  # Only write if we have settings to configure
  if [[ -n "$toml_entries" ]]; then
    info "Configuring Codex settings in $config_file..."

    # Check if config.toml exists
    if [[ -f "$config_file" ]]; then
      # Append to existing config
      echo -e "\n# Custom configuration added by installer\n$toml_entries" >>"$config_file"
      success "Configuration appended to $config_file"
    else
      # Create new config
      echo -e "# Codex Configuration\n$toml_entries" >"$config_file"
      success "Configuration created at $config_file"
    fi
  fi

  return 0
}

# Main installation function
main() {
  local api_key=""
  local base_url=""
  local model=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --api-key)
      api_key="$2"
      shift 2
      ;;
    --base-url)
      base_url="$2"
      shift 2
      ;;
    --model)
      model="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      usage
      exit 1
      ;;
    esac
  done

  info "Installing OpenAI Codex AI agent..."

  # Install Codex CLI
  install_codex_cli || exit 1

  # Configure API key if provided
  if [[ -n "$api_key" ]]; then
    configure_api_key "$api_key" || warn "API key configuration failed, you may need to set it manually"
  fi

  # Configure TOML settings (base_url and model)
  if [[ -n "$base_url" || -n "$model" ]]; then
    configure_codex_toml "$base_url" "$model"
  fi

  success "OpenAI Codex AI agent installation completed"
  echo ""
  info "Post-installation steps:"
  echo ""
  if [[ -z "$api_key" ]]; then
    info "1. Set your OpenAI API key:"
    echo "   echo YOUR_API_KEY | codex login --with-api-key"
    echo "   OR"
    echo "   export OPENAI_API_KEY=your_api_key && codex login --with-api-key"
    echo ""
  fi
  if [[ -z "$base_url" ]]; then
    info "2. (Optional) Set custom API base URL for proxies in ~/.codex/config.toml:"
    echo "   base_url = \"https://your-proxy.com/v1\""
    echo ""
  fi
  info "3. Start using Codex:"
  echo "   codex \"your prompt here\""
  echo "   codex exec \"your non-interactive prompt\""
  echo ""
  info "4. Check configuration and health:"
  echo "   codex doctor"
  echo ""
  info "Configuration stored in: ~/.codex/config.toml"
  echo ""
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
