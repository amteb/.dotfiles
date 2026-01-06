# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Cross-platform dotfiles repository for UNIX-based systems (macOS, Linux, WSL) managed with GNU Stow. The repository uses a username-agnostic approach with git smudge/clean filters to maintain portability across different machines.

## Key Commands

### Development & Testing
```bash
# Run all validation tests
./scripts/verify_filters.sh          # Verify git filters are working
pre-commit run --all-files           # Run all pre-commit hooks
stow --simulate --no-folding .       # Test stow without making changes

# Health check
./scripts/health.sh                  # Check dotfiles health status
```

### Deployment
```bash
# Initial setup on new machine
./scripts/setup.sh                   # Install dependencies and configure system

# Stow dotfiles (create symlinks)
stow --no-folding .                  # From ~/.dotfiles directory

# Re-stow after changes
restow                               # Zsh function that stows and syncs to git
```

### Common Workflows
```bash
# Install tool and auto-add to setup.sh
sto brew install <package>           # Zsh function defined in git-functions.zsh

# Git workflow shortcuts
gcr                                  # Git commit remain (commit but don't push)
gcr -s                               # Use single commit instead of atomic commits
gas ~/path/to/repo                   # Auto-sync a git repository
grel                                 # Create semantic version release on GitHub
grel -s                              # Create release with single commit

# Manual git operations
git add .
git commit -m "chore: update dotfiles"
git push

# Tmux session management
tmux-sessionizer                     # Fuzzy find and create/switch sessions (Ctrl+F)
```

## Architecture

### File Organization

**Root Level:**
- `.zshenv` - Environment variables, PATH, XDG dirs (sourced for ALL zsh invocations)
- `.zprofile` - Login shell setup (Homebrew, SSH agent, cargo)
- `.zshrc` - Interactive shell entry point that sources modular configs
- `.gitconfig.dotfiles` - Git configuration (included via `~/.gitconfig`)
- `.stow-local-ignore` - Files excluded from stowing (README, scripts, etc.)

**Zsh Modular Configuration (`.zsh/`):**
- `completions.zsh` - Completion system configuration
- `aliases.zsh` - All shell aliases and alias-like functions
- `git-functions.zsh` - Git workflow functions (restow, gcr, grel, gas, sto)
- `integrations.zsh` - Third-party tool initializations (starship, zoxide, atuin, jj)
- `widgets.zsh` - ZLE widgets and keybindings
- `completions/` - Custom completion files for zsh functions

**Configuration (`.config/`):**
- `nvim/` - Neovim config based on Kickstart.nvim with custom modules in `lua/custom/`
- `tmux/` - Tmux config with modular components and themes
- `starship.toml` - Cross-shell prompt configuration
- Application configs: alacritty, atuin, ghostty, lazygit, posting, etc.

**Scripts (`scripts/`):**
- `setup.sh` - Main installation script for new systems
- `smudge.sh` / `clean.sh` - Git filters for username-agnostic configs
- `setup_smudge_clean.sh` - Configure git smudge/clean filters
- `verify_filters.sh` - Verify filter functionality
- `health.sh` - System health check
- `tmux-sessionizer` - Fuzzy finder for tmux sessions
- `git-autosync.sh` - Auto-sync git repositories
- `atomic-commits.sh` - Analyze changes and create semantic atomic commits
- `generate-commit-message.sh` - Generate conventional commit messages
- `calculate-next-version.sh` - Calculate next semantic version from commits
- `hooks/` - Custom pre-commit hook scripts

### Git Smudge/Clean Filter System

**Critical:** This repository uses git filters to keep configs portable across systems.

**How it works:**
- **Clean filter** (on commit): Replaces personal values with placeholders
  - `$HOME` → `%%HOME%%`
  - Git name → `%%GIT_NAME%%`
  - Git email → `%%GIT_EMAIL%%`
- **Smudge filter** (on checkout): Replaces placeholders with local values

