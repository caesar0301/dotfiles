#!/usr/bin/env zsh

# =====================
# Git Utilities for zsh-caesardev
# =====================
# This file combines git aliases, functions, and LFS utilities
# from multiple sources into a single, organized module.

# =====================
# Core Git Aliases
# =====================

# Basic git commands
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbm='git branch --move'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'

# Commit aliases
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gca!='git commit --verbose --all --amend'
alias gcan!='git commit --verbose --all --no-edit --amend'
alias gcans!='git commit --verbose --all --signoff --no-edit --amend'
alias gcann!='git commit --verbose --all --date=now --no-edit --amend'
alias gc!='git commit --verbose --amend'
alias gcn='git commit --verbose --no-edit'
alias gcn!='git commit --verbose --no-edit --amend'
alias gcmm='git commit -m'
alias gcmsg='git commit --message'
alias gcsm='git commit --signoff --message'
alias gcam='git commit --all --message'
alias gcas='git commit --all --signoff'
alias gcasm='git commit --all --signoff --message'
alias gcs='git commit --gpg-sign'
alias gcss='git commit --gpg-sign --signoff'
alias gcssm='git commit --gpg-sign --signoff --message'
alias gcfu='git commit --fixup'

# Checkout aliases
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gcb='git checkout -b'
alias gcB='git checkout -B'
alias gcd='git checkout $(git_develop_branch)'
alias gcm='git checkout $(git_main_branch)'

# Diff aliases
alias gd='git diff --ws-error-highlight=all'
alias gdc='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdup='git diff @{upstream}'
alias gdt='git diff-tree --no-commit-id --name-only -r'

gdbf() {
  local n=${1:-1}
  git diff --binary HEAD~"$n"
}

# Fetch and pull aliases
alias gf='git fetch'
alias gfo='git fetch origin'
alias gfa='git fetch --all --tags --prune --jobs=10'

alias gl='git pull'
alias gpr='git pull --rebase'
alias gprv='git pull --rebase -v'
alias gpra='git pull --rebase --autostash'
alias gprav='git pull --rebase --autostash -v'
alias gprom='git pull --rebase origin $(git_main_branch)'
alias gpromi='git pull --rebase=interactive origin $(git_main_branch)'
alias gprum='git pull --rebase upstream $(git_main_branch)'
alias gprumi='git pull --rebase=interactive upstream $(git_main_branch)'

# Push aliases
alias gp='git push'
alias gpd='git push --dry-run'
alias gpv='git push --verbose'
alias gpoat='git push origin --all && git push origin --tags'
alias gpod='git push origin --delete'
alias gpu='git push upstream'

# Force push with lease (safer than force)
alias gpf!='git push --force'
alias gpf='git push --force-with-lease --force-if-includes'

# Log aliases
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias glp='_git_log_prettily'
alias gll='git log | less'
alias ghf="git log --follow -p --"

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

# Stash aliases
alias gstall='git stash --all'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --patch'
alias gsta='git stash push'
alias gstu='gsta --include-untracked'

# Merge and rebase aliases
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms="git merge --squash"
alias gmff="git merge --ff-only"
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grbd='git rebase $(git_develop_branch)'
alias grbm='git rebase $(git_main_branch)'
alias grbom='git rebase origin/$(git_main_branch)'
alias grbum='git rebase upstream/$(git_main_branch)'

# Remote aliases
alias gr='git remote'
alias grv='git remote --verbose'
alias gra='git remote add'
alias grrm='git remote remove'
alias grmv='git remote rename'
alias grset='git remote set-url'
alias grup='git remote update'

# Tag aliases
alias gta='git tag --annotate'
alias gts='git tag --sign'
alias gtv='git tag | sort -V'

# Worktree aliases
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'

# Utility aliases
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias gcf='git config --list'
alias ghh='git help'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias gfg='git ls-files | grep'
alias gcount='git shortlog --summary --numbered'
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'
alias grf='git reflog'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gclean='git clean --interactive -d'
alias gcl='git clone --recurse-submodules'
alias gclf='git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules'
alias gbl='git blame -w'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsn='git bisect new'
alias gbso='git bisect old'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gap='git apply'
alias gapt='git apply --3way'
alias gam='git am'
alias gama='git am --abort'
alias gamc='git am --continue'
alias gamscp='git am --show-current-patch'
alias gams='git am --skip'
alias gsw='git switch'
alias gswc='git switch --create'
alias gswd='git switch $(git_develop_branch)'
alias gswm='git switch $(git_main_branch)'
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gtl='gtl(){ git tag --sort=-v:refname -n --list "${1}*" }; noglob gtl'
alias gk='\gitk --all --branches &!'
alias gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'

