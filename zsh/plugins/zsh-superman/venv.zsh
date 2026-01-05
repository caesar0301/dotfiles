# =============================
# Development Environment Setup
# =============================

# Add to PATH if directory exists and not already present
_prepend_to_path() {
  local dir=$1
  if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
}

# --- Python Environment ---
# Initialize pyenv if available
_init_pyenv() {
  if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    _prepend_to_path "$PYENV_ROOT/bin"
    if command -v pyenv &>/dev/null; then
      eval "$(pyenv init -)"
    fi
  fi
}
_init_pyenv

# --- Ruby Environment ---
# Initialize rbenv if available
_init_rbenv() {
  if [ -d "$HOME/.rbenv" ]; then
    export RBENV_ROOT="$HOME/.rbenv"
    _prepend_to_path "$RBENV_ROOT/bin"
    if command -v rbenv &>/dev/null; then
      eval "$(rbenv init - zsh)"
    fi
  fi
}
_init_rbenv

# --- Go Environment ---
_init_go_env() {
  if command -v go &>/dev/null; then
    export GOROOT=$(go env GOROOT)
    export GOPATH=$(go env GOPATH)
    export GO111MODULE=on
    export GOPROXY=https://goproxy.cn,direct
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
  fi
}
_init_go_env

# --- Java Environment ---
_init_jenv() {
  if [ -d "$HOME/.jenv" ]; then
    _prepend_to_path "$HOME/.jenv/bin"
    if command -v jenv &>/dev/null; then
      eval "$(jenv init -)"
    fi
  fi
}
_init_jenv

# --- Haskell Environment ---
_init_haskell_env() {
  if [ -d "$HOME/.ghcup" ]; then
    _prepend_to_path "$HOME/.ghcup/bin"
  fi
  if [ -d "$HOME/.cabal" ]; then
    _prepend_to_path "$HOME/.cabal/bin"
  fi
}
_init_haskell_env

# --- Lisp Environment ---
# Initialize Lisp/Quicklisp/Roswell/Allegro CL if available
_init_lisp_env() {
  # Roswell
  if [ -d "$HOME/.roswell" ]; then
    _prepend_to_path "$HOME/.roswell/bin"
  fi

  # Quicklisp home
  if [ -d "$HOME/quicklisp" ]; then
    export QUICKLISP_HOME=${HOME}/quicklisp
  fi

  # Allegro CL
  local ACL_HOME=${HOME}/.local/share/acl
  if [ -d "$ACL_HOME" ]; then
    _prepend_to_path "$ACL_HOME"
  fi

  # rlwrap for better REPL experience
  if command -v rlwrap &>/dev/null; then
    alias sbcl="rlwrap -f $HOME/.config/rlwrap/lisp_completions --remember sbcl"
    alias alisp="rlwrap -f $HOME/.config/rlwrap/lisp_completions --remember alisp"
    alias mlisp="rlwrap -f $HOME/.config/rlwrap/lisp_completions --remember mlisp"
  fi
}
_init_lisp_env

# --- node Environment ---
# Initialize nvm if available
_init_node_env() {
  if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  fi
}
_init_node_env