**Files affected:** Configured in `.gitattributes` with `filter=substitution`
- `.zshrc`, `.zshenv`, `.zprofile`
- `.config/hatch/config.toml`

**Important:** When editing these files, work with actual values in your working directory. Git will automatically convert them when committing.

### Shell Configuration Architecture

The zsh config follows a three-file pattern:

1. **`.zshenv`** (always sourced first)
   - Sets up XDG Base Directory variables
   - Configures PATH using typeset array
   - Defines environment variables
   - Must be fast (sourced by all zsh instances)

2. **`.zprofile`** (login shells only)
   - Initializes Homebrew
   - Sets up SSH agent with keychain
   - Loads cargo, opam environments
   - One-time login tasks

3. **`.zshrc`** (interactive shells)
   - History configuration and zsh options
   - Keybindings (emacs mode, edit-command-line)
   - Sources modular configuration files from `.zsh/`:
     - `completions.zsh` - Completion system setup
     - `git-functions.zsh` - Git workflow automation functions
     - `aliases.zsh` - Shell aliases and wrappers
     - `widgets.zsh` - ZLE widgets (tmux-sessionizer)
     - `integrations.zsh` - Third-party tool initializations
   - Named directory shortcuts (~dot, ~dev, ~downloads)
   - Sources `.zshrc.local` if it exists (for machine-specific config)

### Neovim Configuration

Based on Kickstart.nvim pattern:
- `init.lua` - Entry point that requires `custom` module
- `lua/custom/` - Custom configuration modules
- `lua/kickstart/` - Kickstart base modules
- Plugin management via lazy.nvim
- Formatted with StyLua (config in `.config/nvim/.stylua.toml`)

### Tmux Configuration

Modular structure:
- `tmux.conf` - Main config that sources components
- `themes/` - Color schemes (monokai-pro-machine)
- `components/` - Modular config pieces (minimalist statusline)
- `plugins/` - TPM plugins (tmux-sensible, vim-tmux-navigator)
- Plugin manager: TPM (Tmux Plugin Manager)

### Pre-commit Hooks

Extensive hook configuration in `.pre-commit-config.yaml`:

**Standard checks:**
- File quality (trailing whitespace, line endings)
- Syntax validation (YAML, TOML, JSON)
- Permission checks (shebangs, executables)

**Security:**
- gitleaks (scan for secrets)
- detect-private-key (find SSH/GPG keys)
- Custom: verify-no-personal-info (check for personal data leakage)
- Custom: verify-git-filters-configured (ensure filters are set up)

**Code quality:**
- shellcheck (lint shell scripts, excludes zsh configs)
- bashate (shell script style)
- stylua (format Lua/Neovim configs)
- yamllint (lint YAML)

**Custom checks:**
- check-shell-scripts-executable (verify scripts are executable)
- check-common-mistakes (detect bash in zsh, PATH overwrites)

Configuration files: `.shellcheckrc`, `.yamllint`, `.pre-commit-config.yaml`

## Important Patterns

### PATH Management
Use array addition instead of string concatenation:
```zsh
# Good
path+=("/new/path")

# Bad
PATH="$PATH:/new/path"
```

### XDG Compliance
Always use XDG variables for config locations:
```zsh
$XDG_CONFIG_HOME  # ~/.config
$XDG_CACHE_HOME   # ~/.cache
$XDG_DATA_HOME    # ~/.local/share
$XDG_STATE_HOME   # ~/.local/state
```

### Conditional PATH Additions
Use the `_add_to_path()` function in `.zshenv` to only add directories that exist:
```zsh
_add_to_path "$HOME/optional/bin" "/another/optional/path"
```

### Named Directories
Defined in `.zshrc` for quick navigation:
```zsh
~dot        # $HOME/.dotfiles
~dev        # $HOME/Dev
~downloads  # $HOME/Downloads
```

