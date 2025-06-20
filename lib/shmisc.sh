#!/bin/bash
###################################################
# Shell Utility Library
# https://github.com/caesar0301/cool-dotfiles
#
# Features:
# - XDG base directory support
# - Colored logging functions
# - Path manipulation utilities
# - Package management helpers
# - OS and architecture detection
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

set -euo pipefail

# XDG base directory specification
readonly XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
readonly XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}

# ANSI color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RESET='\033[0m'

# Log levels
readonly LOG_INFO="INFO"
readonly LOG_WARN="WARN"
readonly LOG_ERROR="ERROR"

# Print a formatted log message
# Arguments:
#   $1 - color code
#   $2 - log level
#   $3 - message
print_message() {
  if [ $# -lt 3 ]; then
    printf "${COLOR_RED}[ERROR] Invalid number of arguments to print_message${COLOR_RESET}\n" >&2
    return 1
  fi

  local color_code=$1
  local level=$2
  shift 2
  printf "%b[%s] [%s] %s%b\n" \
    "$color_code" \
    "$(date '+%Y-%m-%dT%H:%M:%S')" \
    "$level" \
    "$*" \
    "$COLOR_RESET"
}

# Common usage function for install scripts
# Arguments:
#   $1 - script name (optional, defaults to install.sh)
#   $2 - additional options (optional)
# Example:
#   usage_me "install.sh" "[-d] [-v]"
usage_me() {
  local script_name=${1:-"install.sh"}
  local additional_opts=${2:-""}
  local opts="[-f] [-s] [-c]"
  if [ -n "$additional_opts" ]; then
    opts="$opts $additional_opts"
  fi

  echo "Usage: $script_name $opts"
  echo "  -f copy and install"
  echo "  -s soft link install"
  echo "  -c cleanse install"
  if [ -n "$additional_opts" ]; then
    echo "  $additional_opts"
  fi
}

# Log an info message
# Arguments:
#   $@ - message
info() {
  print_message "$COLOR_GREEN" "$LOG_INFO" "$@"
}

# Log a warning message
# Arguments:
#   $@ - message
warn() {
  print_message "$COLOR_YELLOW" "$LOG_WARN" "$@" >&2
}

# Log an error message and exit
# Arguments:
#   $@ - message
error() {
  print_message "$COLOR_RED" "$LOG_ERROR" "$@" >&2
  exit 1
}

# Get the absolute path of the current script's directory
# Returns:
#   Absolute path to the script's directory
abspath() {
  local script_path
  if ! script_path=$(realpath "$0"); then
    error "Failed to resolve script path"
  fi
  dirname "$script_path"
}

# Get the absolute path of the current script file
# Returns:
#   Absolute path to the script file
absfilepath() {
  local dir file
  if ! dir=$(cd "$(dirname "$0")" && pwd); then
    error "Failed to resolve directory path"
  fi
  file=$(basename "$0")
  echo "$dir/$file"
}

# Create a directory if it doesn't exist
# Arguments:
#   $1 - directory path
create_dir() {
  if [ $# -ne 1 ]; then
    error "create_dir: requires exactly one argument"
  fi

  local dir=$1
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
}

# Create a temporary directory and set cleanup trap
# Returns:
#   Path to the created temporary directory
get_temp_dir() {
  local temp_dir
  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TEMP_DIR"' EXIT
  echo "$TEMP_DIR"
}

# Check if a command exists in PATH
# Arguments:
#   $1 - command name
# Returns:
#   0 if command exists, 1 otherwise
checkcmd() {
  if [ $# -ne 1 ]; then
    error "checkcmd: requires exactly one argument"
  fi
  command -v "$1" >/dev/null 2>&1
}

# Install Python packages with pip
# Arguments:
#   $@ - package names
pip_install_lib() {
  if [ $# -eq 0 ]; then
    error "pip_install_lib: requires at least one package name"
  fi
  if ! checkcmd pip; then
    error "pip is not installed"
  fi
  if ! pip install --user "$@"; then
    error "Failed to install pip packages: $*"
  fi
}

# Install Go packages
# Arguments:
#   $@ - package paths
go_install_lib() {
  if [ $# -eq 0 ]; then
    error "go_install_lib: requires at least one package path"
  fi
  if ! checkcmd go; then
    error "go is not installed"
  fi
  if ! go install "$@"; then
    error "Failed to install Go packages: $*"
  fi
}

# Install R packages
# Arguments:
#   $@ - package names
rlang_install_lib() {
  if [ $# -eq 0 ]; then
    error "rlang_install_lib: requires at least one package name"
  fi
  if ! checkcmd Rscript; then
    error "R is not installed"
  fi
  if ! Rscript -e "install.packages(c('$*'), repos='https://cloud.r-project.org/')"; then
    error "Failed to install R packages: $*"
  fi
}

# Check and ensure sudo access with timeout
# Arguments:
#   $1 - optional sudo prompt message
# Returns:
#   0 if sudo access granted, exits with error otherwise
check_sudo_access() {
  local prompt timeout_mins=5
  prompt=${1:-"[sudo] Enter password for sudo access: "}

  # Reset sudo timeout
  if ! sudo -v -p "$prompt"; then
    error "Failed to get sudo access"
  fi

  # Keep sudo alive in the background
  while true; do
    sudo -n true
    sleep $((timeout_mins * 60 / 2))
    kill -0 "$$" || exit
  done 2>/dev/null &
}

# Get normalized operating system name
# Returns:
#   'linux', 'darwin', or exits with error for unsupported OS
get_os_name() {
  local os_name
  if ! os_name=$(uname -s); then
    error "Failed to detect operating system"
  fi

  case "${os_name,,}" in
  linux*) echo "linux" ;;
  darwin*) echo "darwin" ;;
  *) error "Unsupported OS: $os_name" ;;
  esac
}

# Get normalized CPU architecture name
# Returns:
#   'amd64', 'arm64', or exits with error for unsupported architecture
get_arch_name() {
  local arch_name
  if ! arch_name=$(uname -m); then
    error "Failed to detect CPU architecture"
  fi

  case "${arch_name,,}" in
  x86_64*) echo "amd64" ;;
  aarch64* | arm64*) echo "arm64" ;;
  *) error "Unsupported architecture: $arch_name" ;;
  esac
}

