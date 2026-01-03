# Shell Scripts

Custom shell scripts in `scripts/` that provide automation, git workflows, and terminal session management.

## Table of Contents

- [Git & Commit Scripts](#git--commit-scripts)
  - [atomic-commits.sh](#atomic-commitssh)
  - [generate-commit-message.sh](#generate-commit-messagesh)
  - [calculate-next-version.sh](#calculate-next-versionsh)
  - [git-autosync](#git-autosync)
- [Session Management](#session-management)
  - [tmux-sessionizer](#tmux-sessionizer)
  - [tmux-windowizer](#tmux-windowizer)
  - [zellij-sessionizer](#zellij-sessionizer)

---

## Git & Commit Scripts

### atomic-commits.sh

**AI-Powered Atomic Commit Creator**

Analyzes staged git changes using Claude AI and automatically groups them into multiple atomic, thematic commits following conventional commit format.

**Location:** `scripts/atomic-commits.sh`

**Usage:**
```bash
# Stage changes first
git add .

# Create atomic commits
./scripts/atomic-commits.sh
```

**Behavior:**
1. Checks for staged changes
2. Gathers changed files and diffs
3. Sends diff to Claude for analysis
4. Receives JSON array of commit groups
5. Unstages all changes
6. Re-stages files per commit group
7. Creates individual commits with generated messages

**Output Format:**
```bash
Analyzing changes...
Waiting for Claude to analyze diff...
Creating 3 commit(s)...
  [1/3] feat(auth): add OAuth2 support
  [2/3] refactor(api): simplify error handling
  [3/3] docs: update API documentation
Successfully created 3 commit(s)
```

**Commit Grouping Logic:**
- Groups related changes together
- Separates features, fixes, and chores
- Creates focused, single-purpose commits
- Follows conventional commit format

**Error Handling:**
- Validates Claude response as JSON
- Ensures all files are included in exactly one commit
- Re-stages all changes on failure
- Exits with error code on failure

**Requirements:**
- Claude CLI installed and configured
- Staged git changes
- Git repository

**Limitations:**
- Max diff size: 30,000 characters (truncates if larger)
- Requires network access for Claude API
- May fail on very complex diffs

**Exit Codes:**
- `0`: Success
- `1`: Error (no staged changes, Claude failure, invalid JSON, etc.)

---

### generate-commit-message.sh

**AI-Powered Single Commit Message Generator**

Generates a single conventional commit message for all staged changes using Claude AI.

**Location:** `scripts/generate-commit-message.sh`

**Usage:**
```bash
# Stage changes first
git add .

# Generate commit message
./scripts/generate-commit-message.sh
# Output: feat: add user authentication
```

**Behavior:**
1. Checks for staged changes
2. Gathers diff statistics and details
3. Prompts for confirmation if diff is large (>20,000 chars)
4. Sends diff to Claude for analysis
5. Returns single-line commit message

**Output:**
- Prints commit message to stdout
- All status messages go to stderr
- Returns only the commit message text (no markdown, no explanations)

**Interactive Prompt:**
```bash
# When diff is large
Diff is large (25000 chars). Send to Claude for commit message? [y/N]
```

**Commit Message Format:**
- Follows conventional commits specification
- Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`
- Format: `type(scope): description`
- Concise and focused on "why" not "what"

**Examples:**
```bash
# Feature addition
./scripts/generate-commit-message.sh
# Output: feat(auth): add OAuth2 login support

# Bug fix
./scripts/generate-commit-message.sh
# Output: fix(api): handle null response from database

# Documentation
./scripts/generate-commit-message.sh
# Output: docs: update installation instructions
```

**Requirements:**
- Claude CLI installed and configured
- Staged git changes
- Git repository

**Limitations:**
- Max diff size: 20,000 characters by default
- Requires user confirmation for large diffs
- Requires network access for Claude API

**Exit Codes:**
- `0`: Success (commit message generated)
- `1`: Error (no Claude CLI, no staged changes, user cancelled, etc.)

**Integration:**
Used by `gcr`, `grel`, and `restow` functions as fallback when atomic commits fail.

---

### calculate-next-version.sh

**Semantic Version Calculator**

Analyzes conventional commits since the last git tag and calculates the next semantic version number.

**Location:** `scripts/calculate-next-version.sh`

**Usage:**
```bash
./scripts/calculate-next-version.sh
# Output: 1.3.0
```

**Behavior:**
1. Gets latest git tag (or starts at 0.0.0)
2. Parses current version (MAJOR.MINOR.PATCH)
3. Analyzes commits since last tag
4. Determines version bump type
5. Returns new version number

**Version Bump Rules:**

| Commit Type | Version Bump | Example |
|------------|-------------|---------|
| **Breaking Change** | MAJOR | `1.2.3` → `2.0.0` |
| `feat!:` or `BREAKING CHANGE` | MAJOR | `1.2.3` → `2.0.0` |
| `feat:` | MINOR | `1.2.3` → `1.3.0` |
| `fix:` | PATCH | `1.2.3` → `1.2.4` |
| Other (`chore:`, `docs:`, etc.) | PATCH | `1.2.3` → `1.2.4` |

**Breaking Change Detection:**
```bash
# Exclamation mark syntax
feat(api)!: redesign authentication flow

# Footer syntax
feat(api): redesign authentication flow

BREAKING CHANGE: API endpoints now require API key
```

**Examples:**

```bash
# No tags exist yet
./scripts/calculate-next-version.sh
# Output: 0.1.0

# Last tag: v1.2.3, new feature added
git log v1.2.3..HEAD
# feat: add dark mode toggle
./scripts/calculate-next-version.sh
# Output: 1.3.0

# Last tag: v1.2.3, bug fix
git log v1.2.3..HEAD
# fix: resolve memory leak
./scripts/calculate-next-version.sh
# Output: 1.2.4

# Last tag: v1.2.3, breaking change
git log v1.2.3..HEAD
# feat!: redesign API
./scripts/calculate-next-version.sh
# Output: 2.0.0

# No new commits since last tag
./scripts/calculate-next-version.sh
# Output: 1.2.3 (unchanged)
```

**Tag Format Support:**
- Supports tags with or without `v` prefix
- Examples: `v1.2.3`, `1.2.3`
- Output always excludes `v` prefix

**Error Handling:**
```bash
# Invalid tag format
git tag invalid-tag
./scripts/calculate-next-version.sh
# Output: Error: Invalid tag format: invalid-tag
# Exit code: 1
```

**Requirements:**
- Git repository
- Git tags following semantic versioning
- Conventional commit messages

**Exit Codes:**
- `0`: Success (version calculated)
- `1`: Error (invalid tag format)

**Integration:**
Used by `grel` function to automatically determine release version.

---

### git-autosync

**Automatic Git Repository Synchronization Manager**

Manages automatic synchronization of multiple git repositories on a schedule using cron jobs. Supports custom frequencies and maintains configuration in `~/.git-autosync.cfg`.

**Location:** `scripts/git-autosync`

**Usage:**
```bash
git-autosync add <repo> <frequency>
git-autosync remove <repo> <frequency>
git-autosync list [frequency | -a]
git-autosync sync <frequency | -a>
git-autosync update-cron
git-autosync add-freq <frequency> <cron-expression>
git-autosync remove-freq <frequency>
```

**Commands:**

#### add
Add a repository to auto-sync schedule.

```bash
# Add current directory
git-autosync add . nightly

# Add specific repository
git-autosync add ~/Dev/myproject weekly

# Add repository to custom frequency
git-autosync add ~/Dev/important daily
```

**Behavior:**
- Validates repository is a git repository
- Creates frequency if it doesn't exist
- Adds repository path to config
- Updates cron jobs automatically

#### remove
Remove a repository from auto-sync schedule.

```bash
git-autosync remove ~/Dev/myproject weekly
git-autosync remove . nightly
```

#### list
List repositories for a frequency or all frequencies.

```bash
# List available frequencies
git-autosync list

# List repositories for specific frequency
git-autosync list nightly

# List all repositories
git-autosync list -a
git-autosync list --all
```

**Output:**
```
Repositories for nightly:
  ~/.dotfiles
  ~/Dev/myproject

Repositories for weekly:
  ~/Dev/archive
```

#### sync
Manually synchronize repositories.

```bash
# Sync specific frequency
git-autosync sync nightly

# Sync all frequencies
git-autosync sync -a
git-autosync sync --all
```

**Sync Process:**
1. Changes to repository directory
2. Checks for uncommitted changes
3. Stages all changes (`git add .`)
4. Creates commit if changes exist: `chore: <frequency> sync`
5. Pulls from remote (`git pull`)
6. Pushes to remote (`git push`)

#### update-cron
Update cron jobs for all frequencies.

```bash
git-autosync update-cron
```

**Behavior:**
- Updates cron jobs to match current configuration
- Automatically called after `add`, `remove`, `add-freq`, `remove-freq`

#### add-freq
Add a new synchronization frequency.

```bash
# Add daily sync at 8 AM
git-autosync add-freq daily "0 8 * * *"

# Add hourly sync
git-autosync add-freq hourly "0 * * * *"

# Interactive prompt for cron expression
git-autosync add-freq custom
# Prompt: Enter cron expression for custom (e.g., 0 0 * * * for daily at midnight):
```

**Cron Expression Format:**
```
* * * * *
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

**Examples:**
- `0 0 * * *` - Daily at midnight
- `0 0 * * 0` - Weekly on Sunday at midnight
- `0 0 1 * *` - Monthly on the 1st at midnight
- `0 */6 * * *` - Every 6 hours
- `*/30 * * * *` - Every 30 minutes

#### remove-freq
Remove a frequency and all its repositories.

```bash
git-autosync remove-freq daily
```

**Configuration File:**

Location: `~/.git-autosync.cfg`

Format:
```ini
[nightly]
cron = "0 0 * * *"
paths = ["~/.dotfiles", "~/Dev/project"]

[weekly]
cron = "0 0 * * 0"
paths = ["~/Dev/archive"]

[monthly]
cron = "0 0 1 * *"
paths = []
```

**Default Frequencies:**
- `nightly`: Daily at midnight (`0 0 * * *`)
- `weekly`: Sunday at midnight (`0 0 * * 0`)
- `monthly`: 1st of month at midnight (`0 0 1 * *`)

**Logging:**

Cron job output is logged to: `~/.log/git_auto_sync.log`

```bash
# View sync logs
tail -f ~/.log/git_auto_sync.log
```

**Requirements:**
- Git installed
- Cron daemon running
- Write access to `~/.git-autosync.cfg`
- Git repositories with remote tracking configured

**Wrapper Function:**

Use the `gas` Zsh function as a shorthand:
```bash
gas add . nightly
gas list -a
gas sync weekly
```

**Exit Codes:**
- `0`: Success
- `1`: Error (invalid repo, config not found, etc.)

---

## Session Management

### tmux-sessionizer

**Fuzzy Project Finder for Tmux**

Interactive fuzzy finder that quickly switches between tmux sessions for different projects.

**Location:** `scripts/tmux-sessionizer`

**Usage:**
```bash
# Interactive mode (fuzzy finder)
tmux-sessionizer

# Direct mode (skip fuzzy finder)
tmux-sessionizer ~/Dev/myproject
```

**Behavior:**

1. **Project Discovery:**
   - Scans `$DEV` directory for projects (max depth 1)
   - Scans `~/Documents/finmath` directory
   - Includes `.dotfiles` directory
   - Displays sorted list in `fzf`

2. **Session Management:**
   - Creates new tmux session if doesn't exist
   - Attaches to existing session if already exists
   - Session name derived from directory basename
   - Dots in names replaced with underscores

3. **Context Awareness:**
   - **No tmux running:** Creates new session
   - **Tmux running, not inside:** Attaches to session
   - **Inside tmux:** Switches to session

**Project Paths:**
Configure by modifying `get_project_paths()` function:
```zsh
add_paths_from_dir "$DEV/" "$FD_CMD"
add_paths_from_dir "$HOME/Documents/finmath/" "$FD_CMD"
paths[.dotfiles]="$DOTFILES"
```

**Session Naming:**
```bash
# Directory: ~/Dev/my.project
# Session name: my_project

# Directory: ~/.dotfiles
# Session name: _dotfiles
```

**Keybinding:**

Bound to `Ctrl+F` via `tmux_sessionizer_widget` in `.zshrc`:
```zsh
bindkey '^F' tmux_sessionizer_widget
```

**Requirements:**
- Tmux
- `fd` (fd-find)
- `fzf`
- `$DEV` environment variable

**Examples:**
```bash
# Launch fuzzy finder
tmux-sessionizer
# [fzf shows project list, user selects with arrows and Enter]

# Direct navigation
tmux-sessionizer ~/Dev/myproject
# Immediately switches to/creates 'myproject' session

# From outside tmux
tmux-sessionizer
# Creates or attaches to selected session

# From inside tmux
tmux-sessionizer
# Switches to selected session
```

**Related:**
- Alias: `tf` (defined in `.zshrc`)
- Keybinding: `Ctrl+F`

---

### tmux-windowizer

**Create or Switch to Named Tmux Window**

Creates a new tmux window within the current session or switches to an existing one, optionally executing a command.

**Location:** `scripts/tmux-windowizer`

**Usage:**
```bash
tmux-windowizer <name> [command]
```

**Behavior:**
1. Takes window name from first argument
2. Sanitizes name (replaces `.` and `/` with `__`)
3. Creates window if doesn't exist in current session
4. Sends optional command to window
5. Executes command automatically

**Examples:**
```bash
# Create/switch to window named 'tests'
tmux-windowizer tests

# Create window and run command
tmux-windowizer tests npm test

# Create window for git operations
tmux-windowizer git git status

# Branch-based window (sanitizes branch name)
tmux-windowizer feature/new-login git log
# Window name: feature__new-login
```

**Name Sanitization:**
```bash
# Input: feature/bug-fix
# Window name: feature__bug-fix

# Input: my.project.test
# Window name: my__project__test
```

**Use Cases:**
- Dedicated testing windows
- Per-branch development windows
- Separate windows for different tasks
- Quick command execution in named contexts

**Requirements:**
- Tmux
- Must be run from within a tmux session

---

### zellij-sessionizer

**Fuzzy Project Finder for Zellij**

Interactive fuzzy finder for quickly switching between Zellij sessions for different projects. Zellij equivalent of `tmux-sessionizer`.

**Location:** `scripts/zellij-sessionizer`

**Usage:**
```bash
# Interactive mode (fuzzy finder)
zellij-sessionizer

# Direct mode (skip fuzzy finder)
zellij-sessionizer ~/Dev/myproject
```

**Behavior:**

1. **Project Discovery:**
   - Scans `~/Documents/dev` directory
   - Scans `~/Documents/finmath` directory
   - Includes `.dotfiles` directory
   - Displays sorted list in `fzf`

2. **Session Management:**
   - Creates new Zellij session if doesn't exist
   - Uses `minimalist` layout
   - Sets working directory to project path
   - Attaches to existing session if already exists

3. **Context Awareness:**
   - **No Zellij running:** Creates new session
   - **Zellij running, not inside:** Attaches to session
   - **Inside Zellij:** Switches to session

**Session Naming:**
```bash
# Directory: ~/Dev/my.project
# Session name: my_project

# Directory: ~/.dotfiles
# Session name: _dotfiles
```

**Layout:**
Uses `minimalist` layout defined in Zellij config.

**Requirements:**
- Zellij
- `fd` (fd-find)
- `fzf`
- Zellij config at `$XDG_CONFIG_HOME/zellij/config.kdl`
- `minimalist` layout defined

**Examples:**
```bash
# Launch fuzzy finder
zellij-sessionizer
# [fzf shows project list, user selects with arrows and Enter]

# Direct navigation
zellij-sessionizer ~/Documents/dev/myproject
# Immediately switches to/creates 'myproject' session

# From outside Zellij
zellij-sessionizer
# Creates or attaches to selected session

# From inside Zellij
zellij-sessionizer
# Switches to selected session
```

**Comparison with tmux-sessionizer:**

| Feature | tmux-sessionizer | zellij-sessionizer |
|---------|-----------------|-------------------|
| Terminal Multiplexer | Tmux | Zellij |
| Layout | tmux.conf | minimalist layout |
| Project Paths | `$DEV` | `~/Documents/dev` |
| Session Switching | `switch-client` | `switch-session` |
| Keybinding | `Ctrl+F` | None (manual) |

---

## Utility Scripts

These scripts are primarily used internally by other scripts and functions. They are not typically called directly by users, but are documented here for completeness.

### Helper Scripts

Most scripts in the repository are either:
- **Git filter scripts**: `smudge.sh`, `clean.sh`, `apply_smudge.sh`, `setup_smudge_clean.sh`, `verify_filters.sh`
- **Setup scripts**: `setup.sh`, `health.sh`

These are used for dotfiles setup and maintenance but are not primary user-facing tools.

---

## Script Conventions

### Error Handling

All scripts follow these conventions:

```bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures
```

### Exit Codes

- `0`: Success
- `1`: Error (with descriptive message to stderr)

### Output

- **stdout**: Script output (results, data)
- **stderr**: Status messages, errors, prompts

### Colors

Scripts use consistent color codes:

```bash
BLUE='\033[0;34m'      # Info messages
GREEN='\033[0;32m'     # Success messages
YELLOW='\033[0;33m'    # Warnings
RED='\033[0;31m'       # Errors
CYAN='\033[0;36m'      # Highlights
NC='\033[0m'           # No Color (reset)
```

### Dependencies

Scripts check for required tools:

```bash
if ! command -v tool &>/dev/null; then
    echo "Error: tool not found"
    exit 1
fi
```

---

## Requirements

### Common Dependencies

Most scripts require:

- **Git**: Version control
- **Zsh**: Shell (for zsh scripts)
- **Bash**: Shell (for bash scripts)

### Optional Dependencies

Depending on the script:

- **Claude CLI**: AI-powered features (`atomic-commits.sh`, `generate-commit-message.sh`)
- **fzf**: Fuzzy finding (sessionizer scripts)
- **fd**: Fast file finder (sessionizer scripts)
- **Tmux**: Terminal multiplexer (`tmux-sessionizer`, `tmux-windowizer`)
- **Zellij**: Terminal multiplexer (`zellij-sessionizer`)
- **Cron**: Scheduled tasks (`git-autosync`)

### Installation

```bash
# Core tools
brew install git zsh

# Optional tools
brew install fzf fd-find tmux zellij

# Claude CLI
# See: https://github.com/anthropics/claude-cli
```
