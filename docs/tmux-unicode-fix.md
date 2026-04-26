# Unicode Display Troubleshooting in Tmux Over Remote Connections

## Problem Analysis

When connecting to remote hosts via SSH in tmux, unicode characters may fail to display correctly due to:

### 1. Missing Locale Environment Variables
- **Cause**: Zsh configuration doesn't export locale variables that SSH passes to remote hosts
- **Symptom**: Unicode characters (emojis, special symbols) display as `?` or boxes
- **Location**: `/Users/xiaming/.dotfiles/zsh/init.zsh` lacked locale exports

### 2. SSH Not Passing Locale Variables
- **Cause**: SSH client doesn't send locale environment variables by default
- **Requirement**: Remote SSH server must accept these variables (AcceptEnv configured)
- **Impact**: Remote shell sessions start with incorrect or missing locale settings

### 3. Tmux Terminal Configuration
- **Status**: Already correctly configured with:
  - `tmux_conf_24b_colour=true` (line 73 in tmux.conf.local)
  - `terminal-features 'xterm-256color:RGB'` (line 76)
  - UTF-8 support enabled (lines 31-32 in tmux.conf)
- **Note**: No changes needed here

### 4. Remote Host Locale Issues
- **Cause**: Remote system lacks UTF-8 locale packages or configuration
- **Requirement**: Remote host must have locale packages installed and configured

## Implemented Fixes

### Fix 1: Locale Configuration File ✅
**Created**: `/Users/xiaming/.dotfiles/zsh/config/locale-config.zsh`

```zsh
# Ensure UTF-8 locale for proper unicode display
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"
export LC_COLLATE="${LC_COLLATE:-en_US.UTF-8}"
export LC_MESSAGES="${LC_MESSAGES:-en_US.UTF-8}"
```

**Purpose**: Sets and exports locale variables that SSH transmits to remote hosts

### Fix 2: Load Config Files in Init Script ✅
**Modified**: `/Users/xiaming/.dotfiles/zsh/init.zsh`

Added automatic loading of config files:
```zsh
# Load config files (locale, proxy, etc.)
for config_file in "${ZSH_CONFIG_DIR}/config"/*.zsh(N); do
  source "$config_file"
done
```

### Fix 3: Install Script Updates ✅
**Modified**: `/Users/xiaming/.dotfiles/zsh/install.sh`

- Added config directory installation
- Updated cleansing function to remove config directory

### Fix 4: SSH Configuration Reference ✅

SSH config snippet to pass locale variables:
```
Host *
    SendEnv LANG LC_ALL LC_CTYPE LC_COLLATE LC_MESSAGES LC_NUMERIC LC_TIME
```

## Installation Instructions

### Step 1: Install Locale Configuration

```bash
# Reinstall zsh configuration to apply locale settings
cd /Users/xiaming/.dotfiles/zsh
./install.sh -s

# Or manually copy config file
mkdir -p ~/.config/zsh/config
ln -sf /Users/xiaming/.dotfiles/zsh/config/locale-config.zsh ~/.config/zsh/config/locale-config.zsh
```

### Step 2: Add SSH Locale Configuration

```bash
# Check if SSH config exists
[ -f ~/.ssh/config ] || touch ~/.ssh/config

# Add locale configuration (preserve existing content)
cat >> ~/.ssh/config << 'EOF'

# Pass locale environment variables for unicode support
Host *
    SendEnv LANG LC_ALL LC_CTYPE LC_COLLATE LC_MESSAGES LC_NUMERIC LC_TIME
EOF
```

### Step 3: Restart Shell Session

```bash
# Restart zsh to apply locale configuration
exec zsh

# Verify locale settings
locale
```

### Step 4: Test in New Tmux Session

```bash
# Create new tmux session
tmux new-session -s test

# Test unicode display
echo "🚀 Testing unicode: 💛🩷💙🖤❤️🤍 αβγδ εζηθ"

# SSH to remote host and test
ssh user@remote-host
echo "🚀 Testing unicode on remote: 💛🩷💙🖤❤️🤍 αβγδ εζηθ"
```

## Remote Host Configuration

### Required Setup on Remote Hosts

**1. Install Locale Packages**

```bash
# Ubuntu/Debian
sudo apt-get install -y locales
sudo locale-gen en_US.UTF-8

# CentOS/RHEL/Fedora
sudo dnf install -y glibc-langpack-en
# or
sudo yum install -y glibc-common
sudo localedef -c -i en_US -f UTF-8 en_US.UTF-8

# Arch Linux
sudo pacman -S locales
sudo locale-gen
```

**2. Configure SSH Server to Accept Locale Variables**

```bash
# Edit SSH server config
sudo vim /etc/ssh/sshd_config

# Add or modify AcceptEnv line
AcceptEnv LANG LC_ALL LC_CTYPE LC_COLLATE LC_MESSAGES LC_NUMERIC LC_TIME

# Restart SSH service
sudo systemctl restart sshd
# or
sudo service sshd restart
```

