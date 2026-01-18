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
The essential tools installer (`lib/install-essentials.sh) is automatically run as a prerequisite:

```bash
# Basic installation (utility scripts + pyenv + fzf + ctags + cargo)
./lib/install-essentials.sh

# With optional components
INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 INSTALL_AI_CODE_AGENTS=1 ./lib/install-essentials.sh
```

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
```

### Code Formatting
```bash
# Format shell scripts (excluding zsh-specific files)
./format.sh
```

## Architecture

### Core Components

1. **Installation Orchestrators**
   - `install_all.sh`: Full installation with all optional features
   - `install_basics.sh`: Minimal installation with core components
   - Both use `lib/install-essentials.sh` as prerequisite

2. **Shared Library (`lib/`)**
   - `shmisc.sh`: Core shell utility library with logging, path utilities, system detection
   - `install-essentials.sh`: Installs pyenv, fzf, ctags, cargo, and optional Homebrew/version managers/AI tools

3. **Module Structure**
   - Each module (zsh/, nvim/, tmux/, emacs/) has its own `install.sh` script
   - Modules follow XDG Base Directory specification
   - All modules load `lib/shmisc.sh` for common utilities

4. **Custom Tools (`bin/`)**
   - `dotme-xxx` series of personalized development tools
   - Enhanced wrappers for common utilities (Google Java Format, GPG, etc.)
   - Tools are installed to `~/.local/bin`

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
- **AI Code Agents**: Optional integration with AI development tools (requires Node.js >= 20)

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