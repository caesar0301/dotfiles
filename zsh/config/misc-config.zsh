
# extra paths
export PATH=$HOME/.dotfiles/bin:$HOME/.local/bin:$PATH

# Homebrew (official Linux prefix first, then user-local, then standard macOS locations)
for _brew_prefix in /home/linuxbrew/.linuxbrew "$HOME/.local/homebrew" /opt/homebrew /usr/local; do
  if [[ -x "$_brew_prefix/bin/brew" ]]; then
    eval "$("$_brew_prefix/bin/brew" shellenv)" 2>/dev/null || true
    break
  fi
done
unset _brew_prefix

# respect fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
