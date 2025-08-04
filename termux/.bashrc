# Git pull aliases
alias gl='git pull'
alias gpr='git pull --rebase'
alias gprv='git pull --rebase -v'

# Status aliases
alias gst='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'

# Reset aliases
alias grh='git reset'
alias gru='git reset --'
alias grhh='git reset --hard'
alias grhk='git reset --keep'
alias grhs='git reset --soft'
alias grsh="git reset --soft HEAD^ && git reset --hard HEAD"

# Commit and push all modified files with a generated message
function git-quick-update() {
  local modified_files commit_message
  modified_files=$(git diff --name-only && git diff --cached --name-only | sort -u)
  if [ -z "$modified_files" ]; then
    echo "No modified files to commit."
    return 1
  fi
  commit_message="Update:"
  for file in $modified_files; do
    commit_message="$commit_message \"$file\""
  done
  commit_message="$commit_message [skip ci]"

  # Stage the modified files
  git add -u
  if git commit -m "$commit_message" && git push; then
    echo "Changes committed and pushed successfully."
  else
    echo "Failed to commit and push changes."
    return 1
  fi
}

# Quick update alias
alias gqu="git-quick-update"

# Warp aliases
alias warp="cd ~/storage/documents/warpnotes"