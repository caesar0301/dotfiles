#!/bin/bash
###################################################
# Shell Utility Library
# https://github.com/caesar0301/cool-dotfiles
#
# A comprehensive shell utility library organized by functionality:
# - Core Configuration & Constants
# - Logging & Messaging Functions
# - Path & File Utilities
# - System Information & Detection
# - Package Management Helpers
# - Development Environment Installation
#
# Copyright (c) 2024, Xiaming Chen
# License: MIT
###################################################

# Enable strict mode: exit on error, undefined vars, pipe failures
set -euo pipefail

###################################################
# CORE CONFIGURATION & CONSTANTS
###################################################

# XDG base directory specification
# These variables define standard directories for user data, config, and cache
# Set default values if not already set (only if not readonly)
[[ -z "${XDG_DATA_HOME:-}" ]] && XDG_DATA_HOME="$HOME/.local/share"
[[ -z "${XDG_CONFIG_HOME:-}" ]] && XDG_CONFIG_HOME="$HOME/.config"
[[ -z "${XDG_CACHE_HOME:-}" ]] && XDG_CACHE_HOME="$HOME/.cache"

# Make readonly only if not already readonly (suppress error if already readonly)
readonly XDG_DATA_HOME 2>/dev/null || true
readonly XDG_CONFIG_HOME 2>/dev/null || true
readonly XDG_CACHE_HOME 2>/dev/null || true

# ANSI color codes for modern terminal output
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'

# Log levels with enhanced formatting
readonly LOG_INFO="INFO"
readonly LOG_WARN="WARN"
readonly LOG_ERROR="ERROR"
readonly LOG_SUCCESS="SUCCESS"

###################################################
# LOGGING & MESSAGING FUNCTIONS
###################################################

# Print a modern formatted log message with timestamp and enhanced styling
# Arguments:
#   $1 - color code for the message
#   $2 - log level (INFO, WARN, ERROR, SUCCESS)
#   $3+ - message content
print_message() {
  [[ $# -lt 3 ]] && {
    printf "${COLOR_RED}✗ [ERROR] Invalid arguments to print_message${COLOR_RESET}\n" >&2
    return 1
  }

  local color_code=$1 level=$2
  shift 2

  # Modern log format with icons and enhanced readability
  local icon
  case "$level" in
  "INFO") icon="ℹ" ;;
  "WARN") icon="⚠" ;;
  "ERROR") icon="✗" ;;
  "SUCCESS") icon="✓" ;;
  *) icon="•" ;;
  esac

  printf "%b%s [%s] %s %s%b\n" \
    "$color_code" \
    "$icon" \
    "$(date '+%H:%M:%S')" \
    "$level" \
    "$*" \
    "$COLOR_RESET"
}

# Display modern usage information for installation scripts
# Arguments:
#   $1 - script name (optional, defaults to install.sh)
#   $2 - additional options (optional)
usage_me() {
  local script_name=${1:-"install.sh"}
  local additional_opts=${2:-""}
  local opts="[-f] [-s] [-c]"

  [[ -n "$additional_opts" ]] && opts="$opts $additional_opts"

  printf "%b%s Usage Instructions%b\n" "$COLOR_BOLD$COLOR_CYAN" "$script_name" "$COLOR_RESET"
  printf "  %b-f%b  Copy and install (force overwrite)\n" "$COLOR_GREEN" "$COLOR_RESET"
  printf "  %b-s%b  Soft link install (symlink)\n" "$COLOR_YELLOW" "$COLOR_RESET"
  printf "  %b-c%b  Cleanse install (remove existing)\n" "$COLOR_RED" "$COLOR_RESET"

  [[ -n "$additional_opts" ]] && printf "  %s\n" "$additional_opts"
}

# Modern logging functions with enhanced error handling
info() {
  print_message "$COLOR_BLUE" "$LOG_INFO" "$@"
}

success() {
  print_message "$COLOR_GREEN" "$LOG_SUCCESS" "$@"
}

warn() {
  print_message "$COLOR_YELLOW" "$LOG_WARN" "$@" >&2
}

# Enhanced error function with optional exit code
error() {
  local exit_code=1
  [[ $1 =~ ^[0-9]+$ ]] && {
    exit_code=$1
    shift
  }
  print_message "$COLOR_RED" "$LOG_ERROR" "$@" >&2
  exit "$exit_code"
}

