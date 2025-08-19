#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory to ensure relative paths work correctly
cd "$SCRIPT_DIR"

python clash_config_fetcher.py -t ${TROJANFLARE_CLASHX_URL} \
  -g -o config.latest

python clash_config_fetcher.py -t ${TROJANFLARE_CLASHX_URL} \
  -g -w -d -o config.gfwlist
