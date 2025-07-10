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

* `SHELLPROXY_URL`: proxy address used by `shell-proxy` plugin.
