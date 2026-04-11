#!/bin/bash
###################################################
# Safe Installation Wrapper
# Interactive installer with validation and confirmation
###################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

COMPONENT="${1:-}"

if [[ -z "$COMPONENT" ]]; then
    echo -e "${RED}Error: Component name required${RESET}"
    echo "Usage: install_helper.sh <component>"
    echo "Examples:"
    echo "  install_helper.sh pyenv"
    echo "  install_helper.sh zsh"
    echo "  install_helper.sh nvim"
    echo "  install_helper.sh basics"
    echo "  install_helper.sh all"
    exit 1
fi

echo -e "${BLUE}=== Installation Helper: $COMPONENT ===${RESET}"
echo

# Locate install script
DOTFILES_PATH="${HOME}/.dotfiles"

if [[ ! -d "$DOTFILES_PATH" ]]; then
    echo -e "${RED}✗ Dotfiles repository not found at $DOTFILES_PATH${RESET}"
    echo -e "${YELLOW}  Clone first: git clone https://github.com/caesar0301/dotfiles.git ~/.dotfiles${RESET}"
    exit 1
fi

# Find appropriate install script
INSTALL_SCRIPT=""
case "$COMPONENT" in
    basics)
        INSTALL_SCRIPT="$DOTFILES_PATH/install_basics.sh"
        DESCRIPTION="Basic components: zsh, tmux, nvim + essential tools"
        ;;
    all)
        INSTALL_SCRIPT="$DOTFILES_PATH/install_all.sh"
        DESCRIPTION="All components: zsh, tmux, nvim, emacs, vifm, misc, lisp + all tools"
        ;;
    essentials)
        INSTALL_SCRIPT="$DOTFILES_PATH/lib/install-essentials.sh"
        DESCRIPTION="Essential development tools: pyenv, fzf, ctags, cargo, Homebrew, AI agents"
        ;;
    *)
        # Check for module install script
        MODULE_SCRIPT="$DOTFILES_PATH/$COMPONENT/install.sh"
        LIB_SCRIPT="$DOTFILES_PATH/lib/install-$COMPONENT.sh"

        if [[ -f "$MODULE_SCRIPT" ]]; then
            INSTALL_SCRIPT="$MODULE_SCRIPT"
            DESCRIPTION="Module: $COMPONENT"
        elif [[ -f "$LIB_SCRIPT" ]]; then
            INSTALL_SCRIPT="$LIB_SCRIPT"
            DESCRIPTION="Tool: $COMPONENT"
        else
            # Search for partial matches
            MATCHES=$(find "$DOTFILES_PATH/lib" -name "install-*$COMPONENT*.sh" 2>/dev/null || echo "")
            if [[ -n "$MATCHES" ]]; then
                echo -e "${YELLOW}Multiple install scripts found matching '$COMPONENT':${RESET}"
                echo "$MATCHES" | sed 's/^/  /'
                echo -e "${YELLOW}Please specify exact component name${RESET}"
                exit 1
            else
                echo -e "${RED}✗ No install script found for: $COMPONENT${RESET}"
                echo -e "${YELLOW}  Available modules: zsh, nvim, tmux, emacs, vifm, misc, lisp${RESET}"
                echo -e "${YELLOW}  Available tools: pyenv, fzf, ctags, cargo, homebrew, neovim, etc.${RESET}"
                echo -e "${YELLOW}  Check: ls ~/.dotfiles/lib/install-*.sh${RESET}"
                exit 1
            fi
        fi
        ;;
esac

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    echo -e "${RED}✗ Install script not found: $INSTALL_SCRIPT${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Found install script: $INSTALL_SCRIPT${RESET}"
echo -e "${CYAN}  Description: $DESCRIPTION${RESET}"
echo

# Show what will be installed
echo -e "${BLUE}What will happen:${RESET}"
echo -e "${CYAN}  1. Script will run: $INSTALL_SCRIPT${RESET}"
echo -e "${CYAN}  2. Configurations will be symlinked to XDG paths${RESET}"
echo -e "${CYAN}  3. Tools will be installed to ~/.local/bin or system paths${RESET}"
echo -e "${CYAN}  4. PATH may be updated in shell config${RESET}"
echo

# Check current state
echo -e "${BLUE}Current state:${RESET}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

if [[ "$COMPONENT" == "basics" || "$COMPONENT" == "all" || "$COMPONENT" == "essentials" ]]; then
    # Check multiple components
    for tool in zsh nvim tmux; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo -e "${GREEN}  ✓ $tool already installed${RESET}"
        else
            echo -e "${YELLOW}  ✗ $tool not installed${RESET}"
        fi
    done
else
    # Check specific component
    if command -v "$COMPONENT" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ $COMPONENT already installed${RESET}"
        CONFIG_PATH="$XDG_CONFIG_HOME/$COMPONENT"
        if [[ -d "$CONFIG_PATH" ]]; then
            echo -e "${GREEN}  ✓ Config exists at $CONFIG_PATH${RESET}"
        else
            echo -e "${YELLOW}  ⚠ Config missing${RESET}"
        fi
    else
        echo -e "${YELLOW}  ✗ $COMPONENT not installed${RESET}"
    fi
fi

echo

# Ask for confirmation
echo -e "${BLUE}Ready to install?${RESET}"
read -p "Proceed with installation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled${RESET}"
    exit 0
fi

echo
echo -e "${BLUE}=== Installing $COMPONENT ===${RESET}"

# Execute installation
cd "$DOTFILES_PATH"
bash "$INSTALL_SCRIPT"

INSTALL_STATUS=$?

echo
echo -e "${BLUE}=== Installation Results ===${RESET}"

if [[ $INSTALL_STATUS -eq 0 ]]; then
    echo -e "${GREEN}✓ Installation successful${RESET}"
    echo
    echo -e "${BLUE}Next steps:${RESET}"
    echo -e "${CYAN}  1. Restart shell to apply PATH changes: exec \$SHELL${RESET}"
    echo -e "${CYAN}  2. Verify installation: which $COMPONENT${RESET}"
    if [[ "$COMPONENT" != "essentials" ]]; then
        echo -e "${CYAN}  3. Check configuration: ls ~/.config/$COMPONENT${RESET}"
    fi
    echo

    # Verification
    echo -e "${BLUE}Quick verification:${RESET}"
    if command -v "$COMPONENT" >/dev/null 2>&1 || [[ "$COMPONENT" == "essentials" ]]; then
        if [[ "$COMPONENT" != "essentials" ]]; then
            TOOL_PATH=$(command -v "$COMPONENT")
            echo -e "${GREEN}✓ $COMPONENT available at: $TOOL_PATH${RESET}"
        fi
        echo -e "${GREEN}✓ Installation verified${RESET}"
    else
        echo -e "${YELLOW}⚠ $COMPONENT installed but not yet in PATH${RESET}"
        echo -e "${YELLOW}  Run: exec \$SHELL${RESET}"
    fi

    exit 0
else
    echo -e "${RED}✗ Installation failed (exit code: $INSTALL_STATUS)${RESET}"
    echo -e "${YELLOW}  Check error messages above${RESET}"
    echo -e "${YELLOW}  Verify prerequisites are met${RESET}"
    exit 1
fi