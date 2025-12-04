#############################################################
# Filename: ~/.config/zsh/init.zsh
#     About: init script of zsh
#     Maintained by xiaming.cxm, updated 2023-05-11
#
# Plugins:
#     We recommend extend custom zsh settings via plugins.
#     You can put any plugin or zsh-suffixed scripts in
#     ~/.config/zsh/plugins to make them work.
#############################################################
ZSH_CONFIG_DIR="${HOME}/.config/zsh"
ZSH_PLUGIN_DIR="${ZSH_CONFIG_DIR}/plugins/"
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
ZINIT_WORKDIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
ZINIT_PROFILING="${ZINIT_PROFILING:-0}"

# Enable profiling to identify slow sections
if [[ x$ZINIT_PROFILING == "x1" ]]; then 
  zmodload zsh/zprof
fi

source "${ZINIT_HOME}/zinit.zsh"
source "${ZSH_CONFIG_DIR}/_helper.zsh"

# extra envs
export ZSH_CONFIG_DIR=${ZSH_CONFIG_DIR}
export ZSH_PLUGIN_DIR=${ZSH_PLUGIN_DIR}

###------------------------------------------------
### ZI MANAGER
###------------------------------------------------

autoload -Uz _zi
[[ -v _comps ]] && _comps[zi]=_zi

# Oh-My-Zsh libs
zinit ice wait lucid
zinit snippet OMZL::clipboard.zsh
zinit ice wait lucid
zinit snippet OMZL::completion.zsh
zinit ice wait lucid
zinit snippet OMZL::functions.zsh
zinit ice wait lucid
zinit snippet OMZL::spectrum.zsh

# Theme
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# Efficiency
zinit ice pick"z.sh" wait lucid
zinit load rupa/z
zinit ice wait lucid
zinit snippet OMZP::vi-mode
zinit ice wait lucid
zinit snippet OMZP::alias-finder

# Auto command completion
zinit ice wait lucid
zinit light zsh-users/zsh-completions

# Fish-like auto suggestions on history
zinit ice lucid wait='0' atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# flatpak auto completion
zinit ice wait lucid
zinit light bilelmoussaoui/flatpak-zsh-completion

# Command output highlighting
zinit ice pick "zsh-syntax-highlighting.zsh" wait lucid
zinit light zsh-users/zsh-syntax-highlighting

# User custom plugins
_zinit_ice_custom_extensions

autoload -U parseopts zargs zcalc zed zmv
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -u
else
  compinit -C -u
fi
zinit cdreplay -q

###------------------------------------------------
### ZSH ENHANCEMENT
###------------------------------------------------

# disable Ctrl+D to close session
setopt IGNORE_EOF

# enable Ctrl+s and Ctrl+q
stty start undef
stty stop undef
setopt noflowcontrol

# zsh history
export HISTFILE=$HOME/.zhistory
export HISTSIZE=9999
export SAVEHIST=9999

# clicolor
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# extra paths
export PATH=$HOME/.local/bin:$HOME/.dotfiles/bin:$PATH
export RLWRAP_HOME=${HOME}/.config/rlwrap
export PATH=$HOME/.npm-global/bin:$PATH

# respect local zshenv
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

# respect fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Show profiling results on startup
if [[ x$ZINIT_PROFILING == "x1" ]]; then 
  zprof
fi
