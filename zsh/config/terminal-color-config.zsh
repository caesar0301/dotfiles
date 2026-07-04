#############################################################
# Filename: ~/.config/zsh/config/terminal-color-config.zsh
#     About: Restore CLI colors inside tmux when IDE agents
#              pollute the environment (NO_COLOR, TERM=dumb).
#     Maintained by xiaming.cxm
#############################################################

# IDE agents (Cursor, VS Code, CI) often set NO_COLOR=1, FORCE_COLOR=0,
# and TERM=dumb. Claude Code and similar tools honor these and strip colors.
if [[ -o interactive && -t 1 && -n "$TMUX" ]]; then
  unset NO_COLOR NODE_DISABLE_COLORS
  [[ "${FORCE_COLOR:-}" == "0" ]] && unset FORCE_COLOR
  [[ "$TERM" == dumb ]] && export TERM=screen-256color
  export COLORTERM="${COLORTERM:-truecolor}"
fi
