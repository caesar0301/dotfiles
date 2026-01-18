# cool-dotfiles

Personal collection of dotfiles for a modern development environment.

![Screenshot](assets/screenshot.png)

## Quick Start

Clone this repository:

```bash
git clone --depth=1 https://github.com/caesar0301/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## Installation Options

### Basic Installation (Recommended)

Install essential components: Zsh, development tools, Tmux, and Neovim:

```bash
./install_basics.sh
```

This automatically installs essential development tools (pyenv, fzf, ctags, cargo, utility scripts) as a prerequisite before installing other components.

### Full Installation

Install all modules including Emacs, Vifm, and misc configurations:

```bash
./install_all.sh
```

This automatically installs essential development tools with **all optional features enabled** (Homebrew, version managers, AI code agents) as a prerequisite before installing other components.

### Installation Flags

| Flag | Description |
|------|-------------|
| `-s` | Use symlinks (default) |
| `-f` | Force copy instead of symlinks |
| `-c` | Clean/remove configurations |

## Modules

| Module | Description | Documentation |
|--------|-------------|---------------|
| `zsh/` | Zsh shell configuration with Zinit | [README](zsh/README.md) |
| `nvim/` | Neovim configuration with LSP support | [README](nvim/README.md) |
| `tmux/` | Tmux terminal multiplexer | [README](tmux/README.md) |
| `emacs/` | Emacs configuration | [README](emacs/README.md) |
| `vifm/` | Vi file manager | - |
| `misc/` | Kitty terminal, SBCL completions | - |

**Note:** Essential development tools (pyenv, fzf, ctags, cargo, utility scripts) are automatically installed as a prerequisite when running `install_basics.sh` or `install_all.sh`. Run `./lib/install-essentials.sh --help` or check the script header for usage details.

## Install Individual Modules

```bash
# Essential development tools (installed automatically as prerequisite)
# Can be run standalone to install/update essentials
./lib/install-essentials.sh

# Zsh configuration
sh zsh/install.sh

# Neovim (automatically installs essentials as prerequisite)
sh nvim/install.sh

# Tmux
sh tmux/install.sh

# Emacs
sh emacs/install.sh
```

## Optional Features

Essential development tools support optional features that can be enabled via environment variables:

```bash
# Install with Homebrew
INSTALL_HOMEBREW=1 ./lib/install-essentials.sh

# Install Java/Go/Node version managers
INSTALL_EXTRA_VENV=1 ./lib/install-essentials.sh

# Install AI code agents (requires Node.js >= 20)
INSTALL_AI_CODE_AGENTS=1 ./lib/install-essentials.sh

# Full installation with all optional features
INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 INSTALL_AI_CODE_AGENTS=1 ./lib/install-essentials.sh
```

**Note:** `./install_all.sh` automatically enables all optional features when installing essentials as a prerequisite. `./install_basics.sh` uses default settings (no optional features).

## Utility Scripts

The `dotme-xxx` series of custom tools are installed to `~/.local/bin`:

| Script | Description |
|--------|-------------|
| `dotme-google-java-format` | Enhanced Google Java Format wrapper |
| `dotme-gpg` | GPG helper with key alias support |
| `dotme-decrypt-zshenv` | Decrypt local environment files |
| `dotme-install-python` | Python installation helper |
| `dotme-rsync-parallel` | Parallel rsync wrapper |
| `dotme-run-container` | Docker container runner |

See [bin/README.md](bin/README.md) for detailed documentation.

## License

MIT License
