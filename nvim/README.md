# Nvim Dotfiles

![IDE Screenshot](https://github.com/caesar0301/cool-dotfiles/blob/721440cf68751aabaa72da106a8f6770d8281964/assets/screenshot.png)

> **Modern, batteries-included Neovim configuration for an IDE-like experience.**

---

## Prerequisites

- **Neovim** v0.9+
  (For best remote copy/paste support, use v0.10.0+)
- **Python** 3.7.10+

## Installation

1. **Clone the repository:**
   ```bash
   git clone --depth=1 https://github.com/caesar0301/cool-dotfiles.git ~/.dotfiles
   ```
2. **Install Neovim configurations:**
   ```bash
   sh nvim/install.sh
   ```
   - By default, creates symlinks for easy updates.
   - Use `-f` to copy files instead of symlinking.
   - **Note:** Sudo may be required to install dependencies for plugins.

**Configuration structure:**

| Path                                 | Purpose                        |
|--------------------------------------|--------------------------------|
| `~/.config/nvim`                     | Nvim runtime directory         |
| `~/.config/nvim/lua/plugins/`        | Modular plugin configurations  |
| `~/.config/nvim/plugin/`             | Plugin setup scripts           |
| `~/.config/nvim/after/plugin`        | User plugin preferences        |

## Post-installation

- Some linter/formatter tools are installed via `install.sh`.
- Others must be installed manually. For example:
  ```bash
  brew install bufbuild/buf/buf  # for proto files
  ```

### Optional Environment Variables

| Variable             | Description                                 | Default                                      |
|----------------------|---------------------------------------------|----------------------------------------------|
| `JAVA_HOME_4JDTLS`   | Java executable for jdt-language-server     | Uses `JAVA_HOME`                             |
| `JDTLS_HOME`         | Install location for jdt-language-server    | `~/.local/share/jdt-language-server`         |
| `JAVA_HOME_4GJF`     | Java executable for google-java-formatter   | Uses `JAVA_HOME`                             |
| `GJF_JAR_FILE`       | Jar path for google-java-formatter          | `~/.local/share/google-java-format/google-java-format-all-deps.jar` |

**Example:**
```bash
# Install with JDTLS
INSTALL_JDTLS=1 sh nvim/install.sh

# Or set in your environment
export INSTALL_JDTLS=1
sh nvim/install.sh
```

## Features

- **LSP Management:** `nvim-lspconfig`
- **Auto-completion:** `nvim-cmp`, `nvim-treesitter`
- **Code Formatting:** `conform.nvim`
- **File Explorer/Tabline:** `nvim-tree`, `barbar.nvim`
- **Code Structure:** `tagbar` (requires `universal-ctags`/`gotags`)
- **Fuzzy Finder:** `nvim-telescope`
- **Git Integration:** `vim-gitgutter`

---

## Troubleshooting

- If plugins fail to install, ensure you have the required system dependencies.
- For language servers, check that environment variables are set correctly.

## Updating

To update your dotfiles and plugins:
```bash
git pull origin main
sh nvim/install.sh
```

## Contributing

Pull requests and issues are welcome!

---

**Enjoy your enhanced Neovim experience!**
