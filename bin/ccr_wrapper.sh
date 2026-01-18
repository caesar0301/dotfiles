#!/bin/bash
# claude-code-wrapper for VSCode Claude Code Plugin

# 1. Disable Node.js DEP0190 Warning
export NODE_OPTIONS="--no-deprecation"

# 2. Make sure ccr in PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"

# 3. skip default first claude binnary command as argument
shift

exec ${HOME}/.local/bin/ccr code "$@"
