# Neovim Keymaps Reference

This document lists all custom keymaps and frequently used plugin shortcuts configured in this Neovim setup.

## Table of Contents

1. [Core Editing](#core-editing)
2. [View, Window & Tabs](#view-window--tabs)
3. [Search & Replace](#search--replace)
4. [File Navigation](#file-navigation)
5. [Buffer Management](#buffer-management)
6. [LSP (Language Server Protocol)](#lsp-language-server-protocol)
7. [Git Integration](#git-integration)
8. [Terminal](#terminal)
9. [Code Completion](#code-completion)
10. [Code Formatting](#code-formatting)
11. [Miscellaneous](#miscellaneous)
12. [Plugin-Specific Keymaps](#plugin-specific-keymaps)

---

## Core Editing

| Key | Mode | Description |
|-----|------|-------------|
| `<C-s>` | n/i/v | Save current buffer |
| `W` | Command | Save all buffers (user command) |
| `Q` | Command | Quit all buffers (user command) |
| `Wq` | Command | Save all and quit current (user command) |
| `WQ` | Command | Save and quit all (user command) |
| `<leader>W` | n/v | Save all buffers |
| `<leader>Q` | n/v | Quit all buffers |
| `0` | all | Go to first non-blank character (remapped from `^`) |
| `<C-a>` | n/i | Go to line head |
| `<C-e>` | n/i | Go to line tail |
| `J` | v | Move selected lines down |
| `K` | v | Move selected lines up |
| `dd` | n | Delete line (doesn't yank empty lines) |
| `<C-BS>` | i/c | Delete word back |
| `<leader>ss` | all | Toggle spell checking |

---

## View, Window & Tabs

| Key | Mode | Description |
|-----|------|-------------|
| `<C-h>` | all | Move to left window |
| `<C-j>` | all | Move to lower window |
| `<C-k>` | all | Move to upper window |
| `<C-l>` | all | Move to right window |
| `<leader>cd` | all | Change working directory to current buffer's directory |

### Command-line Mode Shortcuts

| Key | Mode | Description |
|-----|------|-------------|
| `$h` | c | Edit from home directory |
| `$c` | c | Edit from current file directory |
| `$q` | c | Delete till last slash in command line |
| `<C-A>` | c | Go to start of line |
| `<C-E>` | c | Go to end of line |
| `<C-K>` | c | Delete to start of line |
| `<C-P>` | c | Previous command |
| `<C-N>` | c | Next command |
| `½` | n/i/c | Map to `$` (useful on some keyboards) |

---

## Search & Replace

| Key | Mode | Description |
|-----|------|-------------|
| `<space>` | n | Search forward (remapped to `/`) |
| `<C-space>` | n | Search backward (remapped to `?`) |
| `*` | v | Search forward for visual selection |
| `#` | v | Search backward for visual selection |
| `<leader>rw` | n/v | Replace current word (case sensitive) |
| `<leader>R` | n/v | Replace current word (alias) |
| `<leader>fr` | n | Find and replace using quickfix |
| `<Esc>` | n/i | Clear search highlights, messages, floating windows |

---

## File Navigation

### Telescope (Fuzzy Finder)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>tf` | n | Find files (Telescope) |
| `<leader>tg` | n | Live grep (Telescope) |
| `<leader>tb` | n | Find buffers (Telescope) |
| `<leader>th` | n | Help tags (Telescope) |
| `<leader>ff` | n | Find files |
| `<leader>fw` | n | Find current word |
| `<leader>fg` | n | Search everywhere |
| `<leader>fd` | n | Search in directory |

### Nvim-Tree (File Explorer)

| Key | Mode | Description |
|-----|------|-------------|
| `<F8>` | n | Toggle nvim-tree and find current file |
| `<leader>N` | n | Toggle nvim-tree and find current file |
| `<leader>nn` | n | Toggle nvim-tree and find current file |

---

## Buffer Management (Barbar)

| Key | Mode | Description |
|-----|------|-------------|
| `<A-,>` | n | Previous buffer |
| `<A-.>` | n | Next buffer |
| `<A-c>` | n | Close current buffer |
| `<A-C>` | n | Close all but current buffer |
| `<A-r>` | n | Restore last closed buffer |
| `<C-p>` | n | Magic buffer picker |
| `<Space>bb` | n | Order buffers by number |
| `<Space>bn` | n | Order buffers by name |
| `<Space>bd` | n | Order buffers by directory |
| `<Space>bl` | n | Order buffers by language |
| `<Space>bw` | n | Order buffers by window number |

---

## LSP (Language Server Protocol)

| Key | Mode | Description |
|-----|------|-------------|
| `gD` | n | Go to declaration |
| `gd` | n | Go to definition |
| `gpd` | n | Preview definition (in popup) |
| `gi` | n | Go to implementation |
| `gpi` | n | Preview implementation (in popup) |
| `gt` | n | Go to type definition |
| `gpt` | n | Preview type definition (in popup) |
| `gr` | n | Go to references |
| `gpr` | n | Preview references (in popup) |
| `gP` | n | Close all preview windows |
| `gs` | n | Show signature help |
| `K` | n | Show hover documentation |
| `rn` | n | Rename symbol |
| `ca` | n | Show code actions |
| `<leader>lf` | n | Format code |
| `<leader>ai` | n | Show incoming calls |
| `<leader>ao` | n | Show outgoing calls |
| `<leader>gw` | n | Document symbols |
| `<leader>gW` | n | Workspace symbols |
| `<leader>gl` | n | List workspace folders |
| `<leader>eq` | n | Diagnostic setloclist |
| `<leader>ee` | n | Diagnostic open float |
| `[d` | n | Go to previous diagnostic |
| `]d` | n | Go to next diagnostic |

### Clangd (C/C++) Specific

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>sh` | n | Switch between source and header |

---

## Git Integration (Gitsigns)

### Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `]c` | n | Go to next hunk |
| `[c` | n | Go to previous hunk |

### Hunk Actions

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>hs` | n/v | Stage hunk |
| `<leader>hr` | n/v | Reset hunk |
| `<leader>hS` | n | Stage buffer |
| `<leader>hu` | n | Undo stage hunk |
| `<leader>hR` | n | Reset buffer |
| `<leader>hp` | n | Preview hunk |
| `<leader>hb` | n | Blame line (full) |
| `<leader>tb` | n | Toggle current line blame |
| `<leader>hd` | n | Diff this |
| `<leader>hD` | n | Diff this against HEAD |
| `<leader>td` | n | Toggle deleted |

### Text Object

| Key | Mode | Description |
|-----|------|-------------|
| `ih` | o/x | Inner hunk text object |

---

## Terminal (Toggleterm)

| Key | Mode | Description |
|-----|------|-------------|
| `<C-\>` | - | Toggle terminal |
| `<leader>T` | n | Toggle terminal |

### Terminal Mode Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `<Esc>` | t | Exit terminal mode |
| `jk` | t | Exit terminal mode |
| `<C-h>` | t | Move to left window |
| `<C-j>` | t | Move to lower window |
| `<C-k>` | t | Move to upper window |
| `<C-l>` | t | Move to right window |
| `<C-w>` | t | Window operations |

---

## Code Completion (nvim-cmp)

### Insert Mode

| Key | Mode | Description |
|-----|------|-------------|
| `<Tab>` | i/s | Confirm completion or jump to next snippet |
| `<S-Tab>` | i/s | Select previous item or jump to previous snippet |
| `<C-k>` | i | Select previous item |
| `<C-j>` | i | Select next item |
| `<C-d>` | i | Scroll documentation up |
| `<C-u>` | i | Scroll documentation down |
| `<C-Space>` | i/c | Trigger completion |
| `<C-e>` | i/c | Abort completion |
| `<CR>` | i | Confirm completion |

### Command-line Mode

| Key | Mode | Description |
|-----|------|-------------|
| `<Tab>` | c | Confirm completion |
| `<S-Tab>` | c | Select previous item |
| `<C-k>` | c | Select previous item |
| `<C-j>` | c | Select next item |

---

## Code Formatting

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>af` | n | Format code (Conform) |

### Commands

| Command | Description |
|---------|-------------|
| `:Format` | Format code (supports range) |
| `:FormatWrite` | Format code and write buffer |

---

## Miscellaneous

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ts` | n/i | Insert timestamp (ISO 8601) |
| `<F5>` | n/i/v | Compile and run (custom function) |
| `<leader>gi` | n | Generate .gitignore file |

---

## Plugin-Specific Keymaps

### Tagbar (Code Outline)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>tt` | n | Toggle tagbar |
| `<F9>` | n | Toggle tagbar |

### AI Assistant (CodeCompanion)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ai` | n | Open AI chat |
| `<leader>aa` | n | Open AI actions menu |

### Telescope Internal Mappings

#### Insert Mode

| Key | Description |
|-----|-------------|
| `<Esc>` | Close telescope |
| `<C-n>` | Cycle history next |
| `<C-p>` | Cycle history previous |
| `<C-j>` | Move selection next |
| `<C-k>` | Move selection previous |
| `<C-c>` | Close telescope |

#### Normal Mode

| Key | Description |
|-----|-------------|
| `<Esc>` | Close telescope |
| `j` | Move selection next |
| `k` | Move selection previous |
| `<CR>` | Select default |

---

## Tips

1. **Leader Key**: The default leader key is `<Space>`. Most custom mappings use this prefix.
2. **Mode Abbreviations**:
   - `n` = Normal mode
   - `i` = Insert mode
   - `v` = Visual mode
   - `c` = Command-line mode
   - `t` = Terminal mode
   - `o` = Operator-pending mode
   - `x` = Visual block mode
3. **Key Notation**:
   - `<C-x>` = Ctrl+x
   - `<A-x>` = Alt+x (Option+x on macOS)
   - `<S-x>` = Shift+x
   - `<leader>` = Space (default)
4. For more information about default Vim keymaps, run `:help keymap` in Neovim.