###################################################
# PATH & FILE UTILITIES
###################################################

# Get the absolute path of the current script's directory with enhanced error handling
abspath() {
  local script_path
  script_path=$(realpath "$0" 2>/dev/null) || error "Failed to resolve script path for $0"
  dirname "$script_path"
}

# Get the absolute path of the current script file with improved reliability
absfilepath() {
  local dir file
  dir=$(cd "$(dirname "$0")" && pwd 2>/dev/null) || error "Failed to resolve directory path"
  file=$(basename "$0")
  printf "%s/%s" "$dir" "$file"
}

# Create directory with enhanced validation and feedback
create_dir() {
  [[ $# -ne 1 ]] && error "create_dir: requires exactly one directory path"

  local dir=$1
  [[ -d "$dir" ]] && return 0

  mkdir -p "$dir" || error "Failed to create directory: $dir"
  info "Created directory: $dir"
}

# Create temporary directory with enhanced cleanup and validation
get_temp_dir() {
  local temp_dir
  temp_dir=$(mktemp -d 2>/dev/null) || error "Failed to create temporary directory"

  # Enhanced cleanup trap
  trap 'rm -rf "$temp_dir" 2>/dev/null || true' EXIT INT TERM

  info "Created temporary directory: $temp_dir"
  printf "%s" "$temp_dir"
}

# Check command existence with improved validation
checkcmd() {
  [[ $# -ne 1 ]] && error "checkcmd: requires exactly one command name"
  command -v "$1" >/dev/null 2>&1
}

# Check if node version meets minimum requirement
check_nodejs_version() {
  local min_version="$1"
  [[ -z "$min_version" ]] && min_version="20.0.0"

  if ! checkcmd node; then
    return 1
  fi

  local node_version
  node_version=$(node --version 2>/dev/null) || return 1

  # Simple version comparison for major.minor.patch format
  # Initialize variables to avoid unbound variable errors
  local major="" minor="" patch=""
  IFS='.' read -r major minor patch <<<"${node_version#v}" # Remove leading 'v' if present

  # Initialize min version variables
  local min_major="" min_minor="" min_patch=""
  IFS='.' read -r min_major min_minor min_patch <<<"$min_version"

  # Set defaults for unset variables (in case version has fewer components)
  [[ -z "$major" ]] && major=0
  [[ -z "$minor" ]] && minor=0
  [[ -z "$patch" ]] && patch=0
  [[ -z "$min_major" ]] && min_major=0
  [[ -z "$min_minor" ]] && min_minor=0
  [[ -z "$min_patch" ]] && min_patch=0

  # Compare major version first
  [[ $major -gt $min_major ]] && return 0
  [[ $major -lt $min_major ]] && return 1

  # If major versions are equal, compare minor
  [[ $minor -gt $min_minor ]] && return 0
  [[ $minor -lt $min_minor ]] && return 1

  # If minor versions are equal, compare patch
  [[ $patch -ge $min_patch ]] && return 0
  return 1
}

# Check if system supports modern plugins (node >= 20)
SUPPORTS_MODERN_PLUGINS() {
  check_nodejs_version "20.0.0"
}

###################################################
# PACKAGE MANAGEMENT HELPERS
###################################################

# Install Python packages with enhanced error handling and feedback
pip_install_lib() {
  [[ $# -eq 0 ]] && error "pip_install_lib: requires at least one package name"

  checkcmd pip || error "pip is not installed or not in PATH"

  info "Installing pip packages: $*"
  if pip install --user "$@" --quiet; then
    success "Successfully installed pip packages: $*"
  else
    error "Failed to install pip packages: $*"
  fi
}

# Install Go packages with enhanced validation and feedback
go_install_lib() {
  [[ $# -eq 0 ]] && error "go_install_lib: requires at least one package path"

  checkcmd go || error "Go is not installed or not in PATH"

  info "Installing Go packages: $*"

  # Use proxy in China
  local proxies=(
    "https://goproxy.cn,direct"
    "https://goproxy.io,direct"
    "direct"
  )

  local success_flag=0
  local failed_packages=()

  # Install each package separately to avoid module conflicts
  for package in "$@"; do
    local package_success=0
    for proxy in "${proxies[@]}"; do
      info "Trying to install $package with GOPROXY=$proxy"
      if GOPROXY="$proxy" go install "$package"; then
        success "Successfully installed Go package: $package (via $proxy)"
        package_success=1
        break
      else
        warn "Failed to install $package with GOPROXY=$proxy, retrying..."
      fi
    done

    if [[ $package_success -eq 0 ]]; then
      failed_packages+=("$package")
    fi
  done

  if [[ ${#failed_packages[@]} -gt 0 ]]; then
    error "Failed to install Go packages: ${failed_packages[*]}"
  else
    success "Successfully installed all Go packages: $*"
  fi
}

# Install R packages with improved error handling
rlang_install_lib() {
  [[ $# -eq 0 ]] && error "rlang_install_lib: requires at least one package name"

  checkcmd Rscript || warn "R is not installed or not in PATH" && return 0

  local packages=("$@")
  local pkg_str=$(printf "'%s'," "${packages[@]}")
  pkg_str="${pkg_str%,}"

  info "Installing R packages: ${packages[*]}"

  # China CRAN mirrors
  local mirrors=(
    "https://mirrors.tuna.tsinghua.edu.cn/CRAN"
    "https://mirrors.ustc.edu.cn/CRAN"
    "https://mirrors.aliyun.com/CRAN"
    "https://cloud.r-project.org"
  )

  local success_flag=0
  for repo in "${mirrors[@]}"; do
    info "Trying CRAN mirror: $repo"
    if Rscript -e "install.packages(c(${pkg_str}), repos='$repo')" >/dev/null 2>&1; then
      success "Successfully installed R packages: ${packages[*]} (via $repo)"
      success_flag=1
      break
    else
      warn "Failed with CRAN mirror: $repo, retrying..."
    fi
  done

  [[ $success_flag -eq 1 ]] || error "Failed to install R packages after trying all mirrors: ${packages[*]}"
}

# Install npm packages globally with enhanced configuration
npm_install_lib() {
  [[ $# -eq 0 ]] && error "npm_install_lib: requires at least one package name"

  checkcmd npm || error "npm is not installed or not in PATH"

  # Configure npm prefix for local installs
  create_dir "$HOME/.local"
  npm config set prefix "$HOME/.local" >/dev/null 2>&1

  local packages=("$@")
  local cache_dir="$HOME/.npm_cache"
  create_dir "$cache_dir"

  local registries=(
    "https://registry.npmmirror.com"
    "https://registry.npmjs.org"
    "https://registry.yarnpkg.com"
  )

  local options="--prefer-offline --no-audit --progress=true --cache=$cache_dir"
  local success_flag=0

  info "Installing npm packages: ${packages[*]}"

  for reg in "${registries[@]}"; do
    info "Trying npm registry: $reg"
    if npm install $options --registry="$reg" -g "${packages[@]}"; then
      success "Successfully installed npm packages: ${packages[*]} (via $reg)"
      success_flag=1
      break
    else
      warn "Failed with registry: $reg, retrying..."
    fi
  done

  [[ $success_flag -eq 1 ]] || error "Failed to install npm packages after trying all registries: ${packages[*]}"
}

# Enhanced sudo access management with improved error handling
check_sudo_access() {
  local prompt=${1:-"[sudo] Enter password for sudo access: "}
  local timeout_mins=5

  info "Requesting sudo access..."
  sudo -v -p "$prompt" || error "Failed to obtain sudo access"

  success "Sudo access granted"

  # Background process to maintain sudo credentials
  {
    while kill -0 "$$" 2>/dev/null; do
      sleep $((timeout_mins * 60 / 2))
      sudo -n true 2>/dev/null || break
    done
  } &
}

###################################################
# SYSTEM INFORMATION & DETECTION
###################################################

# Get normalized operating system name with enhanced detection
get_os_name() {
  local os_name
  os_name=$(uname -s 2>/dev/null) || error "Failed to detect operating system"

  case "${os_name,,}" in
  linux*) printf "linux" ;;
  darwin*) printf "darwin" ;;
  *) error "Unsupported operating system: $os_name" ;;
  esac
}

# Get normalized CPU architecture with comprehensive support
get_arch_name() {
  local arch_name
  arch_name=$(uname -m 2>/dev/null) || error "Failed to detect CPU architecture"

  case "${arch_name,,}" in
  x86_64* | amd64*) printf "amd64" ;;
  aarch64* | arm64*) printf "arm64" ;;
  armv7*) printf "armv7" ;;
  i?86*) printf "i386" ;;
  *) error "Unsupported CPU architecture: $arch_name" ;;
  esac
}

# Generate UUID with multiple fallback methods
gen_uuid() {
  local uuid

  # Try uuidgen first (most systems)
  if checkcmd uuidgen; then
    uuid=$(uuidgen 2>/dev/null) && {
      printf "%s" "$uuid"
      return
    }
  fi

  # Fallback to Python
  if checkcmd python3; then
    uuid=$(python3 -c 'import uuid; print(uuid.uuid4())' 2>/dev/null) && {
      printf "%s" "$uuid"
      return
    }
  elif checkcmd python; then
    uuid=$(python -c 'import uuid; print(uuid.uuid4())' 2>/dev/null) && {
      printf "%s" "$uuid"
      return
    }
  fi

  # Last resort: pseudo-random UUID
  printf "%08x-%04x-%04x-%04x-%012x" \
    $((RANDOM * RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM)) $((RANDOM * RANDOM * RANDOM))
}

# Enhanced file download with multiple tools and progress
download_file() {
  [[ $# -ne 2 ]] && error "download_file: requires URL and output path"

  local url=$1 output=$2 output_dir
  output_dir=$(dirname "$output")
  create_dir "$output_dir"

  info "Downloading: $url"

  # Try curl first (preferred)
  if checkcmd curl; then
    if curl -fsSL --progress-bar "$url" -o "$output"; then
      success "Downloaded: $(basename "$output")"
      return
    fi
  fi

  # Fallback to wget
  if checkcmd wget; then
    if wget -q --show-progress "$url" -O "$output"; then
      success "Downloaded: $(basename "$output")"
      return
    fi
  fi

  error "Failed to download $url (tried curl and wget)"
}

# Enhanced archive extraction with format detection
extract_tar() {
  [[ $# -ne 2 ]] && error "extract_tar: requires archive and output path"

  local archive=$1 output=$2
  [[ -f "$archive" ]] || error "Archive not found: $archive"

  create_dir "$output"
  info "Extracting: $(basename "$archive")"

  # Auto-detect compression and extract
  case "${archive,,}" in
  *.tar.gz | *.tgz) tar -xzf "$archive" -C "$output" ;;
  *.tar.bz2 | *.tbz2) tar -xjf "$archive" -C "$output" ;;
  *.tar.xz | *.txz) tar -xJf "$archive" -C "$output" ;;
  *.tar) tar -xf "$archive" -C "$output" ;;
  *) error "Unsupported archive format: $archive" ;;
  esac || error "Failed to extract: $archive"

  success "Extracted: $(basename "$archive")"
}

# Generate random lowercase alphanumeric string with validation
random_uuid_lower() {
  local length=${1:-32} uuid

  # Use multiple methods for better compatibility
  if [[ -c /dev/urandom ]]; then
    uuid=$(tr -dc 'a-z0-9' </dev/urandom | fold -w "$length" | head -n 1)
  else
    # Fallback method using RANDOM
    uuid=$(printf "%s" {1.."$length"} | while read -r _; do printf "%c" "$(printf "\\$(printf "%03o" $((97 + RANDOM % 26)))")"; done)
  fi

  printf "%s" "${uuid:0:$length}"
}

# Generate random number with enhanced validation
random_num() {
  local width=${1:-4} number

  # Validate width parameter
  [[ $width =~ ^[1-9][0-9]*$ ]] || error "random_num: width must be positive integer"

  if [[ -c /dev/urandom ]]; then
    number=$(tr -dc '0-9' </dev/urandom | head -c "$width")
    # Ensure we don't return empty or all-zeros
    [[ -n $number && $number != $(printf "%0${width}d" 0) ]] || number=$(((RANDOM % 9 + 1) * 10 ** (width - 1) + RANDOM % (10 ** (width - 1))))
  else
    # Fallback using RANDOM
    number=$(((RANDOM % 9 + 1) * 10 ** (width - 1) + RANDOM % (10 ** (width - 1))))
  fi

  printf "%0${width}d" "$number"
}

# Get current shell name with improved detection
current_shell_name() {
  local shell_path shell_name

  # Try multiple methods to detect shell
  if [[ -n $SHELL ]]; then
    shell_path=$SHELL
  elif [[ -n $0 && $0 != "-"* ]]; then
    shell_path=$(ps -p "$$" -o comm= 2>/dev/null)
  else
    local username ostype
    username=$(whoami 2>/dev/null) || error "Cannot determine current user"
    ostype=$(uname -s 2>/dev/null) || error "Cannot determine OS type"

    case "$ostype" in
    Darwin) shell_path=$(dscl . -read "/Users/$username" UserShell 2>/dev/null | awk '{print $2}') ;;
    *) shell_path=$(getent passwd "$username" 2>/dev/null | cut -d: -f7) ;;
    esac
  fi

  [[ -n $shell_path ]] || error "Cannot determine current shell"
  shell_name=$(basename "$shell_path")
  printf "%s" "$shell_name"
}

# Get shell configuration file with comprehensive shell support
current_shell_config() {
  local shell_name shell_config
  shell_name=$(current_shell_name)

  case "$shell_name" in
  zsh) shell_config="$HOME/.zshrc" ;;
  bash)
    # Prefer .bashrc, fallback to .bash_profile
    if [[ -f "$HOME/.bashrc" ]]; then
      shell_config="$HOME/.bashrc"
    else
      shell_config="$HOME/.bash_profile"
    fi
    ;;
  fish) shell_config="$HOME/.config/fish/config.fish" ;;
  tcsh | csh) shell_config="$HOME/.cshrc" ;;
  ksh) shell_config="$HOME/.kshrc" ;;
  *)
    warn "Unknown shell: $shell_name, using .profile"
    shell_config="$HOME/.profile"
    ;;
  esac

  printf "%s" "$shell_config"
}

