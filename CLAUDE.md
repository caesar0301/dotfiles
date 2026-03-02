# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles collection (`cool-dotfiles`) for setting up a modern development environment with Zsh, Neovim, Tmux, Emacs, and various development tools. Features automated installation scripts following XDG Base Directory specification.

## Quick Reference

```bash
# Basic installation (Zsh, Tmux, Neovim)
./install_basics.sh

# Full installation (all components)
./install_all.sh

# Selective module installation
./install_all.sh -m zsh,tmux,nvim
./misc/install.sh -m kitty,alacritty

# Code formatting
./format.sh                    # Format shell scripts and Lua files

# Installation flags
-s    Use symlinks (default)
-f    Force copy instead of symlinks
-c    Clean/remove configurations
-m    Install only selected modules
```

## Architecture

### Installation Hierarchy

**Master Orchestrators:**
- `install_all.sh` → Full installation with all optional features (COMPONENTS: zsh, tmux, nvim, emacs, vifm, misc, lisp, alacritty)
- `install_basics.sh` → Core components only (COMPONENTS: zsh, tmux, nvim)
- Both automatically run `lib/install-essentials.sh` as prerequisite

**Prerequisites (`lib/install-essentials.sh`):**
- Always installs: utility scripts (bin/), pyenv, fzf, universal-ctags, cargo, Homebrew, AI code agents
- Optional: `INSTALL_EXTRA_VENV=1` enables jenv, gvm, nvm, rbenv version managers
- `install_all.sh` enables all optional features by default
- `install_basics.sh` uses default settings (no optional version managers)

### Module Structure

Each module (zsh/, nvim/, tmux/, emacs/, vifm/, misc/, lisp/, alacritty/) follows this pattern:
- Has `install.sh` script with `-s`, `-f`, `-c` flags
- Sources `lib/shmisc.sh` for utilities
- Follows XDG Base Directory specification (XDG_DATA_HOME, XDG_CONFIG_HOME, XDG_CACHE_HOME)
- Uses `set -euo pipefail` strict mode

### Core Library (`lib/`)

**Essential Utilities:**
- `shmisc.sh` → Core library with logging, path utilities, system detection, installation helpers
- `install-essentials.sh` → Orchestrates all prerequisite tools

**Individual Installers:** Modular scripts for each tool (pyenv, fzf, ctags, cargo, Homebrew, neovim, language formatters, version managers, etc.). Can be used independently.

### Custom Tools (`bin/`)

`dotme-xxx` series of personalized development tools installed to `~/.local/bin`:
- `dotme-google-java-format` → Enhanced Google Java Format wrapper
- `dotme-gpg` → GPG helper with key alias support
- `dotme-decrypt-zshenv` → Decrypt local environment files
- `dotme-install-python`, `dotme-rsync-parallel`, `dotme-run-container`, `ccr_wrapper.sh`

See `bin/README.md` for detailed documentation.

### Key Design Patterns

**All installation scripts:**
1. Use `set -euo pipefail` for strict error handling
2. Source `lib/shmisc.sh` for common utilities
3. Use XDG environment variables with fallbacks
4. Support installation flags (-s, -f, -c, -m where applicable)
5. Use logging functions: `info()`, `warn()`, `error()`, `success()`

**Module install scripts pattern:**
```bash
# Resolve script directory
THISDIR=$(dirname "$(realpath "$0")")

# Load utilities with validation
source "$THISDIR/../lib/shmisc.sh" || { printf "✗ Failed to load shmisc.sh\n" >&2; exit 1; }

# Define XDG paths
readonly XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

# Install configuration files
install_file_pair "$source_file" "$dest_file"
```

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

## Important Notes

### XDG Compliance
- All configurations follow XDG Base Directory specification
- XDG_DATA_HOME defaults to `~/.local/share`
- XDG_CONFIG_HOME defaults to `~/.config`
- XDG_CACHE_HOME defaults to `~/.cache`

### Cross-Platform Compatibility
- Scripts detect OS using `is_linux` and `is_macos` functions from shmisc.sh
- Platform-specific adjustments are handled automatically
- Neovim checks kernel version on Linux to disable incompatible plugins

### Path Management
- Utility scripts in `bin/` are added to PATH via `zsh/init.zsh`
- Restart shell after installation: `exec $SHELL`
- Tools are installed to `~/.local/bin` for compatibility

### Format Script (`format.sh`)
- Formats shell scripts with shfmt (excluding zsh-specific files that use unsupported syntax)
- Formats Lua files in nvim/ with stylua
- Zsh files excluded due to glob qualifiers and zsh parameter expansion

## Development Environment Components

- **Zsh**: Zinit plugin manager, proxy support, custom plugins in `zsh/plugins/`
- **Neovim**: Lazy.nvim plugin manager, LSP support, kernel version compatibility checks, language formatters
- **Tmux**: Terminal multiplexer with optimized configurations
- **Emacs**: Configuration with plugins and Lisp development environment
- **Vifm**: Vi file manager
- **Misc**: Kitty and Alacritty terminals, SBCL completions (supports selective installation via `-m`)
- **Lisp**: Common Lisp development with SBCL
- **AI Code Agents**: Requires Node.js >= 20 and npm >= 20
