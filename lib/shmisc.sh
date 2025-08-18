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

# Enable strict mode: exit on error, undefined vars, pipe failures
set -euo pipefail

# XDG base directory specification
# These variables define standard directories for user data, config, and cache
readonly XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
readonly XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}

# ANSI color codes for terminal output
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RESET='\033[0m'

# Log levels for different message types
readonly LOG_INFO="INFO"
readonly LOG_WARN="WARN"
readonly LOG_ERROR="ERROR"

# Print a formatted log message with timestamp
# Arguments:
#   $1 - color code for the message
#   $2 - log level (INFO, WARN, ERROR)
#   $3+ - message content
print_message() {
  # Validate minimum argument count
  if [ $# -lt 3 ]; then
    printf "${COLOR_RED}[ERROR] Invalid number of arguments to print_message${COLOR_RESET}\n" >&2
    return 1
  fi

  local color_code=$1
  local level=$2
  shift 2

  # Print formatted message with timestamp
  printf "%b[%s] [%s] %s%b\n" \
    "$color_code" \
    "$(date '+%Y-%m-%dT%H:%M:%S')" \
    "$level" \
    "$*" \
    "$COLOR_RESET"
}

# Display usage information for installation scripts
# Arguments:
#   $1 - script name (optional, defaults to install.sh)
#   $2 - additional options (optional)
# Example:
#   usage_me "install.sh" "[-d] [-v]"
usage_me() {
  local script_name=${1:-"install.sh"}
  local additional_opts=${2:-""}
  local opts="[-f] [-s] [-c]"

  # Append additional options if provided
  if [ -n "$additional_opts" ]; then
    opts="$opts $additional_opts"
  fi

  echo "Usage: $script_name $opts"
  echo "  -f copy and install"
  echo "  -s soft link install"
  echo "  -c cleanse install"

  # Display additional options if provided
  if [ -n "$additional_opts" ]; then
    echo "  $additional_opts"
  fi
}

# Log an informational message
# Arguments:
#   $@ - message content
info() {
  print_message "$COLOR_GREEN" "$LOG_INFO" "$@"
}

# Log a warning message
# Arguments:
#   $@ - message content
warn() {
  print_message "$COLOR_YELLOW" "$LOG_WARN" "$@" >&2
}

# Log an error message and exit with status 1
# Arguments:
#   $@ - message content
error() {
  print_message "$COLOR_RED" "$LOG_ERROR" "$@" >&2
  exit 1
}

# Get the absolute path of the current script's directory
# Returns:
#   Absolute path to the script's directory
abspath() {
  local script_path

  # Resolve the absolute path of the current script
  if ! script_path=$(realpath "$0"); then
    error "Failed to resolve script path"
  fi

  # Extract and return the directory portion
  dirname "$script_path"
}

# Get the absolute path of the current script file
# Returns:
#   Absolute path to the script file
absfilepath() {
  local dir file

  # Change to the script's directory and get absolute path
  if ! dir=$(cd "$(dirname "$0")" && pwd); then
    error "Failed to resolve directory path"
  fi

  # Get the script filename
  file=$(basename "$0")

  # Return the full absolute path
  echo "$dir/$file"
}

# Create a directory if it doesn't exist
# Arguments:
#   $1 - directory path to create
create_dir() {
  # Validate argument count
  if [ $# -ne 1 ]; then
    error "create_dir: requires exactly one argument"
  fi

  local dir=$1

  # Create directory and all parent directories if needed
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
}

# Create a temporary directory and set up automatic cleanup
# Returns:
#   Path to the created temporary directory
get_temp_dir() {
  local temp_dir

  # Create temporary directory
  TEMP_DIR="$(mktemp -d)"

  # Set trap to automatically clean up on exit
  trap 'rm -rf "$TEMP_DIR"' EXIT

  # Return the path to the temporary directory
  echo "$TEMP_DIR"
}

# Check if a command exists in PATH
# Arguments:
#   $1 - command name to check
# Returns:
#   0 if command exists, 1 otherwise
checkcmd() {
  # Validate argument count
  if [ $# -ne 1 ]; then
    error "checkcmd: requires exactly one argument"
  fi

  # Check if command exists in PATH
  command -v "$1" >/dev/null 2>&1
}

# Install Python packages with pip
# Arguments:
#   $@ - package names to install
pip_install_lib() {
  # Validate that at least one package was provided
  if [ $# -eq 0 ]; then
    error "pip_install_lib: requires at least one package name"
  fi

  # Check if pip is available
  if ! checkcmd pip; then
    error "pip is not installed"
  fi

  # Install packages with user flag
  if ! pip install --user "$@"; then
    error "Failed to install pip packages: $*"
  fi
}

# Install Go packages
# Arguments:
#   $@ - package paths to install
go_install_lib() {
  # Validate that at least one package was provided
  if [ $# -eq 0 ]; then
    error "go_install_lib: requires at least one package path"
  fi

  # Check if Go is available
  if ! checkcmd go; then
    error "go is not installed"
  fi

  # Install Go packages
  if ! go install "$@"; then
    error "Failed to install Go packages: $*"
  fi
}

# Install R packages
# Arguments:
#   $@ - package names to install
rlang_install_lib() {
  # Validate that at least one package was provided
  if [ $# -eq 0 ]; then
    error "rlang_install_lib: requires at least one package name"
  fi

  # Check if Rscript is available
  if ! checkcmd Rscript; then
    error "R is not installed"
  fi

  # Install R packages from CRAN
  if ! Rscript -e "install.packages(c('$*'), repos='https://cloud.r-project.org/')"; then
    error "Failed to install R packages: $*"
  fi
}

# Check and ensure sudo access with timeout renewal
# Arguments:
#   $1 - optional sudo prompt message
# Returns:
#   0 if sudo access granted, exits with error otherwise
check_sudo_access() {
  local prompt timeout_mins=5
  prompt=${1:-"[sudo] Enter password for sudo access: "}

  # Reset sudo timeout by requesting password
  if ! sudo -v -p "$prompt"; then
    error "Failed to get sudo access"
  fi

  # Keep sudo alive in the background by renewing credentials
  while true; do
    sudo -n true
    # Sleep for half the timeout period
    sleep $((timeout_mins * 60 / 2))
    # Check if parent process still exists
    kill -0 "$" || exit
  done 2>/dev/null &
}

# Get normalized operating system name
# Returns:
#   'linux', 'darwin', or exits with error for unsupported OS
get_os_name() {
  local os_name

  # Get the operating system name
  if ! os_name=$(uname -s); then
    error "Failed to detect operating system"
  fi

  # Normalize and return OS name
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

  # Get the CPU architecture
  if ! arch_name=$(uname -m); then
    error "Failed to detect CPU architecture"
  fi

  # Normalize and return architecture name
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
# Returns:
#   A 32-character random string with lowercase letters and numbers
random_uuid_lower() {
  local NEW_UUID

  # Generate random lowercase alphanumeric string
  NEW_UUID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)

  # Return the generated string
  echo "$NEW_UUID"
}

# Generate a random number with specified width
# Arguments:
#   $1 - width of the number (default: 4)
# Returns:
#   A random number with the specified width
random_num() {
  local WIDTH=${1:-4}
  local NUMBER

  # Generate random number with specified width
  NUMBER=$(cat /dev/urandom | tr -dc '0-9' | fold -w 256 | head -n 1 | sed -e 's/^0*//' | head --bytes "$WIDTH")

  # Return the generated number (or 0 if empty)
  echo "${NUMBER:-0}"
}

# Get the current shell name
# Returns:
#   The name of the current shell (e.g., bash, zsh)
current_shell_name() {
  local ostype
  local username
  local shellname

  # Get OS type and current username
  ostype=$(uname -s)
  username=$(whoami)

  # Get shell name based on OS
  if [[ $ostype == "Darwin" ]]; then
    # On macOS, get shell from directory service
    shellname=$(dscl . -read "/Users/$username" UserShell | awk '{print $2}')
  else
    # On Linux, get shell from passwd file
    shellname=$(awk -F: -v user="$username" '$1 == user {print $7}' /etc/passwd)
  fi

  # Return just the shell name without path
  echo "$(basename "$shellname")"
}

# Get the current shell configuration file
# Returns:
#   Path to the shell configuration file
current_shell_config() {
  local sname
  local shellconfig="/dev/null"

  # Get current shell name
  sname=$(current_shell_name)

  # Set config file based on shell type
  if [[ $sname == "zsh" ]]; then
    shellconfig="$HOME/.zshrc"
  elif [[ $sname == "bash" ]]; then
    shellconfig="$HOME/.bashrc"
  fi

  # Return the config file path
  echo "$shellconfig"
}

# Get the latest GitHub release URL
# Arguments:
#   $1 - repository owner
#   $2 - repository name
# Returns:
#   URL of the latest release download
latest_github_release() {
  local repo=$1
  local proj=$2
  local link

  # Fetch latest release info from GitHub API and extract download URL
  link=$(curl -s "https://api.github.com/repos/$repo/$proj/releases/latest" | grep browser_download_url | cut -d '"' -f 4)

  # Return the download link
  echo "$link"
}

# Check if running on Linux
# Returns:
#   0 if running on Linux, 1 otherwise
is_linux() {
  [[ $(uname -s) == "Linux" ]]
}

# Check if running on macOS
# Returns:
#   0 if running on macOS, 1 otherwise
is_macos() {
  [[ $(uname -s) == "Darwin" ]]
}

# Check if running on x86 architecture
# Returns:
#   0 if running on x86, 1 otherwise
is_x86_64() {
  local CPU_ARCH
  CPU_ARCH=$(uname -m)
  [[ "$CPU_ARCH" == "x86_64" || "$CPU_ARCH" == "i"*"86" ]]
}

# Check if running on ARM architecture
# Returns:
#   0 if running on ARM, 1 otherwise
is_arm64() {
  local CPU_ARCH
  CPU_ARCH=$(uname -m)
  [[ "$CPU_ARCH" == "arm64" || "$CPU_ARCH" == "aarch64" ]]
}

# Install files from pairs of source and destination files.
# Input should be pairs of source and destination files.
# If LINK_INSTEAD_OF_COPY is set, use soft link instead of copy.
# Arguments:
#   $1 - source file path
#   $2 - destination file path
install_file_pair() {
  local copycmd="cp"

  # Use soft link if LINK_INSTEAD_OF_COPY is set
  if [ "$LINK_INSTEAD_OF_COPY" == 1 ]; then
    copycmd="ln -sf"
  fi

  # Validate argument count
  if [ $# -ne 2 ]; then
    error "install_file_pair: requires source and destination files"
  fi

  local src="$1"
  local dest="$2"

  # Check if source file exists
  if [ ! -e "$src" ]; then
    error "Error: Source '$src' does not exist"
  fi

  # Create destination directory if needed
  if [ ! -d "$(dirname "$dest")" ]; then
    mkdir -p "$(dirname "$dest")"
  fi

  # Copy or link file
  $copycmd "$src" "$dest" || error "Error copying '$src' to '$dest'"
}

# Install uv
install_uv() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

# Install pyenv to manage Python versions
install_pyenv() {
  if [ ! -e "$HOME/.pyenv" ]; then
    info "Installing pyenv to $HOME/.pyenv..."
    curl -k https://pyenv.run | bash
  fi
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
      git clone --depth 1 https://github.com/jenv/jenv.git "$HOME/.jenv"
    fi
    PATH="$HOME/.jenv/bin:$PATH"
  fi

  eval "$(jenv init -)"
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

# Install nvm to manage node versions
install_nvm() {
  if [ ! -e "$HOME/.nvm" ]; then
    info "Installing nvm to $HOME/.nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash
  fi
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
# Arguments:
#   $1 - Go library path to install
go_install_lib() {
  local gocmd="go"
  local lib=$1
  local custom_goroot="$HOME/.local/go"

  # Check if Go is available in PATH
  if ! checkcmd "$gocmd"; then
    # Check if custom Go installation exists
    if [ -e "${custom_goroot}/bin/go" ]; then
      gocmd="${custom_goroot}/bin/go"
      info "Using custom Go installation at $gocmd"
    else
      warn "Go not found in PATH, skip installing $lib"
      return
    fi
  fi

  # Install the Go library
  "$gocmd" install "$lib"
}

# Install one or more Python libraries using pip
# Arguments:
#   $@ - Python library names to install
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
# Arguments:
#   $@ - npm library names to install
npm_install_lib() {
  # Set npm prefix to be consistent with npm/.npmrc
  mkdir -p $HOME/.local && npm config set prefix '~/.local/'

  local libs=("$@") # Capture all arguments as an array
  local options="--prefer-offline --no-audit --progress=true --registry=https://registry.npmmirror.com"
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

# Install an R library
# Arguments:
#   $1 - R library name to install
rlang_install_lib() {
  local lib=$1

  # Check if R is available
  if checkcmd R; then
    # Check if library is already installed
    if ! R -e "library(${lib})" >/dev/null 2>&1; then
      # Install library from CRAN mirror
      R -e "install.packages('${lib}', repos='https://mirrors.nju.edu.cn/CRAN/')"
    fi
  else
    warn "R not found in PATH, skip installing $lib"
  fi
}

# Install Hack Nerd Font
install_hack_nerd_font() {
  info "Installing Hack Nerd Font and updating font cache..."

  # Check if fontconfig tools are available
  if ! checkcmd fc-list; then
    warn "Fontconfig tools (fc-list, fc-cache) not found."
    return
  fi

  # Set font directory based on OS
  local FONTDIR="$HOME/.local/share/fonts"
  if is_macos; then
    FONTDIR="$HOME/Library/Fonts"
  fi

  # Check if font is already installed
  if ! fc-list | grep "Hack Nerd Font" >/dev/null; then
    # Create font directory and download font
    create_dir "$FONTDIR"
    curl -L --progress-bar "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.tar.xz" | tar xJ -C "$FONTDIR"

    # Update font cache
    fc-cache -f
  else
    info "Hack Nerd Font already installed"
  fi
}

# Install shfmt (shell formatter)
# Arguments:
#   $1 - shfmt version to install (default: v3.7.0)
install_shfmt() {
  # Check if shfmt is already installed
  if checkcmd shfmt; then
    return
  fi

  info "Installing shfmt..."

  # Set version and filename based on OS
  local shfmtver=${1:-"v3.7.0"}
  local shfmtfile="shfmt_${shfmtver}_linux_amd64"
  if [ "$(uname)" == "Darwin" ]; then
    shfmtfile="shfmt_${shfmtver}_darwin_amd64"
  fi

  # Create bin directory and download shfmt
  create_dir "$HOME/.local/bin"
  curl -L --progress-bar "https://github.com/mvdan/sh/releases/download/${shfmtver}/$shfmtfile" -o "$HOME/.local/bin/shfmt"

  # Make shfmt executable
  chmod +x "$HOME/.local/bin/shfmt"
}

# Install fzf (fuzzy finder)
install_fzf() {
  # Check if fzf is already installed
  if [ ! -e "$HOME/.fzf" ]; then
    info "Installing fzf to $HOME/.fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all
  fi

  # Get current shell configuration file
  local shellconfig
  shellconfig=$(current_shell_config)

  # Check if fzf is already sourced in shell config
  if ! grep -r "source.*\.fzf\.zsh" "$shellconfig" >/dev/null; then
    # Add fzf sourcing to shell configuration
    local config='[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
    echo >>"$shellconfig"
    echo "# automatic configs by cool-dotfiles nvim installer" >>"$shellconfig"
    echo "$config" >>"$shellconfig"
  fi
}

# Install zsh shell
# Requires ZSH_VERSION environment variable to be set
install_zsh() {
  # Check if zsh is already installed
  if checkcmd zsh; then
    return
  fi

  info "Installing zsh..."

  # Create necessary directories
  create_dir "$HOME/.local/bin"
  create_dir "/tmp/build-zsh"

  # Download and extract zsh source
  curl -k -L --progress-bar "http://ftp.funet.fi/pub/unix/shells/zsh/zsh-${ZSH_VERSION}.tar.xz" | tar xJ -C "/tmp/build-zsh/"

  # Build and install zsh
  (
    cd "/tmp/build-zsh/zsh-${ZSH_VERSION}" && ./configure --prefix "$HOME/.local" && make && make install
  )

  # Clean up temporary directory
  rm -rf "/tmp/build-zsh"
}

# Install Neovim text editor
# Arguments:
#   $1 - Neovim version to install (default: 0.11.0)
install_neovim() {
  # Check if Neovim is already installed
  if checkcmd nvim; then
    return
  fi

  info "Installing Neovim..."

  # Set version and create local directory
  local nvimver=${1:-"0.11.0"}
  create_dir "$HOME/.local"

  # Determine Neovim release based on OS and architecture
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

  # Download and extract Neovim
  local link="https://github.com/neovim/neovim/releases/download/v${nvimver}/${NVIM_RELEASE}.tar.gz"
  info "Downloading Neovim from $link"
  curl -k -L --progress-bar "$link" | tar -xz --strip-components=1 -C "$HOME/.local"
}

# Install AI code agents
install_ai_code_agents() {
  # Define AI code agents to install
  local agents="@qwen-code/qwen-code @iflow-ai/iflow-cli @google/gemini-cli @anthropic-ai/claude-code"

  # Install agents using npm
  npm_install_lib ${agents}

  # Install cursor agent CLI
  curl https://cursor.com/install -fsS | bash
}

install_cargo() {
  # Check if cargo is already installed
  if command -v cargo &>/dev/null; then
    echo "Cargo is already installed: $(cargo --version)"
    return 0
  fi

  # Detect download command
  if command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -sSf"
  elif command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget -qO-"
  else
    echo "Error: curl or wget is required to install Rust/Cargo."
    return 1
  fi

  # Install rustup (official Rust installer)
  echo "Installing Rust and Cargo..."
  $DOWNLOAD_CMD https://sh.rustup.rs | sh -s -- -y

  # Source environment variables
  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env"
  fi

  # Verify installation
  if command -v cargo &>/dev/null; then
    echo "Cargo installed successfully: $(cargo --version)"
  else
    echo "Cargo installation failed."
    return 1
  fi
}
