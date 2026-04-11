#!/bin/bash
###################################################
# Tool Status Checker
# Check installation and configuration of specific tools
###################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

TOOL_NAME="${1:-}"

if [[ -z "$TOOL_NAME" ]]; then
    echo -e "${RED}Error: Tool name required${RESET}"
    echo "Usage: tool_status.sh <tool-name>"
    echo "Example: tool_status.sh nvim"
    exit 1
fi

echo -e "${BLUE}=== Tool Status: $TOOL_NAME ===${RESET}"
echo

# Binary check
echo -e "${BLUE}Binary Installation:${RESET}"
TOOL_PATH=$(command -v "$TOOL_NAME" 2>/dev/null || echo "")

if [[ -n "$TOOL_PATH" ]]; then
    echo -e "${GREEN}✓ Binary found: $TOOL_PATH${RESET}"

    # Version check
    VERSION_OUTPUT=$(timeout 2 "$TOOL_NAME" --version 2>/dev/null || timeout 2 "$TOOL_NAME" version 2>/dev/null || echo "")
    if [[ -n "$VERSION_OUTPUT" ]]; then
        echo -e "${GREEN}✓ Version:${RESET}"
        echo "$VERSION_OUTPUT" | head -3 | sed 's/^/  /'
    else
        echo -e "${YELLOW}⚠ Version info not available${RESET}"
    fi
else
    echo -e "${RED}✗ Binary not found${RESET}"
fi

echo

# Configuration check
echo -e "${BLUE}Configuration:${RESET}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Tool-specific config paths
case "$TOOL_NAME" in
    zsh)
        CONFIG_PATH="$XDG_CONFIG_HOME/zsh"
        DATA_PATH="$XDG_DATA_HOME/zinit"
        ;;
    nvim)
        CONFIG_PATH="$XDG_CONFIG_HOME/nvim"
        DATA_PATH="$XDG_DATA_HOME/nvim"
        ;;
    tmux)
        CONFIG_PATH="$XDG_CONFIG_HOME/tmux"
        DATA_PATH="$XDG_DATA_HOME/tmux"
        ;;
    *)
        CONFIG_PATH="$XDG_CONFIG_HOME/$TOOL_NAME"
        DATA_PATH="$XDG_DATA_HOME/$TOOL_NAME"
        ;;
esac

if [[ -d "$CONFIG_PATH" ]]; then
    echo -e "${GREEN}✓ Config directory: $CONFIG_PATH${RESET}"
    CONFIG_COUNT=$(find "$CONFIG_PATH" -type f | wc -l | tr -d ' ')
    echo -e "${GREEN}✓ $CONFIG_COUNT configuration files${RESET}"
else
    echo -e "${YELLOW}⚠ Config directory missing: $CONFIG_PATH${RESET}"
fi

if [[ -d "$DATA_PATH" ]]; then
    echo -e "${GREEN}✓ Data directory: $DATA_PATH${RESET}"
else
    echo -e "${YELLOW}⚠ Data directory missing: $DATA_PATH${RESET}"
fi

echo

# Dependencies check
echo -e "${BLUE}Dependencies:${RESET}"

case "$TOOL_NAME" in
    nvim)
        # Check Python support
        PYTHON_SUPPORT=$(python3 -c "import pynvim" 2>/dev/null && echo "available" || echo "missing")
        if [[ "$PYTHON_SUPPORT" == "available" ]]; then
            echo -e "${GREEN}✓ Python pynvim module available${RESET}"
        else
            echo -e "${YELLOW}⚠ Python pynvim module missing${RESET}"
            echo "  Install: pip install pynvim"
        fi

        # Check ripgrep for telescope
        if command -v rg >/dev/null 2>&1; then
            echo -e "${GREEN}✓ ripgrep (rg) available${RESET}"
        else
            echo -e "${YELLOW}⚠ ripgrep missing (telescope.nvim functionality limited)${RESET}"
        fi

        # Check kernel version on Linux
        if [[ "$(uname)" == "Linux" ]]; then
            KERNEL_VERSION=$(uname -r)
            echo -e "${BLUE}  Kernel version: $KERNEL_VERSION${RESET}"
            if [[ $(echo "$KERNEL_VERSION >= 5.0" | bc 2>/dev/null || echo "0") == "1" ]]; then
                echo -e "${GREEN}  ✓ Modern plugins supported (kernel >= 5.0)${RESET}"
            else
                echo -e "${YELLOW}  ⚠ Some plugins may be disabled (kernel < 5.0)${RESET}"
            fi
        fi
        ;;
    zsh)
        # Check Zinit
        ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
        if [[ -d "$ZINIT_HOME" ]]; then
            echo -e "${GREEN}✓ Zinit installed${RESET}"
        else
            echo -e "${YELLOW}⚠ Zinit missing${RESET}"
            echo "  Install: cd ~/.dotfiles && ./zsh/install.sh"
        fi
        ;;
    pyenv)
        # Check pyenv plugins
        PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
        if [[ -d "$PYENV_ROOT/plugins/pyenv-virtualenv" ]]; then
            echo -e "${GREEN}✓ pyenv-virtualenv installed${RESET}"
        else
            echo -e "${YELLOW}⚠ pyenv-virtualenv missing${RESET}"
        fi
        ;;
esac

echo

# Platform compatibility
echo -e "${BLUE}Platform Compatibility:${RESET}"
PLATFORM=$(uname)
echo -e "${GREEN}✓ Platform: $PLATFORM${RESET}"

case "$TOOL_NAME" in
    brew)
        if [[ "$PLATFORM" == "Darwin" ]]; then
            echo -e "${GREEN}✓ Homebrew is primary package manager on macOS${RESET}"
        elif [[ "$PLATFORM" == "Linux" ]]; then
            echo -e "${YELLOW}⚠ Homebrew on Linux (consider native package manager)${RESET}"
        fi
        ;;
esac

echo

# Installation source check
echo -e "${BLUE}Installation Source:${RESET}"
DOTFILES_LIB="$HOME/.dotfiles/lib"
if [[ -d "$DOTFILES_LIB" ]]; then
    INSTALL_SCRIPT=$(find "$DOTFILES_LIB" -name "install-$TOOL_NAME.sh" -o -name "install-*$TOOL_NAME*.sh" | head -1)
    if [[ -n "$INSTALL_SCRIPT" ]]; then
        echo -e "${GREEN}✓ Dotfiles install script: $INSTALL_SCRIPT${RESET}"
        if [[ -n "$TOOL_PATH" ]]; then
            echo -e "${GREEN}✓ Can reinstall/update: $INSTALL_SCRIPT${RESET}"
        else
            echo -e "${YELLOW}⚠ Install via: $INSTALL_SCRIPT${RESET}"
        fi
    else
        echo -e "${YELLOW}⚠ No dotfiles install script for $TOOL_NAME${RESET}"
    fi
else
    echo -e "${YELLOW}⚠ Dotfiles lib directory not found${RESET}"
fi

echo

# Summary
echo -e "${BLUE}=== Status Summary ===${RESET}"
if [[ -n "$TOOL_PATH" && -d "$CONFIG_PATH" ]]; then
    echo -e "${GREEN}✓ $TOOL_NAME fully configured and operational${RESET}"
    exit 0
elif [[ -n "$TOOL_PATH" ]]; then
    echo -e "${YELLOW}⚠ $TOOL_NAME installed but configuration incomplete${RESET}"
    exit 0
else
    echo -e "${RED}✗ $TOOL_NAME not installed or not in PATH${RESET}"
    exit 1
fi