# Generate a random UUID using Python
# Returns:
#   A random UUID string
gen_uuid() {
  if ! checkcmd python; then
    error "Python is required for UUID generation"
  fi

  local uuid
  if ! uuid=$(python -c 'import uuid; print(uuid.uuid4())'); then
    error "Failed to generate UUID"
  fi
  echo "$uuid"
}

# Download a file from URL using curl
# Arguments:
#   $1 - source URL
#   $2 - output file path
download_file() {
  if [ $# -ne 2 ]; then
    error "download_file: requires URL and output path"
  fi

  if ! checkcmd curl; then
    error "curl is not installed"
  fi

  local url=$1
  local output=$2
  local output_dir

  # Create output directory if it doesn't exist
  output_dir=$(dirname "$output")
  create_dir "$output_dir"

  if ! curl -fsSL "$url" -o "$output"; then
    error "Failed to download: $url"
  fi
  info "Downloaded $url to $output"
}

# Extract a tar archive to specified directory
# Arguments:
#   $1 - archive file path
#   $2 - output directory path
extract_tar() {
  if [ $# -ne 2 ]; then
    error "extract_tar: requires archive and output path"
  fi

  local archive=$1
  local output=$2

  if [ ! -f "$archive" ]; then
    error "Archive not found: $archive"
  fi

  create_dir "$output"

  if ! tar -xf "$archive" -C "$output"; then
    error "Failed to extract: $archive"
  fi
  info "Extracted $archive to $output"
}

# Generate a random UUID with only lower-case alphanumeric characters
random_uuid_lower() {
  local NEW_UUID
  NEW_UUID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)
  echo "$NEW_UUID"
}

# Generate a random number
random_num() {
  local WIDTH=${1:-4}
  local NUMBER
  NUMBER=$(cat /dev/urandom | tr -dc '0-9' | fold -w 256 | head -n 1 | sed -e 's/^0*//' | head --bytes "$WIDTH")
  echo "${NUMBER:-0}"
}

# Get the current shell name
current_shell_name() {
  local ostype
  local username
  local shellname
  ostype=$(uname -s)
  username=$(whoami)
  if [[ $ostype == "Darwin" ]]; then
    shellname=$(dscl . -read "/Users/$username" UserShell | awk '{print $2}')
  else
    shellname=$(awk -F: -v user="$username" '$1 == user {print $7}' /etc/passwd)
  fi
  echo "$(basename "$shellname")"
}

# Get the current shell configuration file
current_shell_config() {
  local sname
  local shellconfig="/dev/null"
  sname=$(current_shell_name)
  if [[ $sname == "zsh" ]]; then
    shellconfig="$HOME/.zshrc"
  elif [[ $sname == "bash" ]]; then
    shellconfig="$HOME/.bashrc"
  fi
  echo "$shellconfig"
}

# Get the latest GitHub release URL
latest_github_release() {
  local repo=$1
  local proj=$2
  local link
  link=$(curl -s "https://api.github.com/repos/$repo/$proj/releases/latest" | grep browser_download_url | cut -d '"' -f 4)
  echo "$link"
}

# Check if running on Linux
is_linux() {
  [[ $(uname -s) == "Linux" ]]
}

# Check if running on macOS
is_macos() {
  [[ $(uname -s) == "Darwin" ]]
}

# Check if running on x86 architecture
is_x86_64() {
  local CPU_ARCH
  CPU_ARCH=$(uname -m)
  [[ "$CPU_ARCH" == "x86_64" || "$CPU_ARCH" == "i"*"86" ]]
}

# Check if running on ARM architecture
is_arm64() {
  local CPU_ARCH
  CPU_ARCH=$(uname -m)
  [[ "$CPU_ARCH" == "arm64" || "$CPU_ARCH" == "aarch64" ]]
}

# Install files from pairs of source and destination files.
# Input should be pairs of source and destination files.
# If LINK_INSTEAD_OF_COPY is set, use soft link instead of copy.
install_file_pair() {
  local copycmd="cp"
  if [ "$LINK_INSTEAD_OF_COPY" == 1 ]; then
    copycmd="ln -sf"
  fi
  if [ $# -ne 2 ]; then
    error "install_file_pair: requires source and destination files"
  fi
  local src="$1"
  local dest="$2"
  if [ ! -e "$src" ]; then
    error "Error: Source '$src' does not exist"
  fi
  if [ ! -d $(dirname $dest) ]; then
    mkdir -p $(dirname $dest)
  fi
  $copycmd "$src" "$dest" || error "Error copying '$src' to '$dest'"
}

# Install pyenv to manage Python versions
install_pyenv() {
  if [ ! -e "$HOME/.pyenv" ]; then
    info "Installing pyenv to $HOME/.pyenv..."
    curl -k https://pyenv.run | bash
  fi
}

# Install uv
install_uv() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

# Install jenv to manage Java versions
install_jenv() {
  if checkcmd jenv; then
    info "jenv already installed"
    return
  fi

  if is_macos; then
    brew install jenv
  elif is_linux; then
    if [ ! -e "$HOME/.jenv" ]; then
      info "Installing jenv to $HOME/.jenv..."
      git clone https://github.com/jenv/jenv.git "$HOME/.jenv"
    fi
    PATH="$HOME/.jenv/bin:$PATH"
  fi

  eval "$(jenv init -)"
}

# Install jdt-language-server
install_jdt_language_server() {
  info "Installing jdt-language-server..."
  local dpath="$HOME/.local/share/jdt-language-server"
  local jdtdl="https://download.eclipse.org/jdtls/milestones/1.23.0/jdt-language-server-1.23.0-202304271346.tar.gz"
  if [ ! -e "$dpath/bin/jdtls" ]; then
    create_dir "$dpath"
    curl -L --progress-bar "$jdtdl" | tar zxf - -C "$dpath"
  else
    info "$dpath/bin/jdtls already exists"
  fi
}

# Install google-java-format
install_google_java_format() {
  info "Installing google-java-format..."
  local dpath="$HOME/.local/share/google-java-format"
  local fmtdl="https://github.com/google/google-java-format/releases/download/v1.17.0/google-java-format-1.17.0-all-deps.jar"
  if ! compgen -G "$dpath/google-java-format*.jar" >/dev/null; then
    curl -L --progress-bar --create-dirs "$fmtdl" -o "$dpath/google-java-format-all-deps.jar"
  else
    info "$dpath/google-java-format-all-deps.jar already installed"
  fi
}

# Install go version manager
install_gvm() {
  if checkcmd gvm; then
    return
  fi

  if [ -e "$HOME/.gvm" ]; then
    warn "$HOME/.gvm alreay exists, skip"
    return
  fi

  info "Installing GVM..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"
  if [ $? -ne 0 ]; then
    error "GVM installation failed."
    return
  fi

  # Detect shell and configure profile
  SHELL_TYPE=$(basename "$SHELL")
  case "$SHELL_TYPE" in
  bash) PROFILE_FILE="$HOME/.bash_profile" ;;
  zsh) PROFILE_FILE="$HOME/.zshrc" ;;
  *) PROFILE_FILE="$HOME/.profile" ;;
  esac

  # Add GVM to shell profile if not already present
  GVM_LINE='[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"'
  if ! grep -Fx "$GVM_LINE" "$PROFILE_FILE" >/dev/null 2>&1; then
    info "Adding GVM to $PROFILE_FILE..."
    echo "$GVM_LINE" >>"$PROFILE_FILE"
  fi

  # Source GVM in current session
  source "$HOME/.gvm/scripts/gvm"

  # Verify GVM installation
  if command -v gvm >/dev/null 2>&1; then
    info "GVM installed successfully. Version: $(gvm version)"
  else
    error "GVM installation failed. Please check logs above."
    return
  fi

  # Install Go 1.24.2 to resolve version mismatch
  info "Installing Go 1.24.2 (binary) as default..."
  gvm install go1.24.2 -B
  if [ $? -eq 0 ]; then
    gvm use go1.24.2 --default
    info "Go 1.24.2 set as default. Verify with: go version"
  else
    error "Failed to install Go 1.24.2. Please check GVM setup."
    return
  fi

  info "GVM setup complete!"
}

