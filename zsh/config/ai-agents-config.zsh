#############################################################
# Filename: ~/.config/zsh/config/ai-agents-config.zsh
#     About: Short aliases for AI agent CLIs
#     Maintained by xiaming.cxm
#############################################################

# All three aliases default to bypassing permission prompts so agents can run
# without interactive confirmation:
#   oc → opencode --auto
#        auto-approves any permission request not explicitly denied
#        (see https://opencode.ai/docs/permissions/)
#   cc → claude --dangerously-skip-permissions
#   cb → codebuddy --dangerously-skip-permissions   (a.k.a. -y)
#
# To run a one-shot without the bypass, invoke the binary directly:
#   opencode, claude, codebuddy
# Any extra args you pass to the alias are appended after the flag, so
#   cc --resume   →  claude --dangerously-skip-permissions --resume

alias oc='opencode'
alias cc='claude --dangerously-skip-permissions'
alias cb='codebuddy --dangerously-skip-permissions'
