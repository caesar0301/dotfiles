#!/bin/bash
###################################################
# Hermes AI Agent Installer
#
# Wraps the official Hermes Agent installer from Nous Research:
#   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
#
# Hermes is a self-contained open-source AI agent with its own config
# system (~/.hermes/ — config.yaml, .env, SOUL.md, skills/). Unlike the
# DashScope-synced agents (grok, codex, opencode) it does NOT read from
# lib/claude-code-router.json; API keys are configured via `hermes setup`
# or directly in ~/.hermes/.env.
#
# Copyright (c) 2024, 2026 Xiaming Chen
# License: MIT
###################################################

set -euo pipefail

readonly HERMES_INSTALL_URL="https://hermes-agent.nousresearch.com/install.sh"
readonly HERMES_HOME_DEFAULT="${HOME}/.hermes"

usage() {
  cat <<EOF
Hermes AI Agent Installer

Wraps the official Nous Research installer for Hermes Agent.

Usage: $(basename "$0") [OPTIONS] -- [HERMES_FLAGS]

Options:
  --skip-setup         Skip the interactive setup wizard (non-interactive)
  --skip-browser       Skip Playwright/Chromium install (browser tools won't work)
  --skip-computer-use  Skip the cua-driver (Computer Use) install
  --no-skills          Start with a blank slate — seed no bundled skills
  --non-interactive    Skip all stages that require user input
  --branch NAME        Git branch to install (default: main)
  --include-desktop    Also build the desktop app (Hermes.app)
  --hermes-home PATH   Data directory (default: ~/.hermes)
  --dir PATH           Installation directory for the code checkout
  -h, --help           Show this help message and exit

Pass-through flags are forwarded to the upstream installer after '--'.

Examples:
  $(basename "$0")                              # Interactive install with setup wizard
  $(basename "$0") --skip-setup                 # Non-interactive, skip setup wizard
  $(basename "$0") --skip-browser --skip-setup  # Headless server install
  $(basename "$0") -- --no-venv --skip-setup   # Pass raw flags to upstream installer

Note: Hermes requires Python >= 3.11 and (optionally) Node.js >= 20 for
      browser tools. The upstream installer manages its own venv via uv.
      Config: ~/.hermes/config.yaml, ~/.hermes/.env
      Command: hermes (linked into ~/.local/bin)
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shlib.sh
source "${SCRIPT_DIR}/shlib.sh"

# Verify the hermes command is available after install.
verify_hermes_installed() {
  local hermes_home="${1:-}"

  # The installer links `hermes` into ~/.local/bin (or /usr/local/bin for
  # root FHS installs). Check both the current PATH and the default link dir.
  if checkcmd hermes; then
    success "Hermes command available at $(command -v hermes)"
    return 0
  fi

  # ~/.local/bin may not be on PATH yet in this shell session
  if [[ -x "${HOME}/.local/bin/hermes" ]]; then
    success "Hermes command installed at ${HOME}/.local/bin/hermes"
    info "Add ~/.local/bin to PATH or run: exec \$SHELL"
    return 0
  fi

  if [[ -x "/usr/local/bin/hermes" ]]; then
    success "Hermes command installed at /usr/local/bin/hermes"
    return 0
  fi

  warn "Hermes command not found on PATH; it may need a shell reload"
  if [[ -n "${hermes_home}" ]]; then
    info "Hermes data directory: ${hermes_home}"
  fi
  info "Run 'exec \$SHELL' or add ~/.local/bin to PATH, then run: hermes"
}

# Install Hermes Agent via the official installer.
#
# Collects pass-through flags and forwards them to the upstream script.
# The upstream installer is self-contained: it clones the repo, creates a
# venv, installs deps, sets up config, and links the `hermes` command.
install_hermes_agent() {
  local -a hermes_flags=()
  local hermes_home=""

  # Re-parse args here (called from main after our own flags are consumed)
  while [[ $# -gt 0 ]]; do
    case $1 in
    --skip-setup)
      hermes_flags+=("--skip-setup")
      shift
      ;;
    --skip-browser)
      hermes_flags+=("--skip-browser")
      shift
      ;;
    --skip-computer-use)
      hermes_flags+=("--skip-computer-use")
      shift
      ;;
    --no-skills)
      hermes_flags+=("--no-skills")
      shift
      ;;
    --non-interactive)
      hermes_flags+=("--non-interactive")
      shift
      ;;
    --include-desktop)
      hermes_flags+=("--include-desktop")
      shift
      ;;
    --branch)
      hermes_flags+=("--branch" "$2")
      shift 2
      ;;
    --hermes-home)
      hermes_home="$2"
      hermes_flags+=("--hermes-home" "$2")
      shift 2
      ;;
    --dir)
      hermes_flags+=("--dir" "$2")
      shift 2
      ;;
    --)
      shift
      # Everything after -- is passed raw to the upstream installer
      hermes_flags+=("$@")
      break
      ;;
    *)
      # Unknown flags are forwarded raw to the upstream installer
      hermes_flags+=("$1")
      shift
      ;;
    esac
  done

  if checkcmd hermes; then
    info "Hermes already installed ($(command -v hermes)); running upstream installer to update..."
  else
    info "Installing Hermes Agent via official installer..."
  fi

  info "Upstream URL: ${HERMES_INSTALL_URL}"
  if [[ ${#hermes_flags[@]} -gt 0 ]]; then
    info "Pass-through flags: ${hermes_flags[*]}"
  fi

  # Download and run the upstream installer.
  # We fetch to a temp file first so we can detect download failures before
  # piping into bash (curl | bash hides download errors behind a broken pipe).
  local installer_script
  installer_script="$(mktemp)"
  trap 'rm -f "${installer_script}"' EXIT INT TERM

  info "Downloading Hermes installer..."
  if ! curl -fsSL "${HERMES_INSTALL_URL}" -o "${installer_script}"; then
    error "Failed to download Hermes installer from ${HERMES_INSTALL_URL}"
  fi
  success "Installer downloaded"

  info "Running Hermes installer..."
  # NOTE: use "${arr[@]+...}" (not "${arr[@]}") so that an empty flag list
  # does not trip `set -u` on bash 3.2 (macOS /bin/bash), which treats an
  # empty array expansion as an unbound variable.
  if bash "${installer_script}" ${hermes_flags[@]+"${hermes_flags[@]}"}; then
    success "Hermes Agent installation completed"
  else
    error "Hermes Agent installation failed"
  fi

  [[ -z "${hermes_home}" ]] && hermes_home="${HERMES_HOME_DEFAULT}"
  verify_hermes_installed "${hermes_home}"
}

main() {
  local -a passthrough=()
  local show_help=false

  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      show_help=true
      shift
      ;;
    --)
      shift
      passthrough+=("$@")
      break
      ;;
    *)
      passthrough+=("$1")
      shift
      ;;
    esac
  done

  if [[ "${show_help}" == true ]]; then
    usage
    exit 0
  fi

  info "Installing Hermes AI agent..."
  # See note above: ${arr[@]+...} guards empty-array expansion under set -u
  # on bash 3.2 (macOS /bin/bash).
  install_hermes_agent ${passthrough[@]+"${passthrough[@]}"}

  success "Hermes AI agent installation completed"
  echo ""
  echo "Next steps:"
  echo "  hermes              Start chatting"
  echo "  hermes setup        Configure API keys & settings"
  echo "  hermes config       View/edit configuration"
  echo "  hermes update       Update to latest version"
  echo ""
  echo "Config:    ~/.hermes/config.yaml"
  echo "API keys:  ~/.hermes/.env"
  echo "Data:      ~/.hermes/{sessions,logs,skills,...}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