# =====================
# Git LFS Aliases
# =====================

alias glfsi='git lfs install'
alias glfst='git lfs track'
alias glfsls='git lfs ls-files'
alias glfsmi='git lfs migrate import --include='

# =====================
# Core Git Functions
# =====================

# Git wrapper that prevents interference with other git processes
function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

# Get current branch name
function current_branch() {
  git_current_branch
}

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
function git_current_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# Outputs the name of the previously checked out branch
# Usage example: git pull origin $(git_previous_branch)
function git_previous_branch() {
  local ref
  ref=$(__git_prompt_git rev-parse --quiet --symbolic-full-name @{-1} 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]] || [[ -z $ref ]]; then
    return  # no git repo or non-branch previous ref
  fi
  echo ${ref#refs/heads/}
}

# Output the name of the root directory of the git repository
# Usage example: $(git_repo_name)
function git_repo_name() {
  local repo_path
  if repo_path="$(__git_prompt_git rev-parse --show-toplevel 2>/dev/null)" && [[ -n "$repo_path" ]]; then
    echo ${repo_path:t}
  fi
}

# Outputs the name of the current user
# Usage example: $(git_current_user_name)
function git_current_user_name() {
  __git_prompt_git config user.name 2>/dev/null
}

# Outputs the email of the current user
# Usage example: $(git_current_user_email)
function git_current_user_email() {
  __git_prompt_git config user.email 2>/dev/null
}

# Check for develop and similarly named branches
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return 0
    fi
  done

  echo develop
  return 1
}

# Check if main exists and use instead of master
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

# Rename branch locally and remotely
function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"
    return 1
  fi

  # Rename branch locally
  git branch -m "$1" "$2"
  # Rename branch in origin remote
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

# Pull and push functions
function ggl() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git pull origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git pull origin "${b:=$1}"
  fi
}

function ggp() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git push origin "${b:=$1}"
  fi
}

function ggpnp() {
  if [[ "$#" == 0 ]]; then
    ggl && ggp
  else
    ggl "${*}" && ggp "${*}"
  fi
}

function ggu() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git pull --rebase origin "${b:=$1}"
}

function ggf() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git push --force origin "${b:=$1}"
}

function ggfl() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git push --force-with-lease origin "${b:=$1}"
}

# Clone and cd function
function gccd() {
  setopt localoptions extendedglob

  # get repo URI from args based on valid formats: https://git-scm.com/docs/git-clone#URLS
  local repo="${${@[(r)(ssh://*|git://*|ftp(s)#://*|http(s)#://*|*@*)(.git/#)#]}:-$_}"

  # clone repository and exit if it fails
  command git clone --recurse-submodules "$@" || return

  # if last arg passed was a directory, that's where the repo was cloned
  # otherwise parse the repo URI and use the last part as the directory
  [[ -d "$_" ]] && cd "$_" || cd "${${repo:t}%.git/#}"
}

# Diff function with view
function gdv() { git diff -w "$@" | view - }

# Diff without lock files
function gdnolock() {
  git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}

# Pretty log function
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}

# WIP (Work in Progress) functions
function gwip() {
  git add -A
  git rm $(git ls-files --deleted) 2> /dev/null
  git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
}

function gunwip() {
  git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1
}

# Similar to `gunwip` but recursive "Unwips" all recent `--wip--` commits not just the last one
function gunwipall() {
  local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H)

  # Check if a commit without "--wip--" was found and it's not the same as HEAD
  if [[ "$_commit" != "$(git rev-parse HEAD)" ]]; then
    git reset $_commit || return 1
  fi
}

# Warn if the current branch is a WIP
function work_in_progress() {
  command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- "--wip--" && echo "WIP!!"
}

# =====================
# Git LFS Functions
# =====================

# Push LFS objects for current branch
function gplfs() {
  local b="$(git_current_branch)"
  git lfs push origin "$b" --all
}

# =====================
# Submodule Utilities
# =====================

# Pull all submodules to latest master
function git-submodule-latest() {
  git submodule foreach git pull origin master
}

# Reset and clean repo and submodules
function git-reset-recurse-submodules() {
  git reset --hard
  git submodule sync --recursive
  git submodule update --init --force --recursive
  git clean -ffdx
  git submodule foreach --recursive git clean -ffdx
}

