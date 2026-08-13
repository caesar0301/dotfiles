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
readonly GROK_INSTALL_DIR="${HOME}/.grok/bin"
readonly GROK_CONFIG_DIR="${HOME}/.grok"
readonly DASHSCOPE_DEFAULT_MODEL="glm-5.2"

usage() {
  cat <<EOF
Grok AI Agent Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --dashscope          Install DashScope config from bundled template
                       (lib/grok-config.toml) into ~/.grok/config.toml
  -h, --help           Show this help message and exit

Environment Variables (auto-detected for DashScope):
  DASHSCOPE_API_KEY    API key used via env_key in ~/.grok/config.toml

Examples:
  $(basename "$0")                              # Install binary + auto config if env set
  $(basename "$0") --dashscope                  # Install binary and write DashScope config

Note: Binary is downloaded from:
  https://github.com/${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO}/releases
  Assets: grok-{macos|linux}-{x86_64|aarch64}
  Config: ~/.grok/config.toml installed from lib/grok-config.toml template
          (API key via DASHSCOPE_API_KEY env var, not stored in file)
          Existing config is preserved; re-running will not overwrite it.
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shlib.sh
source "${SCRIPT_DIR}/shlib.sh"

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

# Resolve latest release tag WITHOUT the GitHub REST API.
#
# The REST API (api.github.com) rejects headerless / high-volume unauthenticated
# requests with HTTP 403 and limits them to 60/hour per IP. Instead we hit the
# public "releases/latest" HTML page, which 302-redirects to
# ".../releases/tag/<tag>"; we read the tag off the redirect. This path is not
# rate-limited and requires no token.
#
# Writes only the tag to stdout (logging goes to stderr via info/error).
fetch_latest_grok_tag() {
  local releases_url final_url tag

  releases_url="https://github.com/${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO}/releases/latest"

  info "Resolving latest ${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO} release..." >&2

  # -o /dev/null: discard body; -w "%{url_effective}": print final URL after redirects
  final_url=$(curl -fsSL -o /dev/null -w '%{url_effective}' "${releases_url}") ||
    error "Failed to resolve latest grok release (redirect from ${releases_url})"

  # final_url looks like: https://github.com/<owner>/<repo>/releases/tag/<tag>
  tag="${final_url##*/}"
  [[ -n "${tag}" && "${tag}" != "${final_url}" ]] ||
    error "Could not parse tag from redirect URL: ${final_url}"

  printf '%s' "${tag}"
}

# Verify downloaded binary against release SHA256SUMS when available
verify_grok_checksum() {
  local asset_name="$1"
  local binary_path="$2"
  local tag="$3"
  local sums_url sums_file expected actual

  sums_url="https://github.com/${GROK_GITHUB_OWNER}/${GROK_GITHUB_REPO}/releases/download/${tag}/SHA256SUMS"
  sums_file="$(dirname "${binary_path}")/SHA256SUMS"

  if ! curl -fsSL "${sums_url}" -o "${sums_file}" 2>/dev/null; then
    warn "SHA256SUMS not available for ${tag}; skipping checksum verification"
    return 0
  fi

  expected=$(awk -v name="${asset_name}" '$2 == name { print $1; exit }' "${sums_file}")
  if [[ -z "${expected}" ]]; then
    warn "No checksum entry for ${asset_name}; skipping verification"
    return 0
  fi

  if checkcmd shasum; then
    actual=$(shasum -a 256 "${binary_path}" | awk '{ print $1 }')
  elif checkcmd sha256sum; then
    actual=$(sha256sum "${binary_path}" | awk '{ print $1 }')
  else
    warn "No sha256 tool found; skipping checksum verification"
    return 0
  fi

  if [[ "${actual}" != "${expected}" ]]; then
    error "Checksum mismatch for ${asset_name}: expected ${expected}, got ${actual}"
  fi

  success "Checksum verified for ${asset_name}"
}

# Download latest grok binary for this platform into ~/.grok/bin
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

  create_dir "${GROK_INSTALL_DIR}"
  # get_temp_dir logs to stdout; use no-cleanup variant for clean path capture
  tmp_dir=$(get_temp_dir_no_cleanup)
  binary_path="${tmp_dir}/${asset_name}"

  # shellcheck disable=SC2064
  trap "rm -rf '${tmp_dir}' 2>/dev/null || true" EXIT INT TERM

  download_file "${download_url}" "${binary_path}"
  verify_grok_checksum "${asset_name}" "${binary_path}" "${tag}"

  # Remove any existing destination (including symlinks created by grok's
  # own self-update) so `install` writes a real binary file, not a symlink.
  rm -f "${dest_path}"
  install -m 755 "${binary_path}" "${dest_path}"
  export PATH="${GROK_INSTALL_DIR}:${PATH}"

  if checkcmd grok; then
    success "Grok ${tag} installed at ${dest_path}"
  else
    error "Grok installation verification failed (is ${GROK_INSTALL_DIR} on PATH?)"
  fi
}

# Install ~/.grok/config.toml from the bundled template.
#
# The template (lib/grok-config.toml) is the source of truth: it carries the
# full DashScope model catalog and baked-in base_url values. An existing config
# is preserved (never overwritten) so user edits survive re-runs.
configure_dashscope_grok() {
  local config_file="${GROK_CONFIG_DIR}/config.toml"
  local template_file="${SCRIPT_DIR}/grok-config.toml"

  create_dir "${GROK_CONFIG_DIR}"

  if [[ -e "${config_file}" ]]; then
    info "Existing Grok config found at ${config_file}; preserving (not overwritten)"
    if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
      warn "DASHSCOPE_API_KEY is not set; export it before running grok"
    fi
    return 0
  fi

  [[ -e "${template_file}" ]] || error "Grok config template not found: ${template_file}"

  info "Installing Grok config template to ${config_file}..."
  install -m 644 "${template_file}" "${config_file}"

  success "Grok configuration installed to ${config_file}"
  info "Default model: glm-5.2 (edit ${config_file} to change)"
  info "API key is read from DASHSCOPE_API_KEY at runtime (not stored in file)"

  if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
    warn "DASHSCOPE_API_KEY is not set; export it before running grok"
  else
    success "DASHSCOPE_API_KEY is set in the current environment"
  fi
}

main() {
  local use_dashscope=false

  while [[ $# -gt 0 ]]; do
    case $1 in
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
      # shellcheck disable=SC2317
      usage
      # shellcheck disable=SC2317
      exit 1
      ;;
    esac
  done

  # Auto-detect DashScope when env vars are present
  if [[ "${use_dashscope}" == true || -n "${DASHSCOPE_API_KEY:-}" || -n "${DASHSCOPE_BASE_URL:-}" ]]; then
    use_dashscope=true
    info "Using DashScope / OpenAI-compatible endpoint configuration"
  fi

  info "Installing Grok AI agent..."
  install_grok_cli

  if [[ "${use_dashscope}" == true ]]; then
    configure_dashscope_grok
  else
    info "Skipping endpoint configuration (pass --dashscope or set DASHSCOPE_* env vars)"
  fi

  success "Grok AI agent installation completed"
  echo ""
  echo "Next steps:"
  echo "  export DASHSCOPE_API_KEY=sk-xxx"
  echo "  grok"
  echo "  grok -p \"hello\" -m ${DASHSCOPE_DEFAULT_MODEL}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
