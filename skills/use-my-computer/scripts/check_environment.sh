#!/bin/bash
###################################################
# Environment Health Check
# Comprehensive diagnostic for dotfiles environment
###################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Counters
ISSUES=0
WARNINGS=0
SUCCESS=0

# Print functions
print_header() {
    echo -e "${BLUE}=== $1 ===${RESET}"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
    ((SUCCESS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
    ((WARNINGS++))
}

print_error() {
    echo -e "${RED}✗ $1${RESET}"
    ((ISSUES++))
}

# Check dotfiles repository
print_header "Dotfiles Repository"
DOTFILES_PATH="${HOME}/.dotfiles"
if [[ -d "$DOTFILES_PATH" ]]; then
    print_success "Dotfiles repository found at $DOTFILES_PATH"
    if [[ -f "$DOTFILES_PATH/CLAUDE.md" ]]; then
        print_success "CLAUDE.md documentation present"
    else
        print_warning "CLAUDE.md missing - may be outdated clone"
    fi
else
    print_error "Dotfiles repository not found at $DOTFILES_PATH"
    echo "  Clone from: https://github.com/caesar0301/dotfiles.git"
fi

# Check XDG paths
print_header "XDG Base Directory Paths"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

for xdg_path in "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME"; do
    if [[ -d "$xdg_path" ]]; then
        print_success "XDG path exists: $xdg_path"
    else
        print_warning "XDG path missing: $xdg_path (will be created when needed)"
    fi
done

# Check PATH configuration
print_header "PATH Configuration"
LOCAL_BIN="$HOME/.local/bin"
if [[ ":$PATH:" == *":$LOCAL_BIN:"* ]]; then
    print_success "~/.local/bin in PATH"
else
    print_error "~/.local/bin NOT in PATH"
    echo "  Add to PATH via ~/.config/zsh/init.zsh or restart shell"
fi

# Check core tools
print_header "Core Tools"
check_tool() {
    local tool=$1
    if command -v "$tool" >/dev/null 2>&1; then
        local path=$(command -v "$tool")
        print_success "$tool installed at $path"
    else
        print_error "$tool not found"
    fi
}

check_tool "zsh"
check_tool "nvim"
check_tool "tmux"
check_tool "python3"
check_tool "git"

# Check version managers
print_header "Version Managers"
check_optional_tool() {
    local tool=$1
    local name=$2
    if command -v "$tool" >/dev/null 2>&1; then
        print_success "$name installed"
    else
        print_warning "$name not installed (optional)"
    fi
}

check_tool "pyenv"
check_optional_tool "jenv" "jenv (Java)"
check_optional_tool "gvm" "gvm (Go)"
check_optional_tool "nvm" "nvm (Node.js)"

# Check Zsh configuration
print_header "Zsh Configuration"
ZSH_CONFIG="$XDG_CONFIG_HOME/zsh"
if [[ -d "$ZSH_CONFIG" ]]; then
    print_success "Zsh config directory: $ZSH_CONFIG"
    if [[ -f "$ZSH_CONFIG/init.zsh" ]]; then
        print_success "init.zsh present"
    else
        print_error "init.zsh missing"
    fi
    if [[ -f "$HOME/.zshrc" ]]; then
        print_success ".zshrc exists (should source init.zsh)"
    else
        print_warning ".zshrc missing"
    fi
else
    print_error "Zsh config directory missing"
fi

# Check Zinit
ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
if [[ -d "$ZINIT_HOME" ]]; then
    print_success "Zinit installed at $ZINIT_HOME"
else
    print_warning "Zinit not installed (install via zsh/install.sh)"
fi

# Check Neovim configuration
print_header "Neovim Configuration"
NVIM_CONFIG="$XDG_CONFIG_HOME/nvim"
if [[ -d "$NVIM_CONFIG" ]]; then
    print_success "Neovim config directory: $NVIM_CONFIG"
    if [[ -f "$NVIM_CONFIG/init.lua" ]]; then
        print_success "init.lua present"
    else
        print_error "init.lua missing"
    fi
else
    print_error "Neovim config directory missing"
fi

# Check Lazy.nvim
LAZY_HOME="$XDG_DATA_HOME/nvim/lazy/lazy.nvim"
if [[ -d "$LAZY_HOME" ]]; then
    print_success "Lazy.nvim installed"
else
    print_warning "Lazy.nvim not installed (will auto-install on first nvim run)"
fi

# Check custom tools
print_header "Custom Tools (dotme-xxx)"
if [[ -d "$LOCAL_BIN" ]]; then
    DOTME_COUNT=$(find "$LOCAL_BIN" -name "dotme-*" -type f | wc -l | tr -d ' ')
    if [[ "$DOTME_COUNT" -gt 0 ]]; then
        print_success "$DOTME_COUNT dotme tools installed"
    else
        print_warning "No dotme tools found (install via lib/install-essentials.sh)"
    fi
else
    print_error "~/.local/bin directory missing"
fi

# Platform-specific checks
print_header "Platform-Specific"
if [[ "$(uname)" == "Darwin" ]]; then
    print_success "Platform: macOS"
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew installed"
    else
        print_warning "Homebrew not installed"
    fi
elif [[ "$(uname)" == "Linux" ]]; then
    print_success "Platform: Linux"
    KERNEL_VERSION=$(uname -r)
    echo "  Kernel version: $KERNEL_VERSION"
    if [[ $(echo "$KERNEL_VERSION >= 5.0" | bc 2>/dev/null || echo "0") == "1" ]]; then
        print_success "Kernel >= 5.0 (modern Neovim plugins supported)"
    else
        print_warning "Kernel < 5.0 (some Neovim plugins may be disabled)"
    fi
    if command -v systemctl >/dev/null 2>&1; then
        print_success "Systemd available"
    else
        print_warning "Systemd not available"
    fi
fi

# Summary
print_header "Summary"
echo "Successes: $SUCCESS"
echo "Warnings: $WARNINGS"
echo "Issues: $ISSUES"

if [[ "$ISSUES" -gt 0 ]]; then
    echo -e "${RED}Environment needs attention. Fix issues above.${RESET}"
    exit 1
elif [[ "$WARNINGS" -gt 0 ]]; then
    echo -e "${YELLOW}Environment partially configured. Some optional features missing.${RESET}"
    exit 0
else
    echo -e "${GREEN}Environment fully configured and healthy!${RESET}"
    exit 0
fi