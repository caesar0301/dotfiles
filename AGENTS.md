# AGENTS.md

Guidance for working in this personal dotfiles repo (`cool-dotfiles`): Zsh, Neovim, Tmux, Emacs, Zellij, etc., installed via scripts that follow the XDG Base Directory spec.

## Quick Reference

```bash
./install_basics.sh                # zsh, tmux, zellij, nvim
./install_all.sh                   # all components
./install_all.sh -m zsh,tmux,nvim  # selective
./misc/install.sh -m kitty,alacritty
./format.sh                        # shfmt (shell) + stylua (nvim/ Lua)
```

Install flags: `-s` symlink (default) · `-f` copy · `-c` clean/remove · `-m` select modules.

## Setup

Bootstrap a machine (order matters — essentials set up Homebrew/pyenv/cargo that the rest depend on):

```bash
./install_basics.sh                                            # zsh, tmux, zellij, nvim
INSTALL_EXTRA_VENV=1 INSTALL_AI_AGENTS=1 ./install_all.sh       # everything, incl. jenv/gvm/nvm/rbenv
exec $SHELL                                                    # reload PATH: ~/.local/bin, brew, pyenv, cargo
```

Re-run a single component any time: `./nvim/install.sh -s`.

Then finish Neovim, since plugins only bootstrap on first launch:

```bash
nvim                                                           # Lazy.nvim installs plugins + treesitter parsers
:checkhealth                                                   # review; :Lazy health for plugin status
```

Non-interactive capture (useful for agents/CI):

```bash
nvim --headless -c 'set nomore' -c 'checkhealth' -c 'w! /tmp/checkhealth.txt' -c 'qa!'
```

Work the report top to bottom; fix every missing tool, then re-run `:checkhealth` until clean. Mapping of report item → fix:

| checkhealth item | Fix |
| --- | --- |
| `lazy`: git missing | `./lib/install-homebrew.sh` then `brew install git` (macOS: Xcode CLT) |
| `nvim-treesitter`: tree-sitter CLI missing | `./lib/install-tree-sitter.sh` (brew → cargo → npm) |
| `nvim-treesitter`: tar/curl missing | `brew install tar curl` (macOS: Xcode CLT) |
| `nvim-treesitter`: parser missing or ABI mismatch | `:TSUpdate`; parser list lives at `nvim/lua/plugins/nvim-treesitter.lua:15`; `:TSInstallFromGrammar` additionally needs a C compiler |
| `vim.health`: ripgrep missing | `brew install ripgrep` (needed by telescope and fzf-lua live grep) |
| `vim.provider`: Node.js host | `npm install -g neovim` (done by `nvim/install.sh:76`) |
| `vim.provider`: Python 3 host / pynvim | `./lib/install-nvim-python.sh` (pyenv virtualenv `neovim` + pynvim); override with `export NVIM_PYTHON3=$PYENV_ROOT/versions/neovim` |
| `vim.provider`: clipboard tool | macOS `pbcopy`; Linux `brew install xclip` |
| `vim.provider`: perl / ruby providers | Intentionally disabled (`nvim/lua/preference.lua:169`) — do not install |
| `vim.lsp`: server not found | `./lib/install-lsp.sh` (pyright, gopls, cmake-language-server, gotags, R `languageserver`); Java needs `INSTALL_JDTLS=1 ./lib/install-lsp.sh`; server list at `nvim/lua/plugins/nvim-lspconfig.lua:83`, others (clangd, rust_analyzer, metals, clojure_lsp) via brew |
| `conform.nvim`: formatter unavailable | `./lib/install-lang-formatters.sh`; filetype→formatter map at `nvim/lua/plugins/conform.lua:19`; shell-only: `./lib/install-shfmt.sh` |
| `tagbar`: ctags missing | `./lib/install-universal-ctags.sh` (must be universal-ctags, not BSD/GNU ctags) |
| fzf / fzf-lua binary | `./lib/install-fzf.sh` |
| icons render as tofu | `./lib/install-hack-nerd-font.sh`, then select Hack Nerd Font in the terminal |
| `LuaSnip` / `telescope-fzf-native` build failure | Needs `make` + C compiler: Xcode CLT (macOS) or `brew install gcc make` |
| R support (Nvim-R) | R runtime + `./lib/install-lsp.sh` |
| Common Lisp (vlime) | `./lisp/install.sh` (SBCL + Quicklisp); vlime drives the server through Roswell `ros` (`nvim/lua/plugins/vlime.lua:14`), so install Roswell separately or set `vim.g.vlime_cl_impl` to `sbcl` |
| LaTeX (vimtex) | `latexmk` + viewer (Skim on macOS, zathura on Linux) |

The "Nvim x.y.z is available" warning under `vim.health` is informational; upgrade with `./lib/install-neovim.sh` or `brew upgrade neovim` if wanted.

## Architecture

