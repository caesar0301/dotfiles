#!/bin/bash
###################################################
# PATH Diagnostic Tool
# Analyze PATH configuration and find issues
###################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Current PATH
CURRENT_PATH="$PATH"

echo -e "${BLUE}=== PATH Diagnostic ===${RESET}"
echo

# Display current PATH
echo -e "${BLUE}Current PATH:${RESET}"
echo "$CURRENT_PATH" | tr ':' '\n' | nl

echo
echo -e "${BLUE}Expected critical paths:${RESET}"

# Platform-specific expected paths
if [[ "$(uname)" == "Darwin" ]]; then
    EXPECTED_PATHS=(
        "$HOME/.local/bin"
        "/opt/homebrew/bin"  # Apple Silicon
        "/usr/local/Homebrew/bin"  # Intel
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
    )
elif [[ "$(uname)" == "Linux" ]]; then
    EXPECTED_PATHS=(
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
    )
else
    EXPECTED_PATHS=(
        "$HOME/.local/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
    )
fi

for expected in "${EXPECTED_PATHS[@]}"; do
    if [[ ":$CURRENT_PATH:" == *":$expected:"* ]]; then
        echo -e "${GREEN}✓ $expected${RESET}"
    else
        echo -e "${RED}✗ $expected${RESET} - MISSING"
    fi
done

echo

# Check for duplicates
echo -e "${BLUE}Duplicate entries:${RESET}"
DUPLICATES=$(echo "$CURRENT_PATH" | tr ':' '\n' | sort | uniq -d)
if [[ -n "$DUPLICATES" ]]; then
    echo "$DUPLICATES" | while read -r dup; do
        echo -e "${YELLOW}⚠ $dup${RESET} - appears multiple times"
    done
else
    echo -e "${GREEN}✓ No duplicates${RESET}"
fi

echo

# Check for non-existent directories
echo -e "${BLUE}Non-existent directories:${RESET}"
NON_EXISTENT=0
echo "$CURRENT_PATH" | tr ':' '\n' | while read -r dir; do
    if [[ -n "$dir" && ! -d "$dir" ]]; then
        echo -e "${RED}✗ $dir${RESET} - does not exist"
        ((NON_EXISTENT++))
    fi
done

if [[ "$NON_EXISTENT" -eq 0 ]]; then
    echo -e "${GREEN}✓ All directories exist${RESET}"
fi

echo

# Check specific tool if provided
TOOL_NAME="${1:-}"
if [[ -n "$TOOL_NAME" ]]; then
    echo -e "${BLUE}Tool: $TOOL_NAME${RESET}"

    # Check if tool exists
    TOOL_PATH=$(command -v "$TOOL_NAME" 2>/dev/null || echo "")

    if [[ -n "$TOOL_PATH" ]]; then
        echo -e "${GREEN}✓ Found at: $TOOL_PATH${RESET}"

        # Check if in expected location
        if [[ "$TOOL_PATH" == "$HOME/.local/bin/$TOOL_NAME" ]]; then
            echo -e "${GREEN}✓ In expected ~/.local/bin location${RESET}"
        elif [[ "$TOOL_PATH" =~ ^/usr/local/bin/ || "$TOOL_PATH" =~ ^/opt/homebrew/bin/ ]]; then
            echo -e "${GREEN}✓ In standard system location${RESET}"
        else
            echo -e "${YELLOW}⚠ In non-standard location${RESET}"
        fi
    else
        echo -e "${RED}✗ Not found in PATH${RESET}"

        # Check if it exists but PATH is broken
        if [[ -f "$HOME/.local/bin/$TOOL_NAME" ]]; then
            echo -e "${YELLOW}  Tool exists at ~/.local/bin/$TOOL_NAME but PATH missing this directory${RESET}"
            echo -e "${YELLOW}  Fix: Add to PATH in ~/.config/zsh/init.zsh and run: exec $SHELL${RESET}"
        else
            echo -e "${YELLOW}  Tool not installed${RESET}"
            echo -e "${YELLOW}  Install via: cd ~/.dotfiles && ./lib/install-essentials.sh${RESET}"
        fi
    fi

    echo
fi

# Recommendations
echo -e "${BLUE}Recommendations:${RESET}"

LOCAL_BIN="$HOME/.local/bin"
if [[ ":$CURRENT_PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo -e "${YELLOW}1. Add ~/.local/bin to PATH:${RESET}"
    echo "   Edit ~/.config/zsh/init.zsh to add:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "   Then run: exec \$SHELL"
fi

if [[ -n "$DUPLICATES" ]]; then
    echo -e "${YELLOW}2. Remove duplicate PATH entries${RESET}"
    echo "   Check your shell config files for multiple PATH modifications"
fi

if [[ "$NON_EXISTENT" -gt 0 ]]; then
    echo -e "${YELLOW}3. Remove non-existent directories from PATH${RESET}"
    echo "   Clean up your shell config to remove outdated paths"
fi

echo
echo -e "${BLUE}=== Diagnostic Complete ===${RESET}"