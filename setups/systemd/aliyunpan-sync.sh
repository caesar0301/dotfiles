#!/bin/bash
set -euo pipefail

# =============================================================================
# Aliyunpan Sync Script
# Syncs files between local directory and Aliyun Drive
# =============================================================================

# Configuration
export ALIYUNPAN_VERBOSE="${ALIYUNPAN_VERBOSE:-0}"
export ALIYUNPAN_CONFIG_DIR="${ALIYUNPAN_CONFIG_DIR:-$HOME/.config/aliyunpan}"

# Local directory to sync
LOCAL_DIR="${LOCAL_DIR:-$HOME/Documents/Aliyunpan/Research}"
# Remote directory on Aliyun Drive
PAN_DIR="${PAN_DIR:-/Research}"
# Sync mode: upload (local->cloud), download (cloud->local)
SYNC_MODE="${SYNC_MODE:-download}"
# Sync policy: exclusive (delete extra files in target), increment (keep extra files)
SYNC_POLICY="${SYNC_POLICY:-increment}"
# Drive type: backup, resource
DRIVE_TYPE="${DRIVE_TYPE:-resource}"

# =============================================================================
# Helper Functions
# =============================================================================

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" >&2
}

# =============================================================================
# Validation
# =============================================================================

# Find aliyunpan binary
ALIYUNPAN_BIN="${ALIYUNPAN_BIN:-$(command -v aliyunpan 2>/dev/null || true)}"

if [[ -z "$ALIYUNPAN_BIN" ]]; then
    log_error "aliyunpan binary not found in PATH"
    log_error "Please install aliyunpan or set ALIYUNPAN_BIN environment variable"
    exit 1
fi

if [[ ! -x "$ALIYUNPAN_BIN" ]]; then
    log_error "aliyunpan binary is not executable: $ALIYUNPAN_BIN"
    exit 1
fi

# Validate config directory
if [[ ! -d "$ALIYUNPAN_CONFIG_DIR" ]]; then
    log_error "Config directory does not exist: $ALIYUNPAN_CONFIG_DIR"
    log_error "Please run 'aliyunpan login' first to authenticate"
    exit 1
fi

# Validate config file (created after successful login)
ALIYUNPAN_CONFIG_FILE="$ALIYUNPAN_CONFIG_DIR/aliyunpan_config.json"
if [[ ! -f "$ALIYUNPAN_CONFIG_FILE" ]]; then
    log_error "Config file not found: $ALIYUNPAN_CONFIG_FILE"
    log_error "Please run 'aliyunpan login' first to authenticate with Aliyun Drive"
    exit 1
fi

# Validate local directory
if [[ ! -d "$LOCAL_DIR" ]]; then
    log_warn "Local directory does not exist, creating: $LOCAL_DIR"
    mkdir -p "$LOCAL_DIR"
fi

# Validate sync mode
if [[ "$SYNC_MODE" != "upload" && "$SYNC_MODE" != "download" ]]; then
    log_error "Invalid sync mode: $SYNC_MODE (must be 'upload' or 'download')"
    exit 1
fi

# Validate sync policy
if [[ "$SYNC_POLICY" != "exclusive" && "$SYNC_POLICY" != "increment" ]]; then
    log_error "Invalid sync policy: $SYNC_POLICY (must be 'exclusive' or 'increment')"
    exit 1
fi

# Validate drive type
if [[ "$DRIVE_TYPE" != "backup" && "$DRIVE_TYPE" != "resource" ]]; then
    log_error "Invalid drive type: $DRIVE_TYPE (must be 'backup' or 'resource')"
    exit 1
fi

# =============================================================================
# Main
# =============================================================================

log_info "Starting aliyunpan sync"
log_info "  Binary: $ALIYUNPAN_BIN"
log_info "  Config: $ALIYUNPAN_CONFIG_DIR"
log_info "  Local:  $LOCAL_DIR"
log_info "  Remote: $PAN_DIR"
log_info "  Mode:   $SYNC_MODE"
log_info "  Policy: $SYNC_POLICY"
log_info "  Drive:  $DRIVE_TYPE"

exec "$ALIYUNPAN_BIN" sync start \
    -ldir "$LOCAL_DIR" \
    -pdir "$PAN_DIR" \
    -mode "$SYNC_MODE" \
    -policy "$SYNC_POLICY" \
    -drive "$DRIVE_TYPE"
