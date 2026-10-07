#############################################################
# Filename: ~/.config/zsh/config/ai-agents-config.zsh
#     About: Short aliases for AI agent CLIs
#     Maintained by xiaming.cxm
#############################################################

#   oc → opencode, with --thinking auto-injected for the `run` subcommand.
#        --thinking (show reasoning/thinking blocks) is a `run`-subcommand
#        flag only; it is NOT a valid top-level/TUI flag, so we cannot simply
#        alias `oc='opencode --thinking'` (that would break both the TUI and
#        `oc run ...`). The function below places --thinking right after
#        `run` so it is parsed by the subcommand:
#          oc            → opencode                       (launch TUI)
#          oc run "hi"   → opencode run --thinking "hi"   (show thinking)
#          oc run -c     → opencode run --thinking -c
#        To start the TUI without thinking, just run `opencode` directly.
#   cc → claude --dangerously-skip-permissions
#   cb → codebuddy --dangerously-skip-permissions   (a.k.a. -y)
#
# To run a one-shot without the bypass, invoke the binary directly:
#   opencode, claude, codebuddy

oc() {
  if [[ "$1" == "run" ]]; then
    shift
    command opencode run --thinking "$@"
  else
    command opencode "$@"
  fi
}
alias cc='claude --dangerously-skip-permissions'
alias cb='codebuddy --dangerously-skip-permissions'