- `install_all.sh` / `install_basics.sh` → orchestrators; both run `lib/install-essentials.sh` first (bin/ scripts, pyenv, fzf, universal-ctags, cargo, Homebrew).
- Optional prerequisites via env: `INSTALL_EXTRA_VENV=1` (jenv, gvm, nvm, rbenv), `INSTALL_AI_AGENTS=1` (requires npm >= 20). `install_all.sh` enables the version managers; `install_basics.sh` does not.
- Modules (`zsh/ nvim/ tmux/ zellij/ emacs/ vifm/ misc/ lisp/ alacritty/`) each have an `install.sh` registered in the orchestrator's `COMPONENTS` array.
- `lib/` holds `shlib.sh` (logging, path/os helpers) plus one installer per tool; all are independently runnable. Use `ls lib/` rather than trusting a list here.
- `bin/` → `dotme-*` tools installed to `~/.local/bin` (added to PATH by `zsh/init.zsh`). See `bin/README.md`.

## Conventions

Every install script: `set -euo pipefail`, sources `lib/shlib.sh`, resolves XDG vars with fallbacks, supports the standard flags, logs via `info/warn/error/success`.

```bash
THISDIR=$(dirname "$(realpath "$0")")
source "$THISDIR/../lib/shlib.sh" || { printf "✗ Failed to load shlib.sh\n" >&2; exit 1; }
readonly XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
readonly XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
install_file_pair "$source_file" "$dest_file"
```

- XDG defaults: data `~/.local/share`, config `~/.config`, cache `~/.cache`. No `~/.tmux.conf` symlink.
- OS branching via `is_linux` / `is_macos` from shlib.sh.
- New module: add dir + `install.sh`, then add to `COMPONENTS`.

## Testing Changes

1. Test the module installer standalone, then via the orchestrator.
2. Verify both `-s` and `-f` modes; verify `-c` removes and backs up as expected.
3. Check exit codes and error handling.

Tmux Unicode display: see `docs/tmux-unicode-fix.md`.

## AI Agent Config Syncing

The AI agent configs (`grok`, `codex`, `opencode`) are kept in sync against a single source of truth: the `dashscope` provider block in `lib/claude-code-router.json`. When the router's model list changes, all three agent configs must be updated to match.

### Source of truth

- **File:** `lib/claude-code-router.json` → `Providers[name="dashscope"].models`
- **Chat-usable models:** `glm-5.2`, `qwen3.7-plus`, `qwen3.6-flash`, `kimi-k2.5`, `MiniMax-M3`
- **Excluded:** `text-embedding-v4` (embedding model — never synced into chat agents)
- **Default model:** `glm-5.2` (matches `Router.default = "dashscope,glm-5.2"`)

### Synced files

| File | Format | Provider key style | Default |
| --- | --- | --- | --- |
| `lib/grok-config.toml` | TOML | `[model."<id>"]` tables, `api_backend = "chat_completions"` | `glm-5.2` |
| `lib/codex-config.toml` | TOML | `[model_providers.dashscope-*]` tables, `wire_api = "responses"` | `glm-5.2` (`model_provider = "dashscope-glm"`) |
| `opencode/opencode.json` | JSON | `provider.dashscope.models.<id>` entries | `dashscope/glm-5.2` |

### Syncing rules

1. **Single source:** `lib/claude-code-router.json` is the only source of truth. Never edit agent configs independently of it — if a model is added/removed there, propagate to all three.
2. **Chat models only:** Sync only the chat-usable models from the `dashscope` provider. Skip any non-chat entries (e.g. `text-embedding-v4`).
3. **Preserve defaults:** `glm-5.2` is the default in all three configs (matching the router's `Router.default`). Each agent's `small_model`/secondary selection may differ (e.g. opencode uses `kimi-k2.5`) — keep it stable unless the underlying model is removed.
4. **Keep metadata consistent:** `name`, `description`, `base_url`/`baseURL`, and `env_key` must use `${DASHSCOPE_BASE_URL}` / `{env:DASHSCOPE_BASE_URL}` and `DASHSCOPE_API_KEY` across all three, matching the router's `api_base_url`/`api_key` placeholders.
5. **Validate after editing:** Re-parse every changed file (TOML + JSON) to confirm it's well-formed before committing. A broken config silently breaks the agent at launch.
6. **Installer note:** `lib/install-ai-agent-codex.sh` substitutes `${DASHSCOPE_BASE_URL}` into the codex template at install time (Codex doesn't interpolate it at runtime). Keep the placeholder in the template; don't hardcode the URL.
7. **Comment cross-references:** Each agent config carries a header comment pointing back to `lib/claude-code-router.json` as the source — keep these comments accurate when models change.

## `setups/` (infrastructure, not dotfiles)

- `mihomo/` — Docker proxy for macOS: `cd setups/mihomo && ./start.sh -c ~/.config/mihomo`; ports 7890 (proxy) / 9090 (API); console at metacubexd. Still needs macOS system proxy config.
- `clash/` — systemd/Linux Mihomo; fetches remote config (`V2SS_LINK`, `TROJANFLARE_CLASHX_URL`).
- `systemd/` — system units (`mihomo.service`, `minikube.service` → `/etc/systemd/system/`); user units (`colima.service`, `aliyunpan-sync.service` → `~/.config/systemd/user/`).
- `alithia/` notes, `openclaw/` alt proxy.
