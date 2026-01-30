# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles collection (`cool-dotfiles`) for setting up a modern development environment. It includes configurations for Zsh, Neovim, Tmux, Emacs, and various development tools with automated installation scripts.

## Key Installation Commands

### Basic Installation
```bash
# Install essential components (Zsh, Tmux, Neovim) with prerequisites
./install_basics.sh

# Install all modules including Emacs, Vifm, and misc configurations
./install_all.sh
```

### Installation Options
- `-s`: Use symlinks (default)
- `-f`: Force copy instead of symlinks
- `-c`: Clean/remove configurations

### Essential Development Tools
The essential tools installer (`lib/install-essentials.sh`) is automatically run as a prerequisite:

```bash
# Basic installation (utility scripts + pyenv + fzf + ctags + cargo)
./lib/install-essentials.sh

# With optional components
INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 INSTALL_AI_CODE_AGENTS=1 ./lib/install-essentials.sh
```

**What Gets Installed (Always):**
- Local utility scripts (dotme-xxx series) to `~/.local/bin`
- pyenv: Python version manager
- fzf: Fuzzy finder
- universal-ctags: Code navigation tool
- cargo: Rust toolchain

**Optional Features (via environment variables):**
- `INSTALL_HOMEBREW=1`: Homebrew package manager
- `INSTALL_EXTRA_VENV=1`: jenv (Java), gvm (Go), nvm (Node), rbenv (Ruby) version managers
- `INSTALL_AI_CODE_AGENTS=1`: AI-powered development tools (requires npm >= 20)

### Individual Module Installation
```bash
# Zsh configuration
sh zsh/install.sh

# Neovim (includes LSP support)
sh nvim/install.sh

# Tmux
sh tmux/install.sh

# Emacs
sh emacs/install.sh

# Vifm file manager
sh vifm/install.sh

# Lisp development environment
sh lisp/install.sh

# Alacritty terminal emulator
sh alacritty/install.sh

# Misc configurations (includes Kitty terminal)
sh misc/install.sh
```

### Code Formatting
```bash
# Format shell scripts (excluding zsh-specific files)
./format.sh
```

## Architecture

### Core Components

1. **Installation Orchestrators**
   - `install_all.sh`: Full installation with all optional features (Zsh, Tmux, Neovim, Emacs, Vifm, Misc, Lisp, Alacritty)
   - `install_basics.sh`: Minimal installation with core components (Zsh, Tmux, Neovim)
   - Both use `lib/install-essentials.sh` as prerequisite

2. **Shared Library (`lib/`)**
   - `shmisc.sh`: Core shell utility library with logging, path utilities, system detection
   - `install-essentials.sh`: Orchestrates installation of essential tools (utility scripts, pyenv, fzf, ctags, cargo, and optional Homebrew/version managers/AI tools)
   - Individual installers: `install-pyenv.sh`, `install-fzf.sh`, `install-universal-ctags.sh`, `install-cargo.sh`, `install-homebrew.sh`, `install-jenv.sh`, `install-gvm.sh`, `install-nvm.sh`, `install-rbenv.sh`, `install-ai-code-agents.sh`
   - Additional tools: `install-bc.sh`, `install-golang.sh`, `install-google-java-format.sh`, `install-hack-nerd-font.sh`, `install-lazyssh.sh`, `install-miniconda.sh`, `install-neovim.sh`, `install-nvim-python.sh`, `install-sdcv.sh`, `install-shfmt.sh`, `install-uv.sh`, `install-lang-formatters.sh`, `install-lsp.sh`
   - `claude-code-router.json`: Configuration for AI code routing

3. **Module Structure**
   - Each module (zsh/, nvim/, tmux/, emacs/, vifm/, misc/, lisp/, alacritty/) has its own `install.sh` script
   - Modules follow XDG Base Directory specification
   - All modules load `lib/shmisc.sh` for common utilities

4. **Custom Tools (`bin/`)**
   - `dotme-xxx` series of personalized development tools
   - Enhanced wrappers for common utilities (Google Java Format, GPG, etc.)
   - Tools are installed to `~/.local/bin`
   - Includes: `dotme-decrypt-zshenv`, `dotme-google-java-format`, `dotme-gpg`, `dotme-install-python`, `dotme-rsync-parallel`, `dotme-run-container`, `ccr_wrapper.sh`

