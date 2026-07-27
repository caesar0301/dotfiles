#!/bin/bash
###################################################
# Grok AI Agent Installer
#
# Installs Grok CLI from caesar0301/grok-build releases
# and configures a custom OpenAI-compatible endpoint
# (DashScope / Alibaba Cloud MaaS by default).
#
# Copyright (c) 2024, 2026 Xiaming Chen
# License: MIT
###################################################

set -euo pipefail

readonly GROK_GITHUB_OWNER="caesar0301"
readonly GROK_GITHUB_REPO="grok-build"
readonly GROK_INSTALL_DIR="${HOME}/.local/bin"
readonly GROK_CONFIG_DIR="${HOME}/.grok"
readonly DASHSCOPE_DEFAULT_MODEL="glm-5.2"
readonly DASHSCOPE_DEFAULT_BASE_URL="https://llm-0wh4qxgauf8u61nx.cn-beijing.maas.aliyuncs.com/compatible-mode/v1"

usage() {
  cat <<EOF
Grok AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --base-url URL       OpenAI-compatible base URL
                       (default: DASHSCOPE_BASE_URL env or MaaS URL)
  --model MODEL        Default model id (default: ${DASHSCOPE_DEFAULT_MODEL})
  --dashscope          Configure DashScope / custom OpenAI endpoint
  -h, --help           Show this help message and exit

Environment Variables (auto-detected for DashScope):
  DASHSCOPE_API_KEY    API key used via env_key in ~/.grok/config.toml
  DASHSCOPE_BASE_URL   OpenAI-compatible base URL written into config

Examples:
  $(basename "$0")                              # Install latest + auto DashScope if env set
  $(basename "$0") --dashscope                  # Install and write DashScope config
  $(basename "$0") --dashscope --model glm-5.2  # Set default model explicitly

Note: Binary is downloaded from:
  https://github.com/${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO}/releases
  Assets: grok-{macos|linux}-{x86_64|aarch64}
  Config: ~/.grok/config.toml (API key via DASHSCOPE_API_KEY, not stored in file)
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

# Map host OS/arch to grok-build release asset suffix
detect_grok_asset() {
  local os arch

  if is_macos; then
    os="macos"
  elif is_linux; then
    os="linux"
  else
    error "Unsupported operating system for grok: $(uname -s)"
  fi

  case "$(uname -m)" in
  x86_64 | amd64) arch="x86_64" ;;
  arm64 | aarch64) arch="aarch64" ;;
  *)
    error "Unsupported architecture for grok: $(uname -m)"
    ;;
  esac

  printf '%s' "grok-${os}-${arch}"
}

