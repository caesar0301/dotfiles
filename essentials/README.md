# Essential Development Tools

This module installs essential development tools and utilities for a productive development environment.

## Features

- **Local Utility Scripts**: The `dotme-xxx` series of custom tools
- **Python Version Manager**: pyenv for managing Python versions
- **Homebrew**: Package manager (optional, macOS/Linux)
- **Version Managers**: jenv, gvm, nvm for Java/Go/Node (optional)
- **AI Code Agents**: AI-powered development tools (optional)

## Installation

### Basic Installation

```bash
# Install with default settings (utility scripts + pyenv)
sh essentials/install.sh
```

### Optional Components

**Homebrew Package Manager:**
```bash
INSTALL_HOMEBREW=1 sh essentials/install.sh
```

**Development Version Managers** (jenv, gvm, nvm):
```bash
INSTALL_EXTRA_VENV=1 sh essentials/install.sh
```

**AI Code Agents** (requires Node.js >= 20):
```bash
INSTALL_AI_CODE_AGENTS=1 sh essentials/install.sh
```

**Full Installation:**
```bash
INSTALL_HOMEBREW=1 INSTALL_EXTRA_VENV=1 INSTALL_AI_CODE_AGENTS=1 sh essentials/install.sh
```

## What Gets Installed

### Local Utility Scripts (`~/.local/bin`)

The `dotme-xxx` series of custom tools:

| Script | Description |
|--------|-------------|
| `dotme-google-java-format` | Enhanced Google Java Format wrapper |
| `dotme-gpg` | GPG helper with key alias support |
| `dotme-decrypt-zshenv` | Decrypt local zshenv environment |
| `dotme-install-python` | Python installation helper |
| `dotme-rsync-parallel` | Parallel rsync wrapper |
| `dotme-run-container` | Docker container runner |

See [`bin/README.md`](../bin/README.md) for detailed documentation.

### Version Managers

| Tool | Purpose | Environment Variable |
|------|---------|---------------------|
| pyenv | Python version management | Always installed |
| Homebrew | Package manager | `INSTALL_HOMEBREW=1` |
| jenv | Java version management | `INSTALL_EXTRA_VENV=1` |
| gvm | Go version management | `INSTALL_EXTRA_VENV=1` |
| nvm | Node.js version management | `INSTALL_EXTRA_VENV=1` |

## Post-Installation

After installation, ensure `~/.local/bin` is in your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then restart your shell or run:

```bash
exec $SHELL
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `INSTALL_HOMEBREW` | `0` | Set to `1` to install Homebrew |
| `INSTALL_EXTRA_VENV` | `0` | Set to `1` to install jenv, gvm, nvm |
| `INSTALL_AI_CODE_AGENTS` | `0` | Set to `1` to install AI code agents |

## Related Modules

- [`zsh/`](../zsh/README.md) - Zsh shell configuration
- [`nvim/`](../nvim/README.md) - Neovim configuration
- [`bin/`](../bin/README.md) - Utility scripts documentation

