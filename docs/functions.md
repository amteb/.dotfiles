# Zsh Functions

Custom Zsh functions defined in `.zshrc` that provide enhanced functionality for dotfiles management, git workflows, and terminal productivity.

## Table of Contents

- [Git & Commit Functions](#git--commit-functions)
  - [gcr](#gcr)
  - [grel](#grel)
  - [gas](#gas)
- [Dotfiles Management](#dotfiles-management)
  - [restow](#restow)
  - [sto](#sto)
- [Utility Functions](#utility-functions)
  - [l](#l)
  - [g](#g)
  - [tmux_sessionizer_widget](#tmux_sessionizer_widget)

---

## Git & Commit Functions

### gcr

**Git Commit with AI-generated messages**

Automatically stages all changes and creates intelligent commits using Claude AI to analyze diffs and generate conventional commit messages.

**Usage:**
```bash
gcr                # Create atomic commits (multiple thematic commits)
gcr -s             # Create single commit
gcr --single       # Same as -s
```

**Behavior:**
- Stages all changes (`git add .`)
- By default, creates atomic commits by grouping related changes
- Falls back to single commit if atomic commit analysis fails
- Uses Claude AI to generate conventional commit messages
- Does NOT push to remote (commits only)

**Flags:**
- `-s, --single`: Force single commit mode instead of atomic commits

**Examples:**
```bash
# After making changes to multiple files
gcr
# Output:
# Analyzing changes...
# Creating 2 commit(s)...
#   [1/2] feat: add user authentication
#   [2/2] docs: update API documentation
# Committed changes (not pushed)

# Force single commit
gcr -s
# Output:
# Created commit: refactor: improve error handling
# Committed changes (not pushed)
```

**Dependencies:**
- Claude CLI (`claude` command)
- Scripts: `atomic-commits.sh`, `generate-commit-message.sh`

---

### grel

**GitHub Release Creator**

Interactive tool to create GitHub releases with semantic versioning based on conventional commits. Handles uncommitted changes, calculates next version, creates tags, and publishes releases.

**Usage:**
```bash
grel                 # Interactive release creation
grel -s              # Use single commit for uncommitted changes
grel --single        # Same as -s
grel --skip-commit   # Skip commit step, use current HEAD
```

**Interactive Flow:**
1. **Uncommitted Changes**: Prompts to commit using same logic as `gcr`
   - `Y`: Commit changes now (default)
   - `n`: Skip commit, use current HEAD
   - `q`: Quit without creating release

2. **Version Preview**: Shows current version, calculated next version, and commits since last tag

3. **Release Confirmation**: Final approval before creating release
   - `y`: Proceed with release
   - `N`: Cancel (default)
   - `q`: Quit

**What It Does:**
1. Commits uncommitted changes (optional)
2. Calculates next semantic version from conventional commits
3. Creates annotated git tag (e.g., `v1.2.3`)
4. Pushes tag to origin
5. Creates GitHub release with auto-generated notes
6. Displays release URL

**Version Calculation:**
- **Breaking changes** (`feat!:`, `BREAKING CHANGE`) → MAJOR bump
- **Features** (`feat:`) → MINOR bump
- **Fixes/Other** (`fix:`, `chore:`, etc.) → PATCH bump
- First release defaults to `v0.1.0`

**Flags:**
- `-s, --single`: Use single commit mode for uncommitted changes
- `--skip-commit`: Skip commit step entirely

**Examples:**
```bash
# Interactive release
grel
# Output:
# === GitHub Release Creator ===
#
# You have uncommitted changes.
# Commit them now? [Y/n/q] y
#
# Analyzing changes...
# Created commit: feat: add dark mode toggle
#
# Calculating next version...
# Current version: v1.2.0
# Next version:    v1.3.0
#
# Commits since last tag:
# a1b2c3d feat: add dark mode toggle
# d4e5f6g docs: update README
#
# This will:
#   1. Tag the current commit as v1.3.0
#   2. Push the tag to origin
#   3. Create a GitHub release with auto-generated notes
#
# Proceed with release? [y/N/q] y
#
# Creating tag v1.3.0...
# Pushing tag to origin...
# Creating GitHub release...
#
# ✓ Release v1.3.0 created successfully!
# View release: https://github.com/user/repo/releases/tag/v1.3.0
```

**Requirements:**
- GitHub CLI (`gh`) must be installed and authenticated
- Git repository with remote origin
- Conventional commit history for version calculation

**Dependencies:**
- GitHub CLI (`gh`)
- Scripts: `calculate-next-version.sh`, `atomic-commits.sh`, `generate-commit-message.sh`

---

### gas

**Git Auto-Sync Manager**

Wrapper function for the `git-autosync` script. Manages automatic synchronization of git repositories on a schedule using cron jobs.

**Usage:**
```bash
gas add <repo> <frequency>      # Add repository to auto-sync
gas remove <repo> <frequency>   # Remove repository from auto-sync
gas list [frequency]            # List repositories
gas list -a                     # List all repositories
gas sync <frequency>            # Sync repositories now
gas sync -a                     # Sync all repositories
gas update-cron                 # Update cron jobs
gas add-freq <freq> <cron>      # Add new frequency
gas remove-freq <freq>          # Remove frequency
```

**Examples:**
```bash
# Add current directory to nightly sync
gas add . nightly

# Add specific repo to weekly sync
gas add ~/Dev/myproject weekly

# List all auto-sync repositories
gas list -a

# Manually sync all nightly repositories
gas sync nightly
```

**See:** [git-autosync script documentation](scripts.md#git-autosync) for full details.

---

## Dotfiles Management

### restow

**Restow Dotfiles with Smart Commits**

Restows dotfiles using GNU Stow and automatically commits changes with AI-generated commit messages.

**Usage:**
```bash
restow           # Restow and create atomic commits
restow -s        # Restow and create single commit
restow --single  # Same as -s
```

**Behavior:**
1. Changes to `$DOTFILES` directory
2. Runs `stow .` to create/update symlinks
3. Stages all changes
4. Creates commits using same logic as `gcr`:
   - Default: Atomic commits (multiple thematic commits)
   - With `-s`: Single commit
5. Pushes to remote
6. Returns to original directory (unless already in `$DOTFILES`)

**Flags:**
- `-s, --single`: Force single commit mode

**Examples:**
```bash
# After modifying dotfiles
restow
# Output:
# Stowing dotfiles...
# Analyzing changes...
# Creating 2 commit(s)...
#   [1/2] feat(zsh): add new alias
#   [2/2] chore(tmux): update theme
# Pushing to remote...
# Synced .dotfiles repo

# Force single commit
restow -s
# Output:
# Stowing dotfiles...
# Created commit: chore: update dotfiles
# Pushing to remote...
# Synced .dotfiles repo
```

**Environment Variables:**
- `$DOTFILES`: Path to dotfiles directory (required)

**Dependencies:**
- GNU Stow
- Claude CLI
- Scripts: `atomic-commits.sh`, `generate-commit-message.sh`

---

### sto

**Install and Add to Stow Setup**

Executes an installation command and automatically adds it to `scripts/setup.sh` for future dotfiles setup on new machines.

**Usage:**
```bash
sto <install-command>
```

**Behavior:**
1. Executes the installation command
2. Checks if command already exists in `setup.sh`
3. If new, appends command to `setup.sh`
4. Commits and pushes the change to dotfiles repo

**Examples:**
```bash
# Install package and add to setup
sto brew install ripgrep
# Output:
# ... installation output ...
# Installation command logged and dotfiles repo synced.

# Install multiple packages
sto brew install bat exa fd
# Output:
# ... installation output ...
# Installation command logged and dotfiles repo synced.

# If command already exists
sto brew install ripgrep
# Output:
# ... installation output ...
# Command already exists in setup.sh: brew install ripgrep
```

**Use Cases:**
- Track installed packages across machines
- Maintain reproducible dotfiles setup
- Automatically document installation steps

---

## Utility Functions

### l

**Enhanced Directory Listing**

Wrapper for `eza` with opinionated defaults for a beautiful, informative directory listing.

**Usage:**
```bash
l [path]           # List files in directory
l                  # List files in current directory
lt                 # Tree view (alias for l --tree)
```

**Features:**
- Icons for file types
- Git status integration
- Git repository indicators
- Grouped directories first
- Relative timestamps
- File headers
- All files shown (including hidden)
- Long format with metadata

**Examples:**
```bash
# List current directory
l

# List specific directory
l ~/Dev

# Tree view
lt
```

**Dependencies:**
- `eza` (modern replacement for `ls`)

---

### g

**Markdown Viewer**

Wrapper for `glow` with custom theme for rendering markdown files in the terminal.

**Usage:**
```bash
g <file>              # View markdown file
g README.md           # View README
```

**Examples:**
```bash
# View README
g README.md

# View documentation
g docs/functions.md
```

**Dependencies:**
- `glow` (terminal markdown renderer)

---

### tmux_sessionizer_widget

**Fuzzy Project Switcher (Tmux)**

Zsh widget bound to `Ctrl+F` that launches the tmux-sessionizer script for quick project switching.

**Usage:**
- Press `Ctrl+F` in any Zsh shell

**Behavior:**
1. Clears command line
2. Launches `tmux-sessionizer` script
3. Resets prompt after script completes

**Keybinding:**
- `^F` (Ctrl+F)

**See:** [tmux-sessionizer script documentation](scripts.md#tmux-sessionizer) for full details.

---

## Helper Functions

### qpushd / qpopd

**Quiet Directory Stack Operations**

Silent versions of `pushd` and `popd` that suppress directory stack output.

**Usage:**
```bash
qpushd <directory>    # Push directory silently
qpopd                 # Pop directory silently
```

**Examples:**
```bash
# Navigate with quiet pushd
qpushd ~/Dev
# ... do work ...
qpopd  # Return to previous directory
```

---

## Configuration

### Environment Variables

Functions rely on these environment variables:

- `$DOTFILES`: Path to dotfiles directory
- `$DEV`: Path to development projects directory
- `$XDG_CONFIG_HOME`: XDG config directory (defaults to `~/.config`)

### Required Tools

Most functions require these tools:

- **Git**: Version control
- **Claude CLI**: AI-powered commit messages and analysis
- **GitHub CLI** (`gh`): GitHub release management (for `grel`)
- **GNU Stow**: Symlink management (for `restow`)
- **eza**: Enhanced ls (for `l`)
- **glow**: Markdown renderer (for `g`)
- **fzf**: Fuzzy finder (for sessionizer widgets)
- **fd**: Modern find (for sessionizer scripts)

Install missing tools:
```bash
brew install git gh stow eza glow fzf fd-find
```

For Claude CLI, see: https://github.com/anthropics/claude-cli
