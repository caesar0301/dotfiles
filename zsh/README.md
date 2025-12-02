# Zsh dotfiles

## Prerequisites

* Zsh v5.0+

## Installation

Clone the whole repo

```bash
git clone --depth 1 https://github.com/caesar0301/cool-dotfiles.git ~/.dotfiles
```

Install zsh configurations to `~/.config/zsh` by running:

```bash
sh zsh/install.sh
```

By default, soft links would be created for future convenient update. You can change the default behaviour with option `-f` to copy all configurations to `~/.config/zsh`.

The installer would skip existing `~/.zshrc`. In this scenario, you can append below line to piggyback this repo to your existing zsh configs:

```
[ -s "$HOME/.config/zsh/init.zsh" ] && source "$HOME/.config/zsh/init.zsh"
```

Zsh plugins are managed by [zinit project](https://github.com/zdharma-continuum/zinit.git).

## Configuration Structures

* `~/.config/zsh`: Default installation of all configs
* `~/.config/zsh/init.zsh`: The starting initialization
* `~/.config/zsh/bundles`: Bundled convenient settings
* `~/.config/zsh/plugins`: Extendable plugins compatible with `oh-my-zsh` plugin folder structure

## Useful Shortcuts

* `zshld`: Reload all zsh configs.
* `zshup`: Update the whole zinit plugins and custom `~/.config/zsh/plugins`.

## Configurable ENV vars

### Shell Configuration
* `SHELLPROXY_URL`: proxy address used by `shell-proxy` plugin.

### Installation Configuration

The installer supports optional environment variables to control which dependencies are installed:

#### Core Dependencies
By default, the installer installs:
- Zsh shell binary (`install_zsh`)
- Zinit plugin manager (`install_zinit`)
- Zsh plugins (`install_zsh_plugins`)
- Python version manager (`install_pyenv`)

The installer will also automatically change your default shell to zsh if it's not already set.

#### Optional Dependencies

**Homebrew Installation:**
```bash
# Enable Homebrew installation
INSTALL_HOMEBREW=1 sh zsh/install.sh
```

**Development Environment Tools:**
Enable Java, Go, and Node version managers:
```bash
# Install jenv, gvm, and nvm
INSTALL_EXTRA_VENV=1 sh zsh/install.sh
```

This installs:
- `install_jenv` - Java version manager
- `install_gvm` - Go version manager  
- `install_nvm` - Node version manager

**AI Code Agents:**
Enable AI code agents (requires npm >= 20):
```bash
# Install AI code agents
INSTALL_AI_CODE_AGENTS=1 sh zsh/install.sh
```

**Custom Development Plugins:**
Enable custom development plugins (zsh-caesardev):
```bash
# Install custom development plugins
INSTALL_CAESARDEV=1 sh zsh/install.sh
```

**Combined Examples:**
```bash
# Install with Homebrew and development tools
INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 sh zsh/install.sh

# Or set in your environment
export INSTALL_HOMEBREW=1
export INSTALL_EXTRA_VENV=1
export INSTALL_AI_CODE_AGENTS=1
sh zsh/install.sh

# Full installation with all optional components
INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 INSTALL_AI_CODE_AGENTS=1 sh zsh/install.sh
```
