#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEFAULT_CONFIG_DIR="$SCRIPT_DIR/config"
CONFIG_SOURCE_DIR="$DEFAULT_CONFIG_DIR"
PROJECT_NAME="mihomo"

usage() {
  cat <<USAGE
Usage: ./start.sh [-c /path/to/config-dir] [-n project_name]

Options:
  -c  Directory containing config.yaml.
      Default: $DEFAULT_CONFIG_DIR
  -n  Docker compose project name (default: mihomo)
  -h  Show this help message
USAGE
}

while getopts ":c:n:h" opt; do
  case "$opt" in
  c) CONFIG_SOURCE_DIR="$OPTARG" ;;
  n) PROJECT_NAME="$OPTARG" ;;
  h)
    usage
    exit 0
    ;;
  :)
    echo "Option -$OPTARG requires an argument" >&2
    exit 1
    ;;
  \?)
    echo "Unknown option: -$OPTARG" >&2
    usage
    exit 1
    ;;
  esac
done

CONFIG_SOURCE_DIR=$(cd "$CONFIG_SOURCE_DIR" && pwd)
CONFIG_FILE="$CONFIG_SOURCE_DIR/config.yaml"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config file: $CONFIG_FILE" >&2
  echo "Please provide a directory with config.yaml via -c." >&2
  exit 1
fi

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
else
  echo "docker compose (or docker-compose) is required." >&2
  exit 1
fi

echo "Starting mihomo using config directory: $CONFIG_SOURCE_DIR"
"${COMPOSE_CMD[@]}" \
  --project-name "$PROJECT_NAME" \
  -f "$SCRIPT_DIR/docker-compose.yaml" \
  up -d \
  --force-recreate \
  --remove-orphans

echo ""
echo "Mihomo is starting."
echo "Proxy endpoint (HTTP):  127.0.0.1:17890"
echo "Proxy endpoint (SOCKS): 127.0.0.1:17891"
echo "External controller:    127.0.0.1:19090"
echo "Web console (hosted):   https://metacubex.github.io/metacubexd/#/"
echo "When opening the panel, connect it to: http://127.0.0.1:19090"
