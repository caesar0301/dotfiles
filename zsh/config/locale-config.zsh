#############################################################
# Filename: ~/.config/zsh/config/locale-config.zsh
#     About: Configure locale settings for unicode support
#     Maintained by xiaming.cxm
#############################################################

# Ensure UTF-8 locale for proper unicode display
# This is critical for tmux sessions over SSH connections
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Export locale variables for remote sessions
# SSH passes these to remote hosts when AcceptEnv is configured
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"
export LC_COLLATE="${LC_COLLATE:-en_US.UTF-8}"
export LC_MESSAGES="${LC_MESSAGES:-en_US.UTF-8}"