### Modular Zsh Configuration
The zsh config uses a modular architecture for maintainability:
```zsh
# In .zshrc
source ~/.dotfiles/.zsh/git-functions.zsh  # Git workflow automation
source ~/.dotfiles/.zsh/aliases.zsh        # Aliases and wrappers
source ~/.dotfiles/.zsh/widgets.zsh        # ZLE widgets
source ~/.dotfiles/.zsh/integrations.zsh   # Tool initializations
```

When adding new functionality:
- **Aliases/wrappers** → `.zsh/aliases.zsh`
- **Git functions** → `.zsh/git-functions.zsh`
- **ZLE widgets** → `.zsh/widgets.zsh`
- **Tool integrations** → `.zsh/integrations.zsh`
- **Completions** → `.zsh/completions/_functionname`

### Stow Best Practices
- Always use `--no-folding` flag to prevent symlink folders
- Use `--simulate` to test before applying
- Files in `.stow-local-ignore` won't be symlinked (README, scripts, etc.)

## Security Considerations

1. **Never commit unfiltered personal information**
   - Always run `./scripts/verify_filters.sh` before committing
   - Pre-commit hooks will catch most issues

2. **Files that need git filters**
   - Add to `.gitattributes` with `filter=substitution`
   - Use placeholders: `%%HOME%%`, `%%GIT_NAME%%`, `%%GIT_EMAIL%%`

3. **Secrets management**
   - Never commit API keys, tokens, credentials
   - Use `.zshrc.local` (gitignored) for machine-specific secrets
   - Gitleaks hook will scan for common patterns

4. **SSH/GPG keys**
   - Managed outside this repo
   - SSH agent configured in `.zprofile`
   - Keychain used for persistent agent management

## Cross-Platform Support

The repository supports macOS, Linux (Debian/Ubuntu), and WSL:

**OS Detection:**
```zsh
# In scripts and config files
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
fi
```

**Platform-specific package handling:**
- Configured in `scripts/setup.sh`
- Package name translation (e.g., `fd` vs `fd-find`)
- Installation method varies (Homebrew vs apt vs manual)

**Homebrew initialization:**
- macOS: `/opt/homebrew` or `/usr/local`
- Linux: `/home/linuxbrew/.linuxbrew`
- Configured in `.zprofile`

## Testing Changes

Before committing changes:

1. **Verify git filters:**
   ```bash
   ./scripts/verify_filters.sh
   ```

2. **Run pre-commit hooks:**
   ```bash
   pre-commit run --all-files
   ```

3. **Test stow simulation:**
   ```bash
   stow --simulate --no-folding .
   ```

4. **Run health check:**
   ```bash
   ./scripts/health.sh
   ```

5. **Check zsh syntax:**
   ```bash
   zsh -n .zshrc
   zsh -n .zshenv
   zsh -n .zprofile
   ```

## Common Issues

**Stow conflicts:**
- Backup existing files: `mv ~/.zshrc ~/.zshrc.backup`
- Remove broken symlinks: `find ~ -maxdepth 2 -xtype l -delete`

**Git filters not working:**
- Run: `./scripts/setup_smudge_clean.sh`
- Verify: `./scripts/verify_filters.sh`

**Pre-commit hooks failing:**
- Update: `pre-commit autoupdate`
- Clean: `pre-commit clean && pre-commit install`
- Skip specific hook: `SKIP=shellcheck git commit -m "message"`

**PATH issues:**
- Check `.zshenv` for PATH configuration
- Source `.zprofile` manually: `source ~/.zprofile`
- Verify Homebrew is initialized

## Development Workflow

### Standard Workflow
1. **Make changes** to dotfiles in `~/.dotfiles/`
2. **Test locally** (source configs, restart shell)
3. **Run validation** (verify_filters, pre-commit, stow --simulate)
4. **Commit changes:**
   - `restow` - Stow, commit with atomic commits, and push (dotfiles repo only)
   - `gcr` - Commit with atomic commits but don't push (any git repo)
   - `grel` - Create a semantic version GitHub release (any git repo)