# Install Go
install_golang() {
  if checkcmd go; then
    return
  fi

  info "Installing Go..."
  local godl="https://go.dev/dl"
  local gover=${1:-"1.24.2"}
  local custom_goroot="$HOME/.local/go"

  create_dir "$(dirname "$custom_goroot")"

  local GO_RELEASE
  if is_macos; then
    if is_x86_64; then
      GO_RELEASE="go${gover}.darwin-amd64"
    elif is_arm64; then
      GO_RELEASE="go${gover}.darwin-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  else # is_linux
    if is_x86_64; then
      GO_RELEASE="go${gover}.linux-amd64"
    elif is_arm64; then
      GO_RELEASE="go${gover}.linux-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  fi

  local link="${godl}/${GO_RELEASE}.tar.gz"
  info "Downloading Go from $link"
  curl -k -L --progress-bar "$link" | tar -xz -C "$(dirname "$custom_goroot")"
}

# Install a Go library
go_install_lib() {
  local gocmd="go"
  local lib=$1
  local custom_goroot="$HOME/.local/go"

  if ! checkcmd "$gocmd"; then
    if [ -e "${custom_goroot}/bin/go" ]; then
      gocmd="${custom_goroot}/bin/go"
      info "Using custom Go installation at $gocmd"
    else
      warn "Go not found in PATH, skip installing $lib"
      return
    fi
  fi

  "$gocmd" install "$lib"
}

