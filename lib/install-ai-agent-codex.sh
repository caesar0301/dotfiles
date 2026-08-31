#!/bin/bash
###################################################
# OpenAI Codex AI Agent Installer
#
# Installs OpenAI Codex CLI and configures a custom OpenAI-compatible
# endpoint (DashScope / Alibaba Cloud MaaS by default).
#
# DashScope MaaS now supports the Responses API (/responses) directly,
# so no local bridge (aliyun-codex-bridge) is required anymore.
# Configuration is written from the bundled template (lib/codex-config.toml)
# into ~/.codex/config.toml.
#
# Copyright (c) 2024, 2026 Xiaming Chen
# License: MIT
###################################################

readonly CODEX_CONFIG_DIR="${HOME}/.codex"
readonly CODEX_DEFAULT_MODEL="glm-5.2"

usage() {
  cat <<EOF
OpenAI Codex AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --dashscope          Install DashScope config from bundled template
                       (lib/codex-config.toml) into ~/.codex/config.toml
  --api-key KEY        Set OpenAI API key via codex login (non-DashScope)
  -h, --help           Show this help message and exit

Environment Variables (auto-detected for DashScope):
  DASHSCOPE_API_KEY    API key used via env_key in ~/.codex/config.toml
  DASHSCOPE_BASE_URL   DashScope MaaS base URL; substituted into the template
                       at install time (Codex does not interpolate \${VAR} in base_url)

Examples:
  $(basename "$0")                              # Install binary + auto config if env set
  $(basename "$0") --dashscope                  # Install binary and write DashScope config
  $(basename "$0") --api-key sk-xxx             # Install with OpenAI API key (no DashScope)

Note: Codex CLI is installed via npm: npm install -g @openai/codex
      Requires Node.js >= 20 and npm >= 20.
      Config: ~/.codex/config.toml installed from lib/codex-config.toml template
              (API key via DASHSCOPE_API_KEY env var, not stored in file)
              Existing config is preserved; re-running will not overwrite it.
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shlib.sh
source "$SCRIPT_DIR/shlib.sh"

# Install OpenAI Codex CLI via npm
install_codex_cli() {
  info "Installing OpenAI Codex CLI..."

  checkcmd npm || error "npm is not installed or not in PATH (requires Node.js >= 20)"

  if npm install -g @openai/codex; then
    success "OpenAI Codex CLI installed successfully"
    return 0
  else
    error "Failed to install OpenAI Codex CLI"
    return 1
  fi
}

# Preserve user-specific sections from an existing config.toml.
# Captures [projects.*] and [tui.*] tables so they survive rewrites.
preserve_codex_config_sections() {
  local config_file="$1"

  [[ -f "$config_file" ]] || return 0

  awk '
    /^\[projects\./ { capture = 1 }
    /^\[tui\./ { capture = 1 }
    capture { print }
  ' "$config_file"
}

# Install ~/.codex/config.toml from the bundled template.
#
# The template (lib/codex-config.toml) is the source of truth: it carries
# the full DashScope model catalog with ${DASHSCOPE_BASE_URL} placeholders.
# Codex does NOT interpolate ${VAR} in base_url at runtime, so we substitute
# it with the actual URL here. An existing config is preserved (never
# overwritten) so user edits survive re-runs; only [projects.*] and [tui.*]
# sections are merged into the fresh template on re-install.
configure_dashscope_codex() {
  local config_file="${CODEX_CONFIG_DIR}/config.toml"
  local template_file="${SCRIPT_DIR}/codex-config.toml"
  local base_url="${DASHSCOPE_BASE_URL:-}"
  local preserved=""

  create_dir "${CODEX_CONFIG_DIR}"

  [[ -e "${template_file}" ]] || error "Codex config template not found: ${template_file}"

  # Preserve user sections from existing config before rewriting
  if [[ -e "${config_file}" ]]; then
    info "Existing Codex config found at ${config_file}; preserving user sections"
    preserved="$(preserve_codex_config_sections "${config_file}")"
  fi

  info "Installing Codex config template to ${config_file}..."

  if [[ -n "${base_url}" ]]; then
    # Substitute ${DASHSCOPE_BASE_URL} placeholder with the actual URL.
    # Codex does not interpolate env vars in base_url at runtime.
    sed "s|\${DASHSCOPE_BASE_URL}|${base_url}|g" "${template_file}" >"${config_file}"
  else
    # No DASHSCOPE_BASE_URL env var — copy template as-is so the user can
    # fill in the URL manually (the placeholder makes it obvious).
    install -m 644 "${template_file}" "${config_file}"
    warn "DASHSCOPE_BASE_URL is not set; edit \${DASHSCOPE_BASE_URL} in ${config_file} manually"
  fi
  chmod 644 "${config_file}"

  # Append preserved [projects.*] and [tui.*] sections
  if [[ -n "${preserved}" ]]; then
    printf '\n' >>"${config_file}"
    printf '%s\n' "${preserved}" >>"${config_file}"
  fi

  success "Codex configuration installed to ${config_file}"
  info "Default model: ${CODEX_DEFAULT_MODEL} (edit ${config_file} to change)"
  info "Available models: glm-5.2, qwen3.7-plus, qwen3.6-flash, kimi-k2.5, MiniMax-M3"
  info "API key is read from DASHSCOPE_API_KEY at runtime (not stored in file)"

  if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
    warn "DASHSCOPE_API_KEY is not set; export it before running codex"
  else
    success "DASHSCOPE_API_KEY is set in the current environment"
  fi
}

# Configure OpenAI API key via login command (non-DashScope path)
configure_openai_api_key() {
  local api_key="$1"

  [[ -z "$api_key" ]] && return 0

  info "Setting OpenAI API key via codex login..."
  if echo "$api_key" | codex login --with-api-key; then
    success "API key configured successfully"
    return 0
  else
    warn "Failed to set API key via login command"
    return 1
  fi
}

# Verify Codex can reach the configured model
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

  warn "Codex model ${model} test did not return CODEX_OK; check config and API key"
  return 1
}

# Main installation function
main() {
  local api_key=""
  local use_dashscope=false

  while [[ $# -gt 0 ]]; do
    case $1 in
    --dashscope)
      use_dashscope=true
      shift
      ;;
    --api-key)
      api_key="$2"
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

  # Auto-detect DashScope when env vars are present
  if [[ "$use_dashscope" == true || -n "${DASHSCOPE_API_KEY:-}" || -n "${DASHSCOPE_BASE_URL:-}" ]]; then
    use_dashscope=true
    info "Using DashScope (Alibaba Cloud MaaS) configuration"
  fi

  info "Installing OpenAI Codex AI agent..."

  install_codex_cli || exit 1

  if [[ "$use_dashscope" == true ]]; then
    configure_dashscope_codex
    verify_codex_status "${CODEX_DEFAULT_MODEL}" || true
  elif [[ -n "$api_key" ]]; then
    configure_openai_api_key "$api_key" || warn "API key configuration failed, you may need to set it manually"
  fi

  success "OpenAI Codex AI agent installation completed"
  echo ""
  info "Post-installation steps:"
  echo ""

  if [[ "$use_dashscope" == true ]]; then
    info "1. Ensure your DashScope credentials are exported:"
    echo "   export DASHSCOPE_API_KEY=sk-xxx"
    echo "   export DASHSCOPE_BASE_URL=https://your-dashscope-maas-endpoint/compatible-mode/v1"
    echo ""
    info "2. Start using Codex:"
    echo "   codex \"your prompt here\""
    echo "   codex exec \"non-interactive prompt\""
    echo ""
    info "3. Check configuration and health:"
    echo "   codex doctor"
    echo ""
    info "4. Default model/provider:"
    echo "   model = \"${CODEX_DEFAULT_MODEL}\""
    echo "   provider = dashscope (direct Responses API, no bridge needed)"
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
    echo "   codex exec \"non-interactive prompt\""
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
