#!/bin/bash
###################################################
# OpenAI Codex AI Agent Installer
#
# Installs OpenAI Codex CLI with custom configuration support
# Supports DashScope (Alibaba Cloud) Coding Plan via local bridge
#
# Copyright (c) 2024, 2026 Xiaming Chen
# License: MIT
###################################################

readonly CODEX_BRIDGE_HOST="127.0.0.1"
readonly CODEX_BRIDGE_PORT="31415"
readonly DASHSCOPE_DEFAULT_MODEL="glm-5"
readonly DASHSCOPE_DEFAULT_BASE_URL="https://coding.dashscope.aliyuncs.com/v1"

usage() {
  cat <<EOF
OpenAI Codex AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --api-key KEY        Set OpenAI API key via login command
  --base-url URL       DashScope upstream URL for the local bridge
                       (default: DASHSCOPE_BASE_URL env or Coding Plan URL)
  --model MODEL        Set default model (DashScope default: ${DASHSCOPE_DEFAULT_MODEL})
  --dashscope          Use DashScope (Alibaba Cloud) Coding Plan defaults
  -h, --help           Show this help message and exit

Environment Variables (auto-detected for DashScope):
  DASHSCOPE_API_KEY    DashScope Coding Plan API key (sk-sp-...)
  DASHSCOPE_BASE_URL   DashScope upstream base URL for the bridge

Examples:
  $(basename "$0")                              # Install with env defaults
  $(basename "$0") --dashscope                 # Use DashScope defaults
  $(basename "$0") --dashscope --model glm-5   # Set DashScope model explicitly
  $(basename "$0") --api-key sk-xxx            # Install OpenAI with API key

DashScope Configuration:
  export DASHSCOPE_API_KEY=sk-sp-xxx
  export DASHSCOPE_BASE_URL=https://coding.dashscope.aliyuncs.com/v1
  $(basename "$0") --dashscope

Note: OpenAI Codex requires Node.js >= 20 and npm >= 20
      DashScope uses aliyun-codex-bridge because Codex requires the Responses API
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

# Install Responses API bridge for DashScope Coding Plan
install_codex_bridge() {
  info "Installing aliyun-codex-bridge for DashScope Coding Plan..."
  npm_install_lib aliyun-codex-bridge
}

# Configure OpenAI API key via login command
configure_openai_api_key() {
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

# Preserve user-specific sections from an existing config.toml
preserve_codex_config_sections() {
  local config_file="$1"

  if [[ ! -f "$config_file" ]]; then
    return 0
  fi

  awk '
    /^\[projects\./ { capture = 1 }
    /^\[tui\./ { capture = 1 }
    capture { print }
  ' "$config_file"
}

# Configure Codex for DashScope via local Responses API bridge
configure_dashscope_codex() {
  local model="$1"
  local upstream_base_url="$2"
  local config_file="$HOME/.codex/config.toml"
  local bridge_base_url="http://${CODEX_BRIDGE_HOST}:${CODEX_BRIDGE_PORT}"
  local preserved=""

  mkdir -p "$HOME/.codex"
  preserved="$(preserve_codex_config_sections "$config_file")"

  info "Configuring DashScope Codex settings in $config_file..."

  cat >"$config_file" <<EOF
# Codex Configuration (DashScope Coding Plan via local bridge)
model = "${model}"
model_provider = "dashscope"

[model_providers.dashscope]
name = "DashScope (Alibaba Cloud)"
base_url = "${bridge_base_url}"
env_key = "DASHSCOPE_API_KEY"
wire_api = "responses"
stream_idle_timeout_ms = 3000000

EOF

  if [[ -n "$preserved" ]]; then
    printf '%s\n' "$preserved" >>"$config_file"
  fi

  success "DashScope configuration written to $config_file"
  info "Bridge upstream: ${upstream_base_url}"
  return 0
}

# Resolve the bridge server entrypoint (npm bin wrapper has a broken __dirname path)
codex_bridge_server_path() {
  local npm_root="${HOME}/.local/lib/node_modules"
  if command -v npm >/dev/null 2>&1; then
    npm_root="$(npm root -g 2>/dev/null || echo "$npm_root")"
  fi
  echo "${npm_root}/aliyun-codex-bridge/src/server.js"
}

# Start the local DashScope bridge if it is not already running
start_codex_bridge() {
  local upstream_base_url="$1"
  local health_url="http://${CODEX_BRIDGE_HOST}:${CODEX_BRIDGE_PORT}/health"
  local bridge_server=""

  if curl -fsS "$health_url" >/dev/null 2>&1; then
    info "aliyun-codex-bridge is already running at ${health_url}"
    return 0
  fi

  if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
    warn "DASHSCOPE_API_KEY is not set; bridge not started"
    return 1
  fi

  bridge_server="$(codex_bridge_server_path)"
  if [[ ! -f "$bridge_server" ]]; then
    warn "Bridge server not found at $bridge_server"
    return 1
  fi

  info "Starting aliyun-codex-bridge on ${CODEX_BRIDGE_HOST}:${CODEX_BRIDGE_PORT}..."

  HOST="${CODEX_BRIDGE_HOST}" \
    PORT="${CODEX_BRIDGE_PORT}" \
    AI_API_KEY="${DASHSCOPE_API_KEY}" \
    AI_API_BASE="${upstream_base_url}" \
    ALLOW_TOOLS=1 \
    nohup node "$bridge_server" >/dev/null 2>&1 &
  disown

  sleep 2

  if curl -fsS "$health_url" >/dev/null 2>&1; then
    success "aliyun-codex-bridge started successfully"
    return 0
  fi

  warn "Failed to start aliyun-codex-bridge; start it manually before using Codex"
  return 1
}

# Verify Codex can reach glm-5 through the configured provider
verify_codex_status() {
  local model="$1"

  info "Checking Codex health..."
  if codex doctor >/dev/null 2>&1; then
    success "codex doctor passed"
  else
    warn "codex doctor reported issues; run 'codex doctor' for details"
  fi

  if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
    warn "Skipping live model test because DASHSCOPE_API_KEY is not set"
    return 0
  fi

  info "Testing Codex with model ${model}..."
  local test_output=""
  test_output="$(codex exec -m "${model}" -s read-only --ephemeral "Reply with exactly: CODEX_OK" </dev/null 2>&1 || true)"
  if printf '%s\n' "$test_output" | grep -Fxq 'CODEX_OK'; then
    success "Codex model ${model} is responding"
    return 0
  fi

  warn "Codex model ${model} test did not return CODEX_OK; check bridge and API key"
  return 1
}

# Main installation function
main() {
  local api_key=""
  local base_url=""
  local model=""
  local use_dashscope=false

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
    --dashscope)
      use_dashscope=true
      shift
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

  # Auto-detect DashScope when env vars are present
  if [[ "$use_dashscope" == true || -n "${DASHSCOPE_API_KEY:-}" || -n "${DASHSCOPE_BASE_URL:-}" ]]; then
    use_dashscope=true
    api_key="${api_key:-${DASHSCOPE_API_KEY:-}}"
    base_url="${base_url:-${DASHSCOPE_BASE_URL:-${DASHSCOPE_DEFAULT_BASE_URL}}}"
    model="${model:-${DASHSCOPE_DEFAULT_MODEL}}"
    info "Using DashScope (Alibaba Cloud) Coding Plan configuration"
  fi

  info "Installing OpenAI Codex AI agent..."

  install_codex_cli || exit 1

  if [[ "$use_dashscope" == true ]]; then
    install_codex_bridge || exit 1
    configure_dashscope_codex "$model" "$base_url"
    start_codex_bridge "$base_url" || true
    verify_codex_status "$model" || true
  elif [[ -n "$api_key" ]]; then
    configure_openai_api_key "$api_key" || warn "API key configuration failed, you may need to set it manually"
  fi

  success "OpenAI Codex AI agent installation completed"
  echo ""
  info "Post-installation steps:"
  echo ""

  if [[ "$use_dashscope" == true ]]; then
    info "1. Ensure your Coding Plan credentials are exported:"
    echo "   export DASHSCOPE_API_KEY=sk-sp-xxx"
    echo "   export DASHSCOPE_BASE_URL=${DASHSCOPE_DEFAULT_BASE_URL}"
    echo ""
    info "2. Start the local bridge before using Codex:"
    echo "   HOST=127.0.0.1 PORT=31415 AI_API_KEY=\"\$DASHSCOPE_API_KEY\" \\"
    echo "     AI_API_BASE=\"\${DASHSCOPE_BASE_URL:-${DASHSCOPE_DEFAULT_BASE_URL}}\" \\"
    echo "     node \"\$(npm root -g)/aliyun-codex-bridge/src/server.js\""
    echo ""
    info "3. Verify Codex health and model access:"
    echo "   codex doctor"
    echo "   codex exec -m ${model:-${DASHSCOPE_DEFAULT_MODEL}} \"your prompt here\""
    echo ""
    info "4. Default model/provider:"
    echo "   model = \"${model:-${DASHSCOPE_DEFAULT_MODEL}}\""
    echo "   provider = dashscope (via http://${CODEX_BRIDGE_HOST}:${CODEX_BRIDGE_PORT})"
    echo ""
  else
    if [[ -z "$api_key" ]]; then
      info "1. Set your OpenAI API key:"
      echo "   echo YOUR_API_KEY | codex login --with-api-key"
      echo ""
    else
      info "1. OpenAI API key configured via codex login"
      echo ""
    fi
    info "2. Start using Codex:"
    echo "   codex \"your prompt here\""
    echo "   codex exec \"your non-interactive prompt\""
    echo ""
    info "3. Check configuration and health:"
    echo "   codex doctor"
    echo ""
  fi

  info "Configuration stored in: ~/.codex/config.toml"
  echo ""
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