# Install a pip library
pip_install_lib() {
  local libs=("$@") # Accept multiple arguments as an array
  local options="--index-url http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com"
  local pip_cmd="pip"

  # Check if pip is available
  if ! command -v "$pip_cmd" &>/dev/null; then
    warn "pip not found in PATH, skipping installation of ${libs[*]}"
    return
  fi

  # Check if any libraries are provided
  if [[ ${#libs[@]} -eq 0 ]]; then
    warn "No libraries specified for installation"
    return
  fi

  info "Installing pip libraries: ${libs[*]}"
  # Install all libraries in one pip command, with upgrade and quiet flags
  "$pip_cmd" install $options -q -U "${libs[@]}" || {
    warn "Failed to install one or more libraries: ${libs[*]}"
    return
  }
}

# Install one or more npm libraries globally
npm_install_lib() {
  mkdir -p $HOME/.local && npm config set prefix '~/.local/'

  local libs=("$@") # Capture all arguments as an array
  local options="--prefer-offline --no-audit --progress=true"
  local npm_cmd="npm"

  # Check if npm is available
  if ! command -v "$npm_cmd" >/dev/null 2>&1; then
    warn "npm not found in PATH, skipping installation of ${libs[*]}"
    return
  fi

  # Validate input
  if [ ${#libs[@]} -eq 0 ]; then
    warn "No libraries specified for installation"
    return
  fi

  info "Installing npm libraries: ${libs[*]}"
  "$npm_cmd" install $options -g "${libs[@]}"
}

# Install a R library
rlang_install_lib() {
  local lib=$1
  if checkcmd R; then
    if ! R -e "library(${lib})" >/dev/null 2>&1; then
      R -e "install.packages('${lib}', repos='https://mirrors.nju.edu.cn/CRAN/')"
    fi
  else
    warn "R not found in PATH, skip installing $lib"
  fi
}

# Install Hack Nerd Font
install_hack_nerd_font() {
  info "Installing Hack Nerd Font and updating font cache..."
  if ! checkcmd fc-list; then
    warn "Fontconfig tools (fc-list, fc-cache) not found."
    return
  fi
  local FONTDIR="$HOME/.local/share/fonts"
  if is_macos; then
    FONTDIR="$HOME/Library/Fonts"
  fi
  if ! fc-list | grep "Hack Nerd Font" >/dev/null; then
    create_dir "$FONTDIR"
    curl -L --progress-bar "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.tar.xz" | tar xJ -C "$FONTDIR"
    fc-cache -f
  else
    info "Hack Nerd Font already installed"
  fi
}

# Install shfmt
install_shfmt() {
  if checkcmd shfmt; then
    return
  fi
  info "Installing shfmt..."
  local shfmtver=${1:-"v3.7.0"}
  local shfmtfile="shfmt_${shfmtver}_linux_amd64"
  if [ "$(uname)" == "Darwin" ]; then
    shfmtfile="shfmt_${shfmtver}_darwin_amd64"
  fi
  create_dir "$HOME/.local/bin"
  curl -L --progress-bar "https://github.com/mvdan/sh/releases/download/${shfmtver}/$shfmtfile" -o "$HOME/.local/bin/shfmt"
  chmod +x "$HOME/.local/bin/shfmt"
}

# Install fzf
install_fzf() {
  if [ ! -e "$HOME/.fzf" ]; then
    info "Installing fzf to $HOME/.fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all
  fi
  local shellconfig
  shellconfig=$(current_shell_config)
  if ! grep -r "source.*\.fzf\.zsh" "$shellconfig" >/dev/null; then
    local config='[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
    echo >>"$shellconfig"
    echo "# automatic configs by cool-dotfiles nvim installer" >>"$shellconfig"
    echo "$config" >>"$shellconfig"
  fi
}

# Install zsh
install_zsh() {
  if checkcmd zsh; then
    return
  fi
  info "Installing zsh..."
  create_dir "$HOME/.local/bin"
  create_dir "/tmp/build-zsh"
  curl -k -L --progress-bar "http://ftp.funet.fi/pub/unix/shells/zsh/zsh-${ZSH_VERSION}.tar.xz" | tar xJ -C "/tmp/build-zsh/"
  (
    cd "/tmp/build-zsh/zsh-${ZSH_VERSION}" && ./configure --prefix "$HOME/.local" && make && make install
  )
  rm -rf "/tmp/build-zsh"
}

# Install Neovim
install_neovim() {
  if checkcmd nvim; then
    return
  fi

  info "Installing Neovim..."
  local nvimver=${1:-"0.11.0"}
  create_dir "$HOME/.local"

  local NVIM_RELEASE
  if is_macos; then
    if is_x86_64; then
      NVIM_RELEASE="nvim-macos-x86_64"
    elif is_arm64; then
      NVIM_RELEASE="nvim-macos-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  else # is_linux
    if is_x86_64; then
      NVIM_RELEASE="nvim-linux-x86_64"
    elif is_arm64; then
      NVIM_RELEASE="nvim-linux-arm64"
    else
      error "Unsupported CPU architecture, exit"
    fi
  fi

  local link="https://github.com/neovim/neovim/releases/download/v${nvimver}/${NVIM_RELEASE}.tar.gz"
  info "Downloading Neovim from $link"
  curl -k -L --progress-bar "$link" | tar -xz --strip-components=1 -C "$HOME/.local"
}