# Resolve latest release tag from GitHub API
# Writes only the tag to stdout (logging goes to stderr via info/error).
fetch_latest_grok_tag() {
  local api_url tag
  api_url="https://api.github.com/repos/${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO}/releases/latest"

  info "Fetching latest ${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO} release..." >&2
  tag=$(curl -fsSL "$api_url" | grep -o '"tag_name":[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)

  [[ -n "$tag" ]] || error "Failed to resolve latest grok release tag"
  printf '%s' "$tag"
}

# Verify downloaded binary against release SHA256SUMS when available
verify_grok_checksum() {
  local asset_name="$1"
  local binary_path="$2"
  local tag="$3"
  local sums_url sums_file expected actual

  sums_url="https://github.com/${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO}/releases/download/${tag}/SHA256SUMS"
  sums_file="$(dirname "$binary_path")/SHA256SUMS"

  if ! curl -fsSL "$sums_url" -o "$sums_file" 2>/dev/null; then
    warn "SHA256SUMS not available for ${tag}; skipping checksum verification"
    return 0
  fi

  expected=$(awk -v name="$asset_name" '$2 == name { print $1; exit }' "$sums_file")
  if [[ -z "$expected" ]]; then
    warn "No checksum entry for ${asset_name}; skipping verification"
    return 0
  fi

  if checkcmd shasum; then
    actual=$(shasum -a 256 "$binary_path" | awk '{ print $1 }')
  elif checkcmd sha256sum; then
    actual=$(sha256sum "$binary_path" | awk '{ print $1 }')
  else
    warn "No sha256 tool found; skipping checksum verification"
    return 0
  fi

  if [[ "$actual" != "$expected" ]]; then
    error "Checksum mismatch for ${asset_name}: expected ${expected}, got ${actual}"
  fi

  success "Checksum verified for ${asset_name}"
}

# Download latest grok binary for this platform into ~/.local/bin
install_grok_cli() {
  local asset_name tag download_url tmp_dir binary_path dest_path

  asset_name=$(detect_grok_asset)
  tag=$(fetch_latest_grok_tag)
  download_url="https://github.com/${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO}/releases/download/${tag}/${asset_name}"
  dest_path="${GROK_INSTALL_DIR}/grok"

  if checkcmd grok; then
    info "Grok already installed ($(command -v grok)); updating to ${tag} (${asset_name})..."
  else
    info "Installing Grok ${tag} (${asset_name})..."
  fi

  create_dir "$GROK_INSTALL_DIR"
  # get_temp_dir logs to stdout; use no-cleanup variant for clean path capture
  tmp_dir=$(get_temp_dir_no_cleanup)
  binary_path="${tmp_dir}/${asset_name}"

  # shellcheck disable=SC2064
  trap "rm -rf '$tmp_dir' 2>/dev/null || true" EXIT INT TERM

  download_file "$download_url" "$binary_path"
  verify_grok_checksum "$asset_name" "$binary_path" "$tag"

  install -m 755 "$binary_path" "$dest_path"
  export PATH="${GROK_INSTALL_DIR}:${PATH}"

  if checkcmd grok; then
    success "Grok ${tag} installed at ${dest_path}"
  else
    error "Grok installation verification failed (is ${GROK_INSTALL_DIR} on PATH?)"
  fi
}

# Write ~/.grok/config.toml for OpenAI-compatible / DashScope endpoint
configure_dashscope_grok() {
  local model="$1"
  local base_url="$2"
  local config_file="${GROK_CONFIG_DIR}/config.toml"

  mkdir -p "$GROK_CONFIG_DIR"

  info "Configuring Grok DashScope / OpenAI-compatible settings in ${config_file}..."

  cat >"$config_file" <<EOF
# Grok Configuration (DashScope / OpenAI-compatible endpoint)
# API key is read from DASHSCOPE_API_KEY (not stored in this file)

[cli]
auto_update = false

[models]
default = "${model}"

[endpoints]
models_base_url = "${base_url}"

[model.${model}]
model = "${model}"
base_url = "${base_url}"
name = "DashScope ${model}"
description = "DashScope OpenAI-compatible model"
env_key = "DASHSCOPE_API_KEY"
api_backend = "chat_completions"
EOF

  success "Grok configuration written to ${config_file}"
  info "Endpoint: ${base_url}"
  info "Default model: ${model}"

  if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
    warn "DASHSCOPE_API_KEY is not set; export it before running grok"
  else
    success "DASHSCOPE_API_KEY is set in the current environment"
  fi
}

main() {
  local use_dashscope=false
  local base_url=""
  local model=""

  while [[ $# -gt 0 ]]; do
    case $1 in
    --base-url)
      [[ $# -ge 2 ]] || error "--base-url requires a URL argument"
      base_url="$2"
      use_dashscope=true
      shift 2
      ;;
    --model)
      [[ $# -ge 2 ]] || error "--model requires a model id"
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
    base_url="${base_url:-${DASHSCOPE_BASE_URL:-${DASHSCOPE_DEFAULT_BASE_URL}}}"
    model="${model:-${DASHSCOPE_DEFAULT_MODEL}}"
    info "Using DashScope / OpenAI-compatible endpoint configuration"
  fi

  info "Installing Grok AI agent..."
  install_grok_cli

  if [[ "$use_dashscope" == true ]]; then
    configure_dashscope_grok "$model" "$base_url"
  else
    info "Skipping endpoint configuration (pass --dashscope or set DASHSCOPE_* env vars)"
  fi

  success "Grok AI agent installation completed"
  echo ""
  echo "Next steps:"
  echo "  export DASHSCOPE_API_KEY=sk-xxx"
  echo "  export DASHSCOPE_BASE_URL=${base_url:-${DASHSCOPE_DEFAULT_BASE_URL}}"
  echo "  grok"
  echo "  grok -p \"hello\" -m ${model:-${DASHSCOPE_DEFAULT_MODEL}}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
