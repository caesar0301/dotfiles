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
- Python version manager (`install_pyenv`)

#### Optional Dependencies

**Homebrew Installation:**
```bash
# Enable Homebrew installation
INSTALL_HOMEBREW=1 sh zsh/install.sh
```

**Optional Development Tools:**
To install optional dependencies, edit `zsh/install.sh` and uncomment the desired tools in the `optional_deps` array:
```bash
local optional_deps=(
  "install_jenv"     # Java version manager
  "install_gvm"      # Go version manager
  "install_nvm"      # Node version manager
)
```

Available optional dependencies:
- `install_jenv` - Java version manager
- `install_gvm` - Go version manager  
- `install_nvm` - Node version manager

**Example:**
```bash
# Install with Homebrew
INSTALL_HOMEBREW=1 sh zsh/install.sh

# Or set in your environment
export INSTALL_HOMEBREW=1
sh zsh/install.sh
```
