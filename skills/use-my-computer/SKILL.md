---
name: use-my-computer
description: Manage dotfiles, troubleshoot environment issues, configure development tools, and handle system-level setups. Use when user mentions environment setup, PATH issues, tool installation, shell configuration, or any task involving ~/.dotfiles, ~/.config, ~/.local, or system configuration. Trigger on phrases like "setup my environment", "fix PATH", "install tools", "configure shell", "check my dotfiles", "update my setup", or troubleshooting missing tools.
---

# Computer Use - Dotfiles and Environment Management

This skill helps you manage a modern development environment using the cool-dotfiles repository. It understands the architecture, follows XDG Base Directory specification, and handles both macOS and Linux systems.

## When to Use This Skill

Use this skill proactively when the user's task involves:

- **Environment setup**: "setup my dev environment", "install development tools", "configure my shell"
- **Troubleshooting**: "fix PATH", "tool not found", "check my configuration", "why isn't X working"
- **Dotfiles management**: "update my dotfiles", "install new config", "check my zsh setup"
- **Tool installation**: "install nvim plugins", "add a new tool", "setup language support"
- **System awareness**: Any reference to ~/.dotfiles, ~/.config, ~/.local, Homebrew, version managers

Even if the user doesn't explicitly mention "dotfiles", if they're working with shell configs, PATH issues, or environment setup, use this skill.

## Core Principles

### XDG Base Directory Compliance

This repository follows XDG specification strictly. Always prefer XDG paths:

- `XDG_CONFIG_HOME` → `~/.config` (configuration files)
- `XDG_DATA_HOME` → `~/.local/share` (data and plugins)
- `XDG_CACHE_HOME` → `~/.cache` (cache files)

**Default locations:**
- Zsh configs → `~/.config/zsh/`
- Neovim configs → `~/.config/nvim/`
- Tmux configs → `~/.config/tmux/`
- Custom tools → `~/.local/bin/`

Only use legacy paths (like `~/.zshrc`, `~/.vimrc`) if the user explicitly requests them or has existing non-XDG setups.

### Cross-Platform Detection

Always detect the platform before acting:

```bash
# Use shlib.sh platform detection functions
source ~/.dotfiles/lib/shlib.sh
is_macos && # macOS-specific operations
is_linux && # Linux-specific operations
```

**Platform-specific considerations:**

- **macOS**: Homebrew, system proxy setup (Network settings), Docker-based Mihomo
- **Linux**: Systemd services, kernel version checks, package managers

### Interactive Confirmation

For operations that modify the system, show what will happen and ask:

```
I'm about to:
- Install [tool] using [method]
- Modify [file] to add [configuration]
- Remove [old config] from [location]

Proceed? (y/n)
```

Only execute after explicit confirmation. For read-only operations (checking status, diagnosing issues), proceed directly.

## Repository Architecture

