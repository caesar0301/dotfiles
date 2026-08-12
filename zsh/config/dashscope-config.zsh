#############################################################
# Filename: ~/.config/zsh/config/dashscope-config.zsh
# About: Random credential pair selection for DashScope LLM
#
# Reads base_url|api_key pairs from a credential pool file
# and randomly selects one, exporting DASHSCOPE_BASE_URL and
# DASHSCOPE_API_KEY. Runs silently at shell startup.
#############################################################

_DASHSCOPE_KEYS_FILE="$HOME/.dotfiles/lib/dashscope-keys.conf"

# Randomly pick a base_url+api_key pair and export it.
# Usage: dashscope_pick [path-to-keys-file]
# Options: DASHSCOPE_DEBUG=1 to print selection info.
dashscope_pick() {
  local keys_file="${1:-$_DASHSCOPE_KEYS_FILE}"

  if [[ ! -f "$keys_file" ]]; then
    [[ "${DASHSCOPE_DEBUG:-0}" == "1" ]] && \
      print "dashscope_pick: keys file not found: $keys_file" >&2
    return 1
  fi

  # Collect valid lines (skip comments and blanks)
  local -a pairs=()
  local line
  while IFS= read -r line; do
    # Strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == '#'* ]] && continue
    pairs+=("$line")
  done < "$keys_file"

  if (( ${#pairs[@]} == 0 )); then
    [[ "${DASHSCOPE_DEBUG:-0}" == "1" ]] && \
      print "dashscope_pick: no valid pairs in $keys_file" >&2
    return 1
  fi

  # Random selection (zsh arrays are 1-indexed)
  local idx=$(( (RANDOM % ${#pairs[@]}) + 1 ))
  local selected="${pairs[$idx]}"

  local base_url="${selected%%|*}"
  local api_key="${selected#*|}"

  if [[ -z "$base_url" || -z "$api_key" ]]; then
    [[ "${DASHSCOPE_DEBUG:-0}" == "1" ]] && \
      print "dashscope_pick: malformed line: $selected" >&2
    return 1
  fi

  export DASHSCOPE_BASE_URL="$base_url"
  export DASHSCOPE_API_KEY="$api_key"

  [[ "${DASHSCOPE_DEBUG:-0}" == "1" ]] && \
    print "DashScope: selected pair $idx of ${#pairs[@]} → $base_url"
}

# Auto-pick on shell startup (completely silent)
# Silently skips if keys file does not exist.
[[ -f "$_DASHSCOPE_KEYS_FILE" ]] && dashscope_pick
