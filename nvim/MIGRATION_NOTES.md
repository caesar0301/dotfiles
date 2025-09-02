# Migration from Packer to Lazy.nvim

## What Changed

- **Plugin Manager**: Migrated from Packer.nvim to Lazy.nvim
- **Configuration File**: `lua/packer-config.lua` → `lua/lazy-config.lua`
- **Installation**: Plugins now auto-install on first startup (no need for `:PackerInstall`)

## Key Differences

### Packer → Lazy.nvim Syntax Changes

| Packer | Lazy.nvim | Purpose |
|--------|-----------|---------|
| `requires` | `dependencies` | Plugin dependencies |
| `run` | `build` | Build commands |
| `tag` | `version` | Version pinning |
| `rtp` | `init` function | Runtime path modification |

### Preserved Features

✅ **All plugins preserved**: Every plugin from your Packer config is included  
✅ **Conditional loading**: Rust plugin still conditionally loads based on `SUPPORTS_MODERN_PLUGINS`  
✅ **Plugin configurations**: All `config` functions and settings preserved  
✅ **Dependencies**: All plugin dependencies properly converted  
✅ **Version pinning**: Tagged versions maintained where specified  

### New Benefits

- **Faster startup**: Lazy loading by default
- **Better UI**: Modern plugin management interface
- **Auto-installation**: No manual `:PackerInstall` needed
- **Health checks**: Built-in plugin health monitoring
- **Performance**: Optimized plugin loading

## Commands

| Old Packer Command | New Lazy Command | Purpose |
|-------------------|------------------|---------|
| `:PackerInstall` | `:Lazy install` | Install plugins |
| `:PackerUpdate` | `:Lazy update` | Update plugins |
| `:PackerSync` | `:Lazy sync` | Sync plugins |
| `:PackerClean` | `:Lazy clean` | Remove unused plugins |
| `:PackerStatus` | `:Lazy` | Show plugin status |

## First Startup

On your first Neovim startup after migration:
1. Lazy.nvim will automatically install itself
2. All plugins will be installed automatically
3. You may see some download progress indicators
4. Once complete, restart Neovim for full functionality

## Rollback (if needed)

If you need to rollback to Packer:
```bash
rm -rf ~/.config/nvim
cp -r ~/.dotfiles/nvim_packer_backup ~/.config/nvim
```