5. **On other machines** - `git pull && stow .`

### Atomic Commits Feature
The `restow` and `gcr` functions automatically analyze changes and create semantic atomic commits:
- Groups related changes by file type and purpose
- Generates conventional commit messages automatically
- Falls back to single commit if analysis fails
- Use `-s` or `--single` flag to skip atomic commits

Examples:
```bash
restow              # Atomic commits by default
restow -s           # Force single commit
restow --no-checks  # Skip pre-commit hooks
restow --force      # Skip stow dry-run

gcr                 # Commit with atomic commits
gcr -s              # Commit with single message
```

### Release Workflow
The `grel` function automates semantic versioning and GitHub releases:
1. Commits any uncommitted changes (optional)
2. Calculates next version based on conventional commits
3. Creates and pushes a git tag
4. Creates a GitHub release with auto-generated notes

Example:
```bash
grel                # Interactive release process
grel -s             # Single commit if changes exist
grel --skip-commit  # Don't commit changes, just tag and release
```

## Tool Ecosystem

**Essential tools:**
- GNU Stow (symlink manager)
- Neovim (text editor)
- Tmux (terminal multiplexer)
- Starship (prompt)
- Pre-commit (hook framework)

**CLI utilities (installed via setup.sh):**
- fd (fast file finder)
- ripgrep (fast grep)
- fzf (fuzzy finder)
- bat (cat with highlighting)
- eza (modern ls)
- zoxide (smarter cd)
- git-delta (better git diffs)
- lazygit (git TUI)
- atuin (shell history sync)

**Key bindings:**
- `Ctrl+F` - tmux-sessionizer (fuzzy project finder)
- `Ctrl+X Ctrl+E` - Edit command in $EDITOR

## Git Workflow Functions

### Core Functions (defined in `.zsh/git-functions.zsh`)

**`restow`** - Complete dotfiles sync workflow:
- Runs pre-commit checks
- Stows dotfiles with conflict detection
- Creates atomic commits (or single commit with `-s`)
- Pushes to remote
- Options: `-s/--single`, `--no-checks`, `--force`

**`gcr`** (git commit remain) - Commit without pushing:
- Analyzes changes and creates atomic commits
- Use in any git repository
- Options: `-s/--single` for single commit

**`grel`** (git release) - Create GitHub releases:
- Commits pending changes (optional)
- Calculates semantic version from commit history
- Creates git tag and GitHub release
- Options: `-s/--single`, `--skip-commit`

**`gas`** (git autosync) - Auto-sync repositories:
- Wrapper for `git-autosync.sh`
- Periodically pulls and pushes changes
- Usage: `gas ~/path/to/repo`

**`sto`** (stow tool) - Install and track in setup.sh:
- Runs installation command
- Automatically adds to `scripts/setup.sh`
- Commits and pushes the change
- Usage: `sto brew install package`

### Completion System
All git workflow functions have custom zsh completions in `.zsh/completions/`:
- `_restow` - Completes restow flags
- `_gcr` - Completes gcr flags
- `_grel` - Completes grel flags
- `_gas` - Completes directory paths
- `_sto` - Completes based on first argument (brew, cargo, etc.)

## Notes for Claude Code

- When modifying shell configs, respect the modular architecture:
  - `.zshenv` - Environment and PATH only
  - `.zprofile` - Login shell initialization
  - `.zshrc` - Sources modular files from `.zsh/`
  - New functionality goes in appropriate `.zsh/*.zsh` file
- Always verify git filters after changes to filtered files
- Use the existing functions and patterns rather than introducing new approaches
- Test with `stow --simulate` before making symlink changes
- Pre-commit hooks are strict - expect them to catch common mistakes
- The repository prioritizes portability and username-agnostic paths
- XDG Base Directory compliance is a core principle
- Atomic commits are the default - functions auto-analyze changes and create semantic commits
