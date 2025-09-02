# Install Script Adaptation for Lazy.nvim

## Changes Made to install.sh

### 1. Plugin Manager Installation
**Before (Packer):**
```bash
PACKER_HOME="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_HOME"
```

**After (Lazy.nvim):**
```bash
LAZY_HOME="$HOME/.local/share/nvim/lazy/lazy.nvim"
git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_HOME"
```

### 2. Cleanup Function
**Before:**
```bash
rm -rf "$XDG_DATA_HOME/nvim/site/pack"
```

**After:**
```bash
rm -rf "$XDG_DATA_HOME/nvim/lazy"
```

### 3. User Instructions
**Before:**
```bash
warn "Run :PackerInstall in Neovim to install plugins:"
```

**After:**
```bash
warn "Plugins will auto-install on first Neovim startup with Lazy.nvim:"
```

### 4. Header Documentation
- Updated feature list to mention "Lazy.nvim plugin manager with auto-installation"
- Reflects the modern, automated approach of Lazy.nvim

## Key Improvements

1. **Automatic Installation**: No manual `:PackerInstall` required
2. **Better Performance**: Uses `--filter=blob:none` for faster cloning
3. **Stable Branch**: Ensures stable Lazy.nvim version
4. **Cleaner Paths**: Uses Lazy.nvim's standard directory structure

## Installation Process

1. **Run the script**: `sh nvim/install.sh`
2. **Start Neovim**: Plugins auto-install on first launch
3. **Verify setup**: Use `:Lazy` to check plugin status

The script now fully supports Lazy.nvim while maintaining all existing functionality for language servers, formatters, and system dependencies.