5. **Additional Directories**
   - `kitty/`: Kitty terminal emulator configuration (not in default install_all.sh)
   - `setups/`: Additional setup scripts
   - `termux/`: Termux-specific configurations for Android
   - `assets/`: Project assets including screenshots

### Key Design Principles

- **XDG Compliance**: Configurations follow XDG Base Directory specification
- **Modular Installation**: Each component can be installed independently
- **Prerequisite Management**: Essential tools are auto-installed before components
- **Enhanced Error Handling**: All scripts use strict mode (`set -euo pipefail`)
- **Cross-Platform Support**: Works on macOS and Linux with platform-specific adjustments

### Development Environment Features

- **Zsh**: Modern configuration with Zinit plugin manager, proxy support
- **Neovim**: Lazy.nvim plugin manager, LSP support, language formatters
- **Tmux**: Terminal multiplexer with optimized configurations
- **Emacs**: Configuration with plugins and Lisp development environment
- **Vifm**: Vi file manager with custom configurations
- **Alacritty**: GPU-accelerated terminal emulator (included in full installation)
- **Lisp**: Common Lisp development environment with SBCL completions
- **Kitty**: Modern terminal emulator (available but not in default install_all.sh)
- **AI Code Agents**: Optional integration with AI development tools (requires Node.js >= 20)
- **Version Managers**: Support for pyenv, jenv (Java), gvm (Go), nvm (Node), rbenv (Ruby)
- **Language Tools**: Formatters, LSP support, ctags, and various development utilities

## Testing Changes

When making changes to installation scripts:

1. Test individual module installations first
2. Verify prerequisite installation works correctly
3. Check both symlink (`-s`) and copy (`-f`) installation modes
4. Test clean mode (`-c`) for proper removal
5. Ensure all scripts have proper error handling and exit codes

## Common Workflows

### Adding New Modules
1. Create module directory with `install.sh` script
2. Source `lib/shmisc.sh` for utilities
3. Follow existing patterns for XDG compliance
4. Add module to `COMPONENTS` array in `install_all.sh` if needed
5. Current modules in install_all.sh: zsh, tmux, nvim, emacs, vifm, misc, lisp, alacritty
6. Current modules in install_basics.sh: zsh, tmux, nvim

### Updating Utility Scripts
1. Modify scripts in `bin/` directory
2. Update documentation in `bin/README.md`
3. Test with various environment configurations
4. Ensure cross-platform compatibility

### Modifying Essential Tools
1. Update `lib/install-essentials.sh` for new tools/features
2. Test with different environment variable combinations
3. Verify optional feature flags work correctly
4. Update script header documentation

### Library Scripts Reference
The `lib/` directory contains modular installation scripts that can be used independently:

**Core Tools:**
- `install-pyenv.sh`: Python version manager
- `install-fzf.sh`: Fuzzy finder
- `install-universal-ctags.sh`: Code navigation tool
- `install-cargo.sh`: Rust toolchain

**Package Managers:**
- `install-homebrew.sh`: Homebrew package manager (with mirror configuration)
- `install-miniconda.sh`: Miniconda Python distribution

**Version Managers:**
- `install-jenv.sh`: Java version manager
- `install-gvm.sh`: Go version manager
- `install-nvm.sh`: Node.js version manager
- `install-rbenv.sh`: Ruby version manager

**Development Tools:**
- `install-neovim.sh`: Neovim editor
- `install-nvim-python.sh`: Python support for Neovim
- `install-lang-formatters.sh`: Language formatters
- `install-lsp.sh`: Language Server Protocol support
- `install-shfmt.sh`: Shell script formatter

**Utilities:**
- `install-bc.sh`: Calculator utility
- `install-golang.sh`: Go language support
- `install-google-java-format.sh`: Java code formatter
- `install-hack-nerd-font.sh`: Nerd font installation
- `install-lazyssh.sh`: SSH utility
- `install-sdcv.sh`: Dictionary tool
- `install-uv.sh`: Python package installer

**AI Integration:**
- `install-ai-code-agents.sh`: AI-powered development tools
- `claude-code-router.json`: AI code routing configuration

**Core Library:**
- `shmisc.sh`: Core shell utility library (logging, path utilities, system detection)