# Get latest GitHub release with enhanced error handling and filtering
latest_github_release() {
  [[ $# -ne 2 ]] && error "latest_github_release: requires owner and repository name"

  local owner=$1 repo=$2 pattern=${3:-""} api_url release_info download_urls
  api_url="https://api.github.com/repos/$owner/$repo/releases/latest"

  info "Fetching latest release for $owner/$repo"

  # Fetch release information with proper error handling
  if ! release_info=$(curl -s --fail "$api_url" 2>/dev/null); then
    error "Failed to fetch release information from GitHub API"
  fi

  # Extract download URLs
  download_urls=$(printf "%s" "$release_info" | grep -o '"browser_download_url":"[^"]*"' | cut -d'"' -f4)

  [[ -n $download_urls ]] || error "No download URLs found in release"

  # Filter by pattern if provided
  if [[ -n $pattern ]]; then
    download_urls=$(printf "%s" "$download_urls" | grep -E "$pattern" | head -1)
    [[ -n $download_urls ]] || error "No downloads matching pattern: $pattern"
  fi

  printf "%s" "$download_urls"
}

# Enhanced system detection functions with caching
# Use regular variable declaration for bash compatibility
_os_cache=""
_arch_cache=""

is_linux() {
  [[ ${_os_cache:-$(uname -s)} == "Linux" ]]
}

is_macos() {
  [[ ${_os_cache:-$(uname -s)} == "Darwin" ]]
}

is_windows() {
  [[ ${_os_cache:-$(uname -s)} == CYGWIN* || ${_os_cache:-$(uname -s)} == MINGW* ]]
}

is_x86_64() {
  local arch=${_arch_cache:-$(uname -m)}
  [[ $arch == "x86_64" || $arch == "amd64" || $arch == i?86 ]]
}

is_arm64() {
  local arch=${_arch_cache:-$(uname -m)}
  [[ $arch == "arm64" || $arch == "aarch64" ]]
}

is_armv7() {
  local arch=${_arch_cache:-$(uname -m)}
  [[ $arch == armv7* ]]
}

# Get kernel version for compatibility checks
get_kernel_version() {
  local version
  if is_linux; then
    version=$(uname -r | cut -d. -f1,2)
    printf "%s" "$version"
  else
    printf "0.0"
  fi
}

install_file_pair() {
  [[ $# -ne 2 ]] && error "install_file_pair: requires source and destination paths"

  local src="$1" dest="$2" dest_dir backup_suffix

  # Ensure the source file/directory exists
  [[ -e "$src" ]] || error "Source does not exist: $src"

  # Resolve the destination directory path and create it if necessary
  dest_dir=$(dirname "$dest")
  create_dir "$dest_dir"

  # Create backup if destination exists
  if [[ -e "$dest" ]]; then
    backup_suffix=".backup.$(date +%Y%m%d_%H%M%S)"
    info "Creating backup: ${dest}${backup_suffix}"

    # If the destination is a symbolic link, back up the real file it points to
    if [[ -L "$dest" ]]; then
      local real_dest
      real_dest=$(readlink -f "$dest")

      # Check if the real destination exists before attempting to copy
      if [[ -e "$real_dest" ]]; then
        if [[ -d "$real_dest" ]]; then
          cp -rL "$real_dest" "${dest}${backup_suffix}"
        else
          cp -L "$real_dest" "${dest}${backup_suffix}"
        fi
      else
        info "Skipping backup: Symbolic link target does not exist: $real_dest"
      fi
    # If the destination is a regular file or directory, back it up normally
    elif [[ -d "$dest" ]]; then
      cp -r "$dest" "${dest}${backup_suffix}"
    else
      cp "$dest" "${dest}${backup_suffix}"
    fi
  fi

  # Install file (copy or symlink)
  if [[ ${LINK_INSTEAD_OF_COPY:-0} == 1 ]]; then
    # Create a symbolic link from the real source path to the destination
    ln -sf "$(realpath "$src")" "$dest" || error "Failed to create symlink: $src -> $dest"
    info "Symlinked: $(basename "$src") -> $(basename "$dest")"
  else
    # Copy the source, dereferencing any symlinks within it
    cp -rL "$src" "$dest" || error "Failed to copy: $src -> $dest"
    info "Copied: $(basename "$src") -> $(basename "$dest")"
  fi

  # Verify that the installation was successful
  [[ -e "$dest" ]] || error "Installation verification failed: $dest"

  info "Installation successful."
}

###################################################
# DEVELOPMENT ENVIRONMENT INSTALLATION
###################################################

# Install uv Python package manager with verification
install_uv() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-uv.sh"
}

# Install pyenv with enhanced setup and verification
install_pyenv() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-pyenv.sh"
}

# Install jenv Java version manager with platform detection
install_jenv() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-jenv.sh"
}

# Install Go Version Manager with comprehensive setup
install_gvm() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-gvm.sh"
}

