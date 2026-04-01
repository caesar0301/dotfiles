#!/bin/bash
###################################################
# AI Code Agents Installer
#
# Installs various AI code agents and tools
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

usage() {
  cat <<EOF
AI Code Agents Installer

Usage: $(basename "$0") [OPTIONS]

Options:
  --claude       Install Claude Code and claude-code-router
  --opencode     Install opencode
  --cursor       Install Cursor agent
  --codex        Install OpenAI Codex and oh-my-codex
  --all          Install all agents (default if no options specified)
  --autostart    Enable pm2 autostart for ccr and opencode-web (independent of --all)
  -h, --help     Show this help message and exit

Examples:
  $(basename "$0")                      # Install all agents (no autostart)
  $(basename "$0") --all                # Install all agents (no autostart)
  $(basename "$0") --claude             # Install only Claude Code and router
  $(basename "$0") --all --autostart    # Install all agents with autostart
  $(basename "$0") --claude --opencode  # Install Claude and opencode only
  $(basename "$0") --codex              # Install OpenAI Codex only

Note: --autostart is not included in --all and must be specified separately
EOF
}

# Source the shell utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shlib.sh"

# Main installation function
main() {
  local install_claude=false
  local install_opencode=false
  local install_cursor=false
  local install_codex=false
  local enable_autostart=false
  local any_agent_specified=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --claude)
      install_claude=true
      any_agent_specified=true
      shift
      ;;
    --opencode)
      install_opencode=true
      any_agent_specified=true
      shift
      ;;
    --cursor)
      install_cursor=true
      any_agent_specified=true
      shift
      ;;
    --codex)
      install_codex=true
      any_agent_specified=true
      shift
      ;;
    --all)
      install_claude=true
      install_opencode=true
      install_cursor=true
      install_codex=true
      any_agent_specified=true
      shift
      ;;
    --autostart)
      enable_autostart=true
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

  # If no agent specified, default to installing all agents
  if [[ "$any_agent_specified" == "false" ]]; then
    info "No specific agents specified, installing all agents by default..."
    install_claude=true
    install_opencode=true
    install_cursor=true
    install_codex=true
  fi

  info "Installing AI code agents..."

  # Install cursor agent CLI
  if [[ "$install_cursor" == "true" ]]; then
    info "Calling install-ai-agent-cursor.sh..."
    if "$SCRIPT_DIR/install-ai-agent-cursor.sh"; then
      success "Cursor agent installation completed"
    else
      error "Cursor agent installation failed"
      return 1
    fi
  fi

  # Install claude code CLI and router
  if [[ "$install_claude" == "true" ]]; then
    local autostart_flag=""
    if [[ "$enable_autostart" == "true" ]]; then
      autostart_flag="--autostart"
    fi

    info "Calling install-ai-agent-claude.sh..."
    if "$SCRIPT_DIR/install-ai-agent-claude.sh" $autostart_flag; then
      success "Claude agent installation completed"
    else
      error "Claude agent installation failed"
      return 1
    fi
  fi

  # Install opencode
  if [[ "$install_opencode" == "true" ]]; then
    local autostart_flag=""
    if [[ "$enable_autostart" == "true" ]]; then
      autostart_flag="--autostart"
    fi

    info "Calling install-ai-agent-opencode.sh..."
    if "$SCRIPT_DIR/install-ai-agent-opencode.sh" $autostart_flag; then
      success "OpenCode agent installation completed"
    else
      error "OpenCode agent installation failed"
      return 1
    fi
  fi

  # Install codex
  if [[ "$install_codex" == "true" ]]; then
    info "Calling install-ai-agent-codex.sh..."
    if "$SCRIPT_DIR/install-ai-agent-codex.sh"; then
      success "OpenAI Codex agent installation completed"
    else
      error "OpenAI Codex agent installation failed"
      return 1
    fi
  fi

  success "AI code agents installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