The dotfiles repository (`~/.dotfiles` or user's configured location) has a structured architecture you must respect.

### Understanding the Structure

**Master Orchestrators:**
- `install_all.sh` → Full installation (all modules)
- `install_basics.sh` → Core components (zsh, tmux, nvim)
- Both auto-run `lib/install-essentials.sh` for prerequisites

**Module Structure:**
Each module (zsh/, nvim/, tmux/, etc.) has:
- `install.sh` script with flags: `-s` (symlink), `-f` (copy), `-c` (clean)
- Sources `lib/shlib.sh` for utilities
- Follows XDG paths

**Key directories:**
- `lib/` → Installation scripts for individual tools (pyenv, fzf, Homebrew, etc.)
- `bin/` → Custom `dotme-xxx` tools installed to `~/.local/bin`
- `setups/` → System-level configs (Mihomo proxy, systemd services)
- `zsh/plugins/` → Custom Zsh plugins

**Always read CLAUDE.md** from the repository root to understand current architecture, available modules, and installation patterns.

### Using Install Scripts

When installing or updating components, use the provided scripts rather than manual file copying:

```bash
# Install core components
cd ~/.dotfiles
./install_basics.sh

# Install specific modules
./install_all.sh -m zsh,tmux,nvim

# Install a single tool
./lib/install-pyenv.sh
./lib/install-fzf.sh
```

**Installation flags:**
- `-s` → Symlinks (default, recommended for easy updates)
- `-f` → Force copy (when symlinks aren't desired)
- `-c` → Clean/remove configs
- `-m` → Select specific modules

### Custom Tools

The `bin/` directory contains `dotme-xxx` utilities. These are installed to `~/.local/bin` and added to PATH via `zsh/init.zsh`.

**Available tools:**
- `dotme-google-java-format` → Enhanced Java formatter
- `dotme-gpg` → GPG helper with key aliases
- `dotme-decrypt-zshenv` → Decrypt encrypted environment files
- `dotme-install-python` → Python version installer
- `dotme-rsync-parallel` → Parallel rsync wrapper
- `dotme-run-container` → Docker container runner

Check `bin/README.md` for detailed documentation.

## Common Workflows

### Environment Setup and Installation

**Full setup:**
1. Check if dotfiles repo exists: `ls ~/.dotfiles`
2. Read CLAUDE.md to understand available components
3. Ask user which modules they want (or use defaults)
4. Run appropriate install script: `./install_basics.sh` or `./install_all.sh`
5. Restart shell: `exec $SHELL`

**Selective installation:**
```bash
./install_all.sh -m zsh,nvim
./misc/install.sh -m kitty,alacritty
```

**Update existing setup:**
```bash
cd ~/.dotfiles
git pull
./install_basics.sh  # Re-run to update symlinks
```

### PATH and Environment Troubleshooting

**Check PATH configuration:**
```bash
echo $PATH
# Expected: ~/.local/bin should be present
# Check zsh config: ~/.config/zsh/init.zsh
```

**Diagnose missing tool:**
1. Check if tool is installed: `which <tool>`
2. Check if in PATH: `echo $PATH | grep ~/.local/bin`
3. Check if config was installed: `ls ~/.config/<tool>`
4. Run install script if missing: `./lib/install-<tool>.sh`

**Fix PATH issues:**
- Ensure `zsh/init.zsh` adds `~/.local/bin` to PATH
- Restart shell: `exec $SHELL`
- If still broken, check for conflicts in `/etc/profile`, `~/.profile`

### Shell Configuration Management

**Zsh:**
- Config location: `~/.config/zsh/init.zsh`
- Plugin manager: Zinit (installed to `~/.local/share/zinit`)
- Custom plugins: `~/.config/zsh/plugins/`
- Proxy config: `~/.config/proxy` (if needed)

**Installing Zsh plugins:**
Add to `~/.config/zsh/init.zsh`:
```zsh
zinit load <plugin-name>
```

**Updating Zsh config:**
```bash
cd ~/.dotfiles
./zsh/install.sh  # Re-symlink configs
exec $SHELL
```

### Neovim Setup and Plugins

**Neovim:**
- Config location: `~/.config/nvim/`
- Plugin manager: Lazy.nvim (auto-installed)
- Python support: Run `./lib/install-nvim-python.sh`

**Kernel version checks:**
On Linux, Neovim checks kernel version to disable incompatible plugins:
```bash
uname -r  # If < 5.0, some modern plugins are disabled
```

**Plugin management:**
Plugins are managed by Lazy.nvim. Open Neovim and run:
- `:Lazy` → Plugin manager UI
- `:Lazy install` → Install new plugins
- `:Lazy update` → Update all plugins

### Version Managers

**Always installed:**
- `pyenv` → Python versions

**Optional (INSTALL_EXTRA_VENV=1):**
- `jenv` → Java versions
- `gvm` → Go versions
- `nvm` → Node.js versions
- `rbenv` → Ruby versions

**Installing version managers:**
```bash
INSTALL_EXTRA_VENV=1 ./lib/install-essentials.sh
```

**Using pyenv:**
```bash
pyenv install 3.11.0
pyenv global 3.11.0
pyenv versions
```

### System-Level Infrastructure

The `setups/` directory contains system-level configurations beyond user dotfiles.

**Mihomo proxy (Docker-based for macOS):**
```bash
cd ~/.dotfiles/setups/mihomo
./start.sh -c ~/.config/mihomo
# Exposes: 7890 (proxy), 9090 (controller)
# Setup system proxy: System Settings → Network → Proxies
```

**Mihomo proxy (Systemd for Linux):**
```bash
sudo cp ~/.dotfiles/setups/systemd/mihomo.service /etc/systemd/system/
sudo systemctl enable mihomo
sudo systemctl start mihomo
```

**Other systemd services:**
- `colima.service` → Container runtime (user service)
- `minikube.service` → Kubernetes cluster (system service)
- `aliyunpan-sync.service` → File sync (user service)

Install user services to: `~/.config/systemd/user/`
Install system services to: `/etc/systemd/system/`

## Troubleshooting Guide

### Tool Not Found

**Diagnostic steps:**
1. Check installation: `which <tool>`
2. Check PATH: `echo $PATH`
3. Check install script ran: `ls ~/.local/bin`
4. Check XDG paths: `ls ~/.config`, `ls ~/.local/share`
5. Run install script: `./lib/install-<tool>.sh`

**Common causes:**
- Shell not restarted after install → Run `exec $SHELL`
- PATH missing `~/.local/bin` → Check `~/.config/zsh/init.zsh`
- Install script not run → Run appropriate installer

### Configuration Not Loading

**Zsh config issues:**
- Check `~/.zshrc` exists and sources `~/.config/zsh/init.zsh`
- Check Zinit installed: `ls ~/.local/share/zinit/zinit.git`
- Check for syntax errors: `zsh -c "source ~/.config/zsh/init.zsh"`

**Neovim config issues:**
- Check `~/.config/nvim/init.lua` exists
- Check Lazy.nvim installed: `ls ~/.local/share/nvim/lazy/lazy.nvim`
- Open Neovim to auto-install plugins
- Check kernel version on Linux: `uname -r` (must be >= 5.0 for some plugins)

### Permission Issues

**Fix permissions:**
```bash
# Fix ~/.local/bin permissions
chmod +x ~/.local/bin/*

# Fix Zsh plugin permissions
chmod +x ~/.config/zsh/plugins/*/*.plugin.zsh
```

### Cross-Platform Issues

**macOS-specific:**
- Homebrew install: Check `/opt/homebrew` (Apple Silicon) or `/usr/local/Homebrew` (Intel)
- System proxy: Check Network Settings → Proxies
- Mihomo: Use Docker version from `setups/mihomo`

**Linux-specific:**
- Kernel version: Check with `uname -r` for plugin compatibility
- Systemd: Use services from `setups/systemd/`
- Package managers: Check distribution-specific paths

## Bundled Helper Scripts

This skill bundles diagnostic scripts for common troubleshooting tasks. Use these instead of reinventing manual diagnostics.

### check_environment.sh

Comprehensive environment health check:

```bash
# Usage
~/.dotfiles/skills/use-my-computer/scripts/check_environment.sh

# Checks:
# - Dotfiles repository presence
# - XDG paths setup
# - PATH configuration
# - Core tools (zsh, nvim, tmux)
# - Version managers (pyenv, etc.)
# - Shell config loading
# - Platform-specific issues
```

**Output:** Detailed report of environment status with recommendations.

### diagnose_path.sh

PATH-specific diagnostics:

```bash
# Usage
~/.dotfiles/skills/use-my-computer/scripts/diagnose_path.sh [tool-name]

# Checks:
# - Current PATH value
# - Expected paths for platform
# - Missing critical directories
# - Specific tool location if provided
# - Conflicts and duplicates
```

**Output:** PATH analysis with fix recommendations.

### tool_status.sh

Check status of specific tools:

```bash
# Usage
~/.dotfiles/skills/use-my-computer/scripts/tool_status.sh <tool-name>

# Checks:
# - Tool binary location
# - Configuration presence
# - Version
# - Dependencies
# - Platform compatibility
```

**Output:** Tool-specific status report.

### install_helper.sh

Safe installation wrapper:

```bash
# Usage
~/.dotfiles/skills/use-my-computer/scripts/install_helper.sh <component>

# Features:
# - Validates component exists in dotfiles
# - Shows what will be installed
# - Asks for confirmation
# - Runs appropriate install script
# - Verifies installation success
# - Reports PATH updates needed
```

**Output:** Installation result with next steps.

## Best Practices

### Reading Before Acting

Always read relevant documentation before modifying:

1. **CLAUDE.md** → Repository architecture, available modules
2. **Module README** → Specific module documentation (zsh/README.md, nvim/README.md)
3. **bin/README.md** → Custom tools documentation
4. **setups/*/README.md** → Infrastructure setup guides

### Using Existing Infrastructure

Don't manually copy files or create configs from scratch. Use:

- Install scripts (`./install_*.sh`) for setup
- Library scripts (`lib/install-*.sh`) for individual tools
- Module scripts (`zsh/install.sh`, `nvim/install.sh`) for components
- Custom tools (`dotme-xxx`) for specialized operations

### Platform-Aware Recommendations

Tailor advice based on detected platform:

- **macOS**: Recommend Homebrew, Docker-based Mihomo, GUI settings integration
- **Linux**: Recommend systemd services, kernel version checks, distribution-specific package managers

### Respecting User Setup

If user has existing configurations outside XDG paths:

1. Ask about migration preference
2. If they want to keep legacy setup, respect it
3. If they want XDG, help migrate safely
4. Show both options and let them decide

### Shell Restart After Changes

Any change to shell configs requires restart:

```bash
exec $SHELL
```

Remind user after modifying PATH, Zsh configs, or installing tools that affect shell environment.

## Examples

### Example 1: Install Missing Tool

**User request:** "I need ripgrep for telescope.nvim"

**Your response:**
1. Check if installed: `which rg`
2. If missing, read CLAUDE.md to find install script
3. Check platform: `is_macos` or `is_linux`
4. Show plan: "I'll install ripgrep using Homebrew (your package manager)"
5. Ask confirmation
6. Execute: `brew install ripgrep`
7. Verify: `which rg && rg --version`
8. Remind: "Restart shell if PATH changed: exec $SHELL"

### Example 2: Fix PATH Issue

**User request:** "dotme-google-java-format command not found"

**Your response:**
1. Run diagnostic: `scripts/diagnose_path.sh dotme-google-java-format`
2. Check if installed: `ls ~/.local/bin`
3. If tool exists but PATH broken: Check `~/.config/zsh/init.zsh` for PATH setup
4. If tool missing: Check CLAUDE.md, run `./lib/install-google-java-format.sh`
5. Fix PATH: Ensure `~/.config/zsh/init.zsh` adds `~/.local/bin`
6. Restart shell: `exec $SHELL`
7. Verify: `dotme-google-java-format --version`

### Example 3: Setup New Environment

**User request:** "setup my development environment on this new machine"

**Your response:**
1. Check dotfiles presence: `ls ~/.dotfiles`
2. If missing, clone: `git clone https://github.com/caesar0301/dotfiles.git ~/.dotfiles`
3. Read CLAUDE.md for available modules
4. Ask: "Do you want basic (zsh, tmux, nvim) or full installation?"
5. Ask: "Do you need extra version managers (jenv, gvm, nvm)?"
6. Show plan: "I'll run install_basics.sh which installs core tools + prerequisites"
7. Execute: `cd ~/.dotfiles && ./install_basics.sh`
8. Restart shell: `exec $SHELL`
9. Verify: Run `scripts/check_environment.sh`
10. Report: Summary of installed components and next steps

### Example 4: Configure System Proxy

**User request:** "setup network proxy for development"

**Your response:**
1. Detect platform
2. **macOS path:**
   - Check Docker installed: `which docker`
   - Show plan: "I'll setup Mihomo in Docker from setups/mihomo"
   - Ask: "Where is your proxy config? (default: ~/.config/mihomo)"
   - Execute: `cd ~/.dotfiles/setups/mihomo && ./start.sh -c ~/.config/mihomo`
   - Guide: "Now setup system proxy: System Settings → Network → Proxies → HTTP/HTTPS: 127.0.0.1:7890"
   - Check: Verify port 7890 listening: `lsof -i :7890`
3. **Linux path:**
   - Check systemd: `which systemctl`
   - Show plan: "I'll install Mihomo as systemd service"
   - Ask: "Do you have Mihomo binary and config ready?"
   - Execute: Copy service file, enable, start
   - Check: `sudo systemctl status mihomo`

## Quick Reference Commands

```bash
# Check environment status
~/.dotfiles/skills/use-my-computer/scripts/check_environment.sh

# Diagnose PATH
~/.dotfiles/skills/use-my-computer/scripts/diagnose_path.sh

# Check tool status
~/.dotfiles/skills/use-my-computer/scripts/tool_status.sh <tool>

# Safe install wrapper
~/.dotfiles/skills/use-my-computer/scripts/install_helper.sh <component>

# Dotfiles installation
cd ~/.dotfiles
./install_basics.sh        # Core components
./install_all.sh           # Full installation
./install_all.sh -m zsh,nvim  # Selective

# Shell restart
exec $SHELL

# Platform detection
source ~/.dotfiles/lib/shlib.sh
is_macos && echo "macOS"
is_linux && echo "Linux"
```