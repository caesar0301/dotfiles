# reload zsh configs globally
function zshld {
  myextdir=$(basename $(echo "${ZSH_PLUGIN_DIR}" | sed -E -n "s|(.*[^/])/?|\1|p"))
  if [ -e $ZINIT_WORKDIR/snippets ]; then
    ls -d $ZINIT_WORKDIR/snippets/* | grep "$myextdir" | xargs rm -rf
  fi
  source $HOME/.zshrc
}

# update zinit, plugins, and fix broken completions
function zshup {
  setopt local_options err_return no_unset

  echo "==> Updating zinit"
  zinit self-update

  echo "==> Updating zinit plugins"
  zinit update --all --parallel 4

  echo "==> Updating custom plugins"
  local old_path plugin
  old_path=$(pwd)

  if [[ -d ${ZSH_PLUGIN_DIR} ]]; then
    for plugin in ${ZSH_PLUGIN_DIR}/*; do
      [[ -d ${plugin}/.git ]] || continue
      echo -n "  - ${plugin:t} ... "
      (
        cd "${plugin}" &&
        git reset --hard HEAD -q &&
        git pull -q
      ) && echo "done" || echo "failed"
    done
  fi

  cd "${old_path}"

  # ---- Completion cleanup & rebuild ----
  echo "==> Cleaning broken zsh completions"

  local compdir="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/completions"

  if [[ -d ${compdir} ]]; then
    # Remove broken symlinks only
    find "${compdir}" -xtype l -print -delete 2>/dev/null
  fi

  echo "==> Rebuilding completion cache"
  rm -f ~/.zcompdump*
  autoload -Uz compinit
  compinit -C

  echo "==> Done. Restart shell if completions behave oddly."
}


bingo() {
  local SESSION_NAME="${1:-bingo}"

  # Check if tmux server is already running by listing sessions
  if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Attaching to existing tmux session: $SESSION_NAME"
  else
    echo "Creating new tmux session: $SESSION_NAME"
    tmux new-session -d -s "$SESSION_NAME"
  fi

  # Unset TMUX to allow clean attach
  unset TMUX

  # Attach to the session
  tmux attach -t "$SESSION_NAME"
}

# Load custom extensions under $ZSH_PLUGIN_DIR
_zinit_ice_plugin() {
  plugin_path=$1
  if [ ! -e ${plugin_path} ]; then
    return 1
  fi
  zinit ice wait lucid
  zinit light $plugin_path
}

# Load custom extensions
_zinit_ice_custom_extensions() {
  if [ -e ${ZSH_PLUGIN_DIR} ]; then
    # subdirectory plugins
    for i in $(find ${ZSH_PLUGIN_DIR} -maxdepth 1 -mindepth 1 -type d); do
      _zinit_ice_plugin $i
    done
    # softlink subdirectory plugins
    for i in $(find ${ZSH_PLUGIN_DIR} -maxdepth 1 -mindepth 1 -type l -exec test -d {} \; -print); do
      _zinit_ice_plugin $i
    done
    # plain zsh-file plugins
    for i in $(find ${ZSH_PLUGIN_DIR} -maxdepth 1 -mindepth 1 -type f -name "*.zsh"); do
      _zinit_ice_plugin $i
    done
  fi
}