# Install Node Version Manager with shell integration
install_nvm() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-nvm.sh"
}

# Install jdt-language-server
install_jdt_language_server() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-jdt-language-server.sh"
}

# Install google-java-format
install_google_java_format() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-google-java-format.sh"
}

# Install Go
install_golang() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-golang.sh" "$@"
}

# Install Hack Nerd Font
install_hack_nerd_font() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-hack-nerd-font.sh"
}

# Install shfmt (shell formatter)
# Arguments:
#   $1 - shfmt version to install (default: v3.7.0)
install_shfmt() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-shfmt.sh" "$@"
}

# Install fzf (fuzzy finder)
install_fzf() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-fzf.sh"
}

# Install Neovim text editor
# Arguments:
#   $1 - Neovim version to install (default: 0.11.0)
install_neovim() {
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-neovim.sh" "$@"
}

# Install AI code agents
install_ai_code_agents() {
  # Check if system supports modern plugins (npm >= 20)
  if ! SUPPORTS_MODERN_PLUGINS; then
    warn "npm version 20 or higher is required for AI code agents installation"
    warn "Current npm version: $(npm --version 2>/dev/null || echo 'not installed')"
    warn "Please upgrade npm to continue with AI code agents installation"
    return 1
  fi

  success "System supports modern plugins (npm >= 20), proceeding with AI code agents installation"

  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi
  "$script_dir/install-cargo.sh"
}

# Install Rust and Cargo with kernel version check
install_cargo() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$script_dir/install-cargo.sh"
}
