# CLAUDE.md

This file provides guidance to Claude Code when working with this dotfiles repository.

**Quick summary:** Cross-platform dotfiles repository for UNIX-based systems managed with GNU Stow, using git smudge/clean filters for username-agnostic portability.

## Repository Structure

```
.dotfiles/
├── .zsh/                  # Modular zsh configuration
│   ├── aliases.zsh
│   ├── completions.zsh
│   ├── git-functions.zsh
│   ├── integrations.zsh
│   ├── widgets.zsh
│   └── completions/       # Custom completion files
├── .config/               # Configuration files
│   ├── nvim/              # Neovim (Kickstart.nvim-based)
│   ├── tmux/              # Tmux config
│   ├── starship.toml
│   └── [other app configs]
├── scripts/               # Automation and setup
│   ├── setup.sh           # Main installation script
│   ├── smudge.sh / clean.sh  # Git filter scripts
│   ├── verify_filters.sh
│   ├── health.sh
│   ├── atomic-commits.sh
│   ├── generate-commit-message.sh
│   └── [other utilities]
├── .zshenv                # Environment variables and PATH
├── .zprofile              # Login shell setup
├── .zshrc                 # Interactive shell configuration
├── .gitconfig.dotfiles    # Git configuration
├── .gitattributes         # Git filter configuration
└── .stow-local-ignore     # Files excluded from symlinking
```

## Essential Commands

**Quick reference (full details in `.claude/rules/`):**
```bash
restow              # Sync dotfiles, commit atomically, push
gcr                 # Commit with atomic commits (any repo)
grel                # Create semantic GitHub release
pre-commit run --all-files  # Run all validation
./scripts/verify_filters.sh # Check git filters
```

## Key Architectural Principles

1. **Modular zsh configuration:** Separate concerns into `.zsh/*.zsh` files
   - `.zshenv` - Environment and PATH (fast, always sourced)
   - `.zprofile` - Login initialization
   - `.zshrc` - Interactive shell (sources modular files)

2. **Git smudge/clean filters:** Keep configs portable across machines
   - Files affected: `.zshrc`, `.zshenv`, `.zprofile`, `.config/hatch/config.toml`
   - Placeholders: `%%HOME%%`, `%%GIT_NAME%%`, `%%GIT_EMAIL%%`

3. **XDG Base Directory compliance:** Use `$XDG_CONFIG_HOME`, `$XDG_CACHE_HOME`, etc.

4. **GNU Stow:** Create symlinks with `--no-folding` flag

5. **Atomic commits:** Functions auto-analyze changes and create semantic commits

## Related Documentation

Load these files when working on specific areas:

- **Shell configuration** → `.claude/rules/shell-config.md`
- **Git workflow** → `.claude/rules/git-workflow.md`
- **Scripts and automation** → `.claude/rules/scripts.md`
- **Development workflow** → `.claude/rules/development.md`

## Critical Notes for Claude Code

- Verify git filters after changes: `./scripts/verify_filters.sh`
- Respect modular architecture (new functionality in appropriate `.zsh/*.zsh` file)
- Always use `--no-folding` with stow
- Pre-commit hooks are strict—they catch most issues
- Work with actual values locally; git filters handle placeholders on commit
