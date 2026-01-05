#!/usr/bin/env zsh

# =====================
# Superman Utilities
# =====================

# --- Error Output Utility ---
# Print error if verbose mode is enabled
_superman_print_error() {
  if [[ -n "$ZSH_CAESARDEV_VERBOSE" ]]; then
    echo "$1" >&2
  fi
}

# --- Decryption Utilities ---
# Decrypt a file using dotme-gpg tool
_superman_decrypt_file() {
  local alias_name="${1:-default}"
  local encrypted_file="${2:-}"
  local target_file="${3:-}"
  local gpg_tool="$HOME/.dotfiles/bin/dotme-gpg"

  # Help message
  if [[ "$alias_name" == "help" || "$alias_name" == "-h" || "$alias_name" == "--help" ]]; then
    echo "Superman Decrypt Function"
    echo ""
    echo "Usage: _superman_decrypt_file [alias] [encrypted_file] [target_file]"
    echo ""
    echo "Parameters:"
    echo "  alias: GPG alias to use (default: 'default')"
    echo "  encrypted_file: Path to encrypted file"
    echo "  target_file: Path to output decrypted file"
    echo ""
    echo "Examples:"
    echo "  _superman_decrypt_file default /path/to/file.enc /path/to/output"
    echo "  _superman_decrypt_file my-alias /path/to/file.enc /path/to/output"
    return 0
  fi

  # Check for required files and tools
  if [[ -z "$encrypted_file" || -z "$target_file" ]]; then
    _superman_print_error "Missing encrypted_file or target_file argument"
    return 1
  fi
  if [[ ! -f "$encrypted_file" ]]; then
    _superman_print_error "Encrypted file '$encrypted_file' not found"
    return 1
  fi
  if [[ ! -x "$gpg_tool" ]]; then
    _superman_print_error "$gpg_tool not found or not executable"
    return 1
  fi

  # Backup existing target file
  if [[ -f "$target_file" ]]; then
    local backup_file="${target_file:h}/.zshenv.local.bak"
    cp "$target_file" "$backup_file"
  fi

  # Decrypt to a temporary file first
  local tmp_decrypt_file
  tmp_decrypt_file=$(mktemp "${target_file}.tmp.XXXXXX") || { _superman_print_error "mktemp failed"; return 1; }
  if "$gpg_tool" dec "$alias_name" "$encrypted_file" >"$tmp_decrypt_file" 2>/dev/null; then
    mv "$tmp_decrypt_file" "$target_file"
    return 0
  else
    _superman_print_error "Failed to decrypt $encrypted_file"
    rm -f "$tmp_decrypt_file"
    return 1
  fi
}

# Decrypt and source local .zshenv.local.env
_superman_decrypt_and_source_local_env() {
  local script_dir="${${(%):-%x}:h}"
  local encrypted_file="$script_dir/.zshenv.local.enc"
  local decrypted_file="$HOME/.zshenv.local"

  if [[ ! -f "$encrypted_file" ]]; then
    _superman_print_error "Encrypted file not found at $encrypted_file"
    return 1
  fi

  if ! _superman_decrypt_file "drjaminchen" "$encrypted_file" "$decrypted_file"; then
    _superman_print_error "Failed to decrypt .zshenv.local.enc"
    return 1
  fi

  if [[ ! -f "$decrypted_file" ]]; then
    _superman_print_error "Decrypted file not found at $decrypted_file"
    return 1
  fi

  if ! source "$decrypted_file"; then
    _superman_print_error "Failed to source .zshenv.local"
    return 1
  fi
  return 0
}