# Submodule aliases
alias gsi='git submodule init'
alias gsu='git submodule update'
alias gsur="git submodule update --init --recursive"
alias gsrh="git submodule foreach --recursive git reset --hard"

# =====================
# Prune Utilities
# =====================

# Remove deleted files from git cache
function git-prune-cache() {
  FILES=$(git ls-files -d)
  if [[ -n $FILES ]]; then
    git rm $FILES
  else
    echo "No deleted files"
  fi
}

# Remove git submodule
function git-prune-submodule() {
  local SUBMODULE=$1
  if [[ -z $SUBMODULE ]]; then
    echo "Usage: git-prune-submodule <submodule_path>" >&2
    return 1
  fi
  git submodule deinit -f -- "$SUBMODULE"
  rm -rf .git/modules/$SUBMODULE
  git rm -f $SUBMODULE
}

# Remove a branch locally and remotely
function git-prune-branch() {
  if [ $# -eq 0 ]; then
    echo "Usage: git-prune-branch <branch_name>" >&2
    echo "Removes specified branch locally and from origin remote"
    return 1
  fi
  local branch="$1"
  local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ "$current_branch" = "$branch" ]; then
    echo -e "\033[1;31mError: Cannot delete current branch ($branch)\033[0m"
    echo "Switch to another branch first."
    return 1
  fi
  echo -e "\033[1;33mRemoving branch: $branch\033[0m"
  if git branch -D "$branch" >/dev/null 2>&1; then
    echo -e "\033[1;32mLocal branch removed\033[0m"
  else
    echo -e "\033[1;31mLocal branch removal failed (maybe already gone?)\033[0m"
  fi
  if git push origin --delete "$branch" >/dev/null 2>&1; then
    echo -e "\033[1;32mRemote branch removed from origin\033[0m"
  else
    echo -e "\033[1;31mRemote branch removal failed (maybe it didn't exist?)\033[0m"
  fi
  git fetch --prune --quiet >/dev/null 2>&1
}

# Branch cleanup functions
function gbda() {
  git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2>/dev/null
}

# Copied and modified from James Roeder (jmaroeder) under MIT License
# https://github.com/jmaroeder/plugin-git/blob/216723ef4f9e8dde399661c39c80bdf73f4076c4/functions/gbda.fish
function gbds() {
  local default_branch=$(git_main_branch)
  (( ! $? )) || default_branch=$(git_develop_branch)

  git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch; do
      local merge_base=$(git merge-base $default_branch $branch)
      if [[ $(git cherry $default_branch $(git commit-tree $(git rev-parse $branch\^{tree}) -p $merge_base -m _)) = -* ]]; then
        git branch -D $branch
      fi
    done
}

# Gone branch aliases
alias gbgd='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '"'"'{print $1}'"'"' | xargs git branch -d'
alias gbgD='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '"'"'{print $1}'"'"' | xargs git branch -D'
alias gbg='LANG=C git branch -vv | grep ": gone\]"'

# =====================
# Quick Update Utility
# =====================

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

# =====================
# Quick Branch Update
# =====================

# Rebase current branch on top of target branch
git-sync-rebase() {
  if [ -z "$1" ]; then
    echo "Usage: git-sync-rebase <target-branch>"
    return 1
  fi
  target="$1"
  git fetch origin "$target" && \
  git rebase "origin/$target"
}

# Force reset current branch to match target branch
git-sync-reset() {
  if [ -z "$1" ]; then
    echo "Usage: git-sync-reset <target-branch>"
    return 1
  fi
  target="$1"
  git fetch origin "$target" && \
  git reset --hard "origin/$target"
}

# =====================
# Utility Aliases
# =====================

# Set upstream branch
alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease --force-if-includes'

# Pull specific branch aliases
alias ggpull='git pull origin "$(git_current_branch)"'
alias gluc='git pull upstream $(git_current_branch)'
alias glum='git pull upstream $(git_main_branch)'

# Push specific branch aliases
alias ggpush='git push origin "$(git_current_branch)"'

# Restore aliases
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'

# Revert aliases
alias grev='git revert'
alias greva='git revert --abort'
alias grevc='git revert --continue'

# Remove aliases
alias grm='git rm'
alias grmc='git rm --cached'

# SVN aliases (if using git-svn)
alias gsd='git svn dcommit'
alias git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias gsr='git svn rebase'

# Clean and reset aliases
alias gpristine='git reset --hard && git clean --force -dfx'
alias gwipe='git reset --hard && git clean --force -df'
alias groh='git reset origin/$(git_current_branch) --hard'
