# cool-dotfiles

Personal collection of dotfiles for a modern development environment.

![Screenshot](assets/screenshot.png)

## Quick Start

Clone this repository:

```bash
git clone --depth=1 https://github.com/caesar0301/cool-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## Installation Options

### Basic Installation (Recommended)

Install essential components: Zsh, development tools, Tmux, and Neovim:

```bash
./install_basics.sh
```

### Full Installation

Install all modules including Emacs, Vifm, and misc configurations:

```bash
./install_all.sh
```

### Installation Flags

| Flag | Description |
|------|-------------|
| `-s` | Use symlinks (default) |
| `-f` | Force copy instead of symlinks |
| `-c` | Clean/remove configurations |

## Modules

| Module | Description | Documentation |
|--------|-------------|---------------|
| `essentials/` | Development tools (pyenv, dotme-xxx utilities) | [README](essentials/README.md) |
| `zsh/` | Zsh shell configuration with Zinit | [README](zsh/README.md) |
| `nvim/` | Neovim configuration with LSP support | [README](nvim/README.md) |
| `tmux/` | Tmux terminal multiplexer | [README](tmux/README.md) |
| `emacs/` | Emacs configuration | [README](emacs/README.md) |
| `vifm/` | Vi file manager | - |
| `misc/` | Kitty terminal, SBCL completions | - |

## Install Individual Modules

```bash
# Essential development tools
sh essentials/install.sh

# Zsh configuration
sh zsh/install.sh

# Neovim
sh nvim/install.sh

# Tmux
sh tmux/install.sh

# Emacs
sh emacs/install.sh
```

## Optional Features

Enable additional tools via environment variables:

```bash
# Install with Homebrew
INSTALL_HOMEBREW=1 sh essentials/install.sh

# Install Java/Go/Node version managers
INSTALL_EXTRA_VENV=1 sh essentials/install.sh

# Install AI code agents (requires Node.js >= 20)
INSTALL_AI_CODE_AGENTS=1 sh essentials/install.sh

# Full installation with all optional features
INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 INSTALL_AI_CODE_AGENTS=1 ./install_basics.sh
```

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

MIT
