# Zsh Configuration

Modern Zsh configuration with Zinit plugin manager and XDG compliance.

## Prerequisites

- Zsh v5.0+

## Installation

Clone the repository:

```bash
git clone --depth 1 https://github.com/caesar0301/cool-dotfiles.git ~/.dotfiles
```

Install Zsh configuration:

```bash
sh zsh/install.sh
```

By default, symlinks are created for convenient updates. Use `-f` to copy files instead:

```bash
sh zsh/install.sh -f
```

## Integrating with Existing Configuration

If you already have a `~/.zshrc`, the installer will skip it. Add this line to your existing config:

```bash
[ -s "$HOME/.config/zsh/init.zsh" ] && source "$HOME/.config/zsh/init.zsh"
```

## Configuration Structure

| Path | Description |
|------|-------------|
| `~/.config/zsh/` | Main configuration directory |
| `~/.config/zsh/init.zsh` | Entry point initialization |
| `~/.config/zsh/plugins/` | Custom plugins (oh-my-zsh compatible) |
| `~/.config/proxy` | Shell proxy configuration |

## What Gets Installed

- **Zsh shell** (if not present)
- **Zinit plugin manager** for efficient plugin loading
- **Custom plugins** from `plugins/` directory
- **Shell proxy configuration**

## Useful Shortcuts

| Command | Description |
|---------|-------------|
| `zshld` | Reload all Zsh configs |
| `zshup` | Update Zinit plugins and custom plugins |

## Environment Variables

### Shell Configuration

| Variable | Description |
|----------|-------------|
| `SHELLPROXY_URL` | Proxy address for `shell-proxy` plugin |

### Installation Options

**Custom Development Plugins:**
```bash
# Install zsh-caesardev plugin
INSTALL_CAESARDEV=1 sh zsh/install.sh
```

## Options

| Flag | Description |
|------|-------------|
| `-f` | Force copy instead of symlink |
| `-s` | Use symlinks (default) |
| `-c` | Clean/remove configuration |
| `-h` | Show help |

## Clean Installation

Remove all Zsh configuration:

```bash
sh zsh/install.sh -c
```

This creates a backup of `~/.zshrc` before removal.

## Development Tools

For development tools (pyenv, homebrew, version managers), see:

- [`essentials/`](../essentials/README.md) - Essential development tools

## Related Modules

- [`essentials/`](../essentials/README.md) - Development tools and utilities
- [`nvim/`](../nvim/README.md) - Neovim configuration
- [`tmux/`](../tmux/README.md) - Tmux configuration