**3. Set Default Locale on Remote Host**

```bash
# For current user
echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc

# System-wide (requires sudo)
sudo localectl set-locale LANG=en_US.UTF-8
# or add to /etc/environment
sudo echo 'LANG=en_US.UTF-8' >> /etc/environment
sudo echo 'LC_ALL=en_US.UTF-8' >> /etc/environment
```

## Verification Steps

### Local Verification

```bash
# Check locale environment
locale
# Expected output:
# LANG="en_US.UTF-8"
# LC_ALL="en_US.UTF-8"
# LC_CTYPE="en_US.UTF-8"

# Check tmux environment
tmux show-environment -g | grep -i "lang\|lc_"
# Expected: LANG=en_US.UTF-8

# Test unicode display in tmux
tmux new-session -s unicode-test
echo "💛🩷💙🖤❤️🤍 Testing: → ↑ ↓ ◼ ◻ ⌨ ⚷"
```

### Remote Verification

```bash
# SSH with verbose locale passing
ssh -v user@remote-host 2>&1 | grep -i "locale\|lang"

# Check remote locale after SSH
ssh user@remote-host 'locale'

# Test unicode display on remote in tmux
ssh user@remote-host
tmux list-sessions || tmux new-session -s remote-test
echo "💛🩷💙🖤❤️🤍 Remote unicode test: → ↑ ↓ ◼ ◻"
```

## Troubleshooting Commands

### Check Local Configuration

```bash
# Verify zsh config loaded locale
zsh -c 'echo $LANG $LC_ALL'

# Check if locale-config.zsh is sourced
zsh -c 'source ~/.config/zsh/init.zsh && locale'

# Inspect tmux terminal settings
tmux show -gqv default-terminal
tmux show -gqv terminal-features
```

### Debug SSH Locale Transmission

```bash
# Test locale passing explicitly
ssh -o "SendEnv LANG LC_ALL" user@remote-host 'locale'

# Check SSH client config
cat ~/.ssh/config | grep -A5 "SendEnv"

# Test without locale passing (baseline)
ssh user@remote-host 'locale'
```

### Remote Host Diagnostics

```bash
# Check available locales on remote
ssh user@remote-host 'locale -a | grep -i utf'

# Test if locale command works
ssh user@remote-host 'locale'

# Check SSH server AcceptEnv
ssh user@remote-host 'sudo grep AcceptEnv /etc/ssh/sshd_config'
```

## Common Issues and Solutions

### Issue 1: Remote Host Missing UTF-8 Locale

**Symptom**: `locale: Cannot set LC_CTYPE to default locale: No such file or directory`

**Solution**:
```bash
# On remote host
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

### Issue 2: SSH Server Not Accepting Locale Variables

**Symptom**: Remote locale unchanged after SSH connection despite client SendEnv

**Solution**: Configure SSH server to accept variables (see Remote Host Configuration step 2)

### Issue 3: Tmux Shows Question Marks Instead of Unicode

**Symptom**: Unicode displays as `?` or `□` inside tmux sessions

**Solution**:
1. Verify locale is set correctly (locale command)
2. Check tmux UTF-8 support: `tmux show -gqv utf8` (should show "on")
3. Test outside tmux first, then inside tmux
4. Restart tmux server: `tmux kill-server && tmux new-session`

### Issue 4: Font Missing Unicode Glyphs

**Symptom**: Unicode shows as boxes even with correct locale

**Solution**:
```bash
# Install nerd fonts for comprehensive unicode support
brew install --cask font-hack-nerd-font  # macOS
# or
sudo apt-get install fonts-hack-ttf      # Linux

# Configure terminal to use the font
# In terminal settings, select "Hack Nerd Font" or similar
```

## Additional Resources

- **SSH Locale Passing**: `man ssh_config` (Search for SendEnv)
- **SSH Server Configuration**: `man sshd_config` (Search for AcceptEnv)
- **Locale Setup**: `man locale`, `man localedef`
- **Tmux UTF-8**: `man tmux` (Search for utf8, status-utf8)
- **XDG Locale Variables**: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

## Files Modified

1. `/Users/xiaming/.dotfiles/zsh/config/locale-config.zsh` - New locale configuration
2. `/Users/xiaming/.dotfiles/zsh/init.zsh` - Updated to load config files
3. `/Users/xiaming/.dotfiles/zsh/install.sh` - Updated to install config directory
4. SSH config snippet documented inline (no separate file needed)

## Next Steps

1. Run zsh install script to apply locale configuration
2. Add SSH SendEnv configuration to ~/.ssh/config
3. Configure remote hosts to accept locale variables
4. Test unicode display in tmux sessions locally and remotely
5. Restart existing tmux sessions to apply changes