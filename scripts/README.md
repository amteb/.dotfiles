# Scripts

Utility scripts for system setup, workflow automation, and dotfiles management.

## Setup & Installation

### `setup.sh`

Main installation script for new systems. Detects OS (macOS/Linux/WSL) and installs dependencies.

```bash
./scripts/setup.sh
```

**Installs:**
- Core utilities: `curl`, `wget`, `git`, `bat`, `fd`, `fzf`, `ripgrep`, `jq`, `zoxide`, `eza`, `git-delta`, `sd`
- Development tools: `neovim`, `tmux`, `uv`, `tlrc`
- Shell: `zsh`, `starship`, `antidote`
- Security: `keychain`, `gitleaks`, `pre-commit`
- Symlink manager: `stow`

**Also configures:**
- Git to include `.gitconfig.dotfiles`
- Git smudge/clean filters
- Pre-commit hooks

### `setup_smudge_clean.sh`

Configure git smudge/clean filters for username-agnostic configs.

```bash
./scripts/setup_smudge_clean.sh
```

Creates filter scripts if missing and registers them with git.

## Git Filters

These scripts enable portable dotfiles by replacing personal information with placeholders.

### How It Works

1. **On checkout (smudge):** `%%HOME%%` becomes `/Users/yourname`
2. **On commit (clean):** `/Users/yourname` becomes `%%HOME%%`

### Placeholder Mappings

| Placeholder | Replaced With |
|-------------|---------------|
| `%%HOME%%` | `$HOME` |
| `%%GIT_NAME%%` | Git user name |
| `%%GIT_EMAIL%%` | Git user email |

### `smudge.sh`

Restores placeholders to actual local values when checking out files.

```bash
# Applied automatically by git on checkout
# Manual test:
echo "%%HOME%%/test" | ./scripts/smudge.sh
# Output: /Users/yourname/test
```

### `clean.sh`

Replaces personal values with placeholders when committing.

```bash
# Applied automatically by git on commit
# Manual test:
echo "$HOME/test" | ./scripts/clean.sh
# Output: %%HOME%%/test
```

### `apply_smudge.sh`

Re-apply smudge filter to all repository files. Useful after cloning or if filters weren't working.

```bash
./scripts/apply_smudge.sh
```

**Warning:** This removes and re-adds all files from the git index.

### `verify_filters.sh`

Verify filter configuration and test functionality.

```bash
./scripts/verify_filters.sh
```

**Checks:**
1. Git filters are configured
2. Clean filter converts values to placeholders
3. Smudge filter restores placeholders to values
4. No personal information in staged files

## AI-Powered Commit Tools

These scripts use Claude to generate intelligent commit messages.

**Requirement:** Claude CLI must be installed and authenticated.

### `atomic-commits.sh`

Analyzes staged changes and creates semantic, atomic commits using Claude.

```bash
# Stage your changes
git add .

# Let Claude analyze and create atomic commits
./scripts/atomic-commits.sh
```

**Features:**
- Groups related changes into logical commits
- Generates conventional commit messages
- Handles pre-commit hook auto-fixes (retries up to 3 times)
- Truncates large diffs to 30,000 characters

**Output Example:**
```
Analyzing changes...
Waiting for Claude to analyze diff...
Creating 3 commit(s)...
  [1/3] feat(shell): add new git workflow functions
  [2/3] refactor(config): simplify tmux keybindings
  [3/3] docs: update README with new features
Successfully created 3 commit(s)
```

### `generate-commit-message.sh`

Generate a single conventional commit message using Claude.

```bash
# Stage your changes
git add .

# Get a commit message
./scripts/generate-commit-message.sh
# Output: feat(shell): add new alias for docker compose
```

**Features:**
- Uses Claude Haiku for speed
- Prompts for confirmation on large diffs (>20,000 chars)
- Returns only the commit message, no extra text

### `calculate-next-version.sh`

Calculate the next semantic version based on conventional commits since the last tag.

```bash
./scripts/calculate-next-version.sh
# Output: 1.2.0
```

**Version Bump Rules:**
- `BREAKING CHANGE` or `!` suffix: MAJOR bump
- `feat:` commits: MINOR bump
- `fix:` commits: PATCH bump
- Other commits (`chore`, `docs`, etc.): PATCH bump

## Utilities

### `tmux-sessionizer.zsh`

Fuzzy finder for tmux sessions. Quickly create or switch to project sessions.

