# Skills Directory

Custom Claude Code skills for managing your development environment.

## Available Skills

### use-my-computer

Manage dotfiles, troubleshoot environment issues, configure development tools, and handle system-level setups.

**Features:**
- XDG Base Directory compliance
- Cross-platform support (macOS & Linux)
- Interactive confirmation for system changes
- Bundled diagnostic scripts

**Installation:**
```bash
npx skills add use-my-computer --from ~/.dotfiles/skills/use-my-computer
```

**Alternative installation:**
```bash
npx skills add use-my-computer --from https://github.com/caesar0301/dotfiles/tree/main/skills/use-my-computer
```

## Using with Claude Code Marketplace

This directory is configured for Claude Code's marketplace system via `.claude/marketplace.json`.

**To add all skills from this repository:**
```bash
npx skills add --marketplace ~/.dotfiles/.claude/marketplace.json
```

**To list available skills:**
```bash
npx skills list --marketplace ~/.dotfiles/.claude/marketplace.json
```

## Skill Structure

Each skill follows this pattern:
```
skill-name/
├── SKILL.md          # Skill instructions and frontmatter
└── scripts/          # Bundled helper scripts (optional)
    ├── script1.sh
    └── script2.sh
```

## Contributing

When adding new skills:
1. Create skill directory under `skills/`
2. Write `SKILL.md` with proper frontmatter (name, description)
3. Add bundled scripts in `scripts/` subdirectory if needed
4. Update `.claude/marketplace.json` with skill metadata
5. Update this README.md

## Documentation

For detailed skill documentation, see:
- [use-my-computer/SKILL.md](use-my-computer/SKILL.md) - Full skill instructions
- [use-my-computer/scripts/](use-my-computer/scripts/) - Bundled diagnostic tools

## License

MIT License - See repository root for details.