```bash
# Via keybinding (default: Ctrl+F)
# Or run directly:
./scripts/tmux-sessionizer.zsh

# Jump to specific path:
./scripts/tmux-sessionizer.zsh ~/projects/myapp
```

**Features:**
- Scans configured project directories
- Shows git status in preview (branch, modified, staged, etc.)
- Detects project types (node, rust, go, python)
- Creates new tmux session if doesn't exist
- Sources tmux config on new sessions

**Preview Shows:**
- Project type markers (git, node, rust, go, python)
- Git branch and status (modified, staged, untracked, ahead/behind)
- Recent commits
- Directory listing

### `git-autosync.sh`

Automatic git repository synchronization with configurable cron scheduling.

```bash
# Add repository to daily sync
./scripts/git-autosync.sh add ~/notes daily

# Sync all daily repos
./scripts/git-autosync.sh sync daily

# Sync all frequencies
./scripts/git-autosync.sh sync --all

# Use atomic commits
./scripts/git-autosync.sh --atomic sync daily

# List configured repos
./scripts/git-autosync.sh list --all

# Add custom frequency
./scripts/git-autosync.sh add-freq hourly '0 * * * *'
```

**Commands:**
| Command | Description |
|---------|-------------|
| `add REPO FREQ` | Add repository to frequency |
| `remove REPO FREQ` | Remove repository from frequency |
| `list [FREQ]` | List repositories |
| `list --all` | List all frequencies and repos |
| `sync FREQ` | Sync repositories for frequency |
| `sync --all` | Sync all frequencies |
| `add-freq FREQ CRON` | Add new frequency |
| `remove-freq FREQ` | Remove frequency |
| `update-cron` | Update cron jobs |

**Default Frequencies:**
- `daily`: `0 0 * * *` (midnight)
- `weekly`: `0 0 * * 0` (Sunday midnight)
- `monthly`: `0 0 1 * *` (1st of month)

**Config Location:** `~/.git-autosync.cfg`

### `health.sh`

Comprehensive dotfiles health check.

```bash
./scripts/health.sh
```

**Checks:**
1. Dotfiles are stowed (symlinks exist)
2. Git filters are working
3. Repository is up to date
4. No broken symlinks
5. Pre-commit is installed and configured
6. Required tools installed (git, stow, zsh)
7. Default shell is zsh
8. No uncommitted changes

### `colors.sh`

Centralized ANSI color definitions. Source in scripts for consistent styling.

```bash
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

echo -e "${GREEN}Success!${NC}"
echo -e "${RED}Error!${NC}"
echo -e "${YELLOW}Warning${NC}"
echo -e "${BLUE}Info${NC}"
```

**Available Colors:**
- `$RED`, `$GREEN`, `$YELLOW`, `$BRIGHT_YELLOW`, `$BLUE`, `$CYAN`
- `$NC` - No Color (reset)

### `improved-restow.zsh`

Enhanced restow functions with safety checks. Source in `.zshrc` to use.

**Functions:**

```bash
# Interactive restow with pre-commit checks and conflict detection
restow

# Quick restow without prompts (for automation)
restow-auto

# Show diff before restowing
restow-diff
```

## Pre-commit Hooks

Custom hooks in `hooks/` directory. Configured in `.pre-commit-config.yaml`.

### `verify-no-personal-info.sh`

Ensures personal information is filtered out of commits.

**Checks for actual values in:**
- `.zshrc`, `.zshenv`, `.zprofile`
- `.config/hatch/config.toml`

### `verify-git-filters.sh`

Quick check that git filters are configured.

### `check-scripts-executable.sh`

Verifies shell scripts in `scripts/` have executable permissions.

### `check-common-mistakes.sh`

Detects common dotfile mistakes:
- Bash sourcing in zsh configs
- PATH overwrites (should use `path+=`)

## Dependencies

| Script | Dependencies |
|--------|--------------|
| `atomic-commits.sh` | `claude`, `jq`, `git` |
| `generate-commit-message.sh` | `claude`, `git` |
| `tmux-sessionizer.zsh` | `tmux`, `fzf`, `fd`, `eza` |
| `git-autosync.sh` | `git`, `cron` |
| `health.sh` | `git`, `stow`, `pre-commit` |
| `setup.sh` | `brew` (macOS) or `apt` (Linux) |

## Environment Variables

| Variable | Default | Used By |
|----------|---------|---------|
| `DOTFILES` | `$HOME/.dotfiles` | Most scripts |
| `XDG_CONFIG_HOME` | `$HOME/.config` | tmux-sessionizer |
| `CODE` | - | tmux-sessionizer (project scanning) |
