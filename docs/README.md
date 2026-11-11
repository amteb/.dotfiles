# Dotfiles Documentation

Comprehensive documentation for custom functions and scripts in this dotfiles repository.

## Overview

This dotfiles repository includes custom Zsh functions and shell scripts that provide:

- **AI-Powered Git Workflows**: Automated commit message generation and atomic commits
- **GitHub Release Automation**: Semantic versioning and release creation
- **Session Management**: Quick project switching for Tmux and Zellij
- **Repository Synchronization**: Automated git sync on schedules
- **Dotfiles Management**: Simplified stowing and setup tracking

## Documentation Structure

### [Functions](functions.md)

Custom Zsh functions defined in `.zshrc`:

**Git & Commits:**
- [`gcr`](functions.md#gcr) - Git commit with AI-generated messages (atomic or single)
- [`grel`](functions.md#grel) - Interactive GitHub release creator with semantic versioning
- [`gas`](functions.md#gas) - Git auto-sync manager wrapper

**Dotfiles:**
- [`restow`](functions.md#restow) - Restow dotfiles with smart commits
- [`sto`](functions.md#sto) - Install and add to stow setup

**Utilities:**
- [`l`](functions.md#l) - Enhanced directory listing (eza wrapper)
- [`g`](functions.md#g) - Markdown viewer (glow wrapper)
- [`tmux_sessionizer_widget`](functions.md#tmux_sessionizer_widget) - Fuzzy project switcher (Ctrl+F)

### [Scripts](scripts.md)

Shell scripts in `scripts/` directory:

**Git & Commits:**
- [`atomic-commits.sh`](scripts.md#atomic-commitssh) - AI-powered atomic commit creator
- [`generate-commit-message.sh`](scripts.md#generate-commit-messagesh) - Single commit message generator
- [`calculate-next-version.sh`](scripts.md#calculate-next-versionsh) - Semantic version calculator
- [`git-autosync`](scripts.md#git-autosync) - Automatic repository synchronization

**Session Management:**
- [`tmux-sessionizer`](scripts.md#tmux-sessionizer) - Fuzzy project finder for Tmux
- [`tmux-windowizer`](scripts.md#tmux-windowizer) - Named tmux window creator
- [`zellij-sessionizer`](scripts.md#zellij-sessionizer) - Fuzzy project finder for Zellij

## Quick Start

### Installation

1. **Clone repository:**
   ```bash
   git clone https://github.com/yourusername/dotfiles ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Install dependencies:**
   ```bash
   # Core tools
   brew install git zsh stow

   # Enhanced tools
   brew install eza glow fzf fd-find

   # Terminal multiplexers (choose one or both)
   brew install tmux zellij

   # GitHub CLI (for releases)
   brew install gh
   gh auth login
   ```

3. **Install Claude CLI:**
   ```bash
   # See: https://github.com/anthropics/claude-cli
   ```

4. **Stow dotfiles:**
   ```bash
   stow .
   ```

5. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

### Essential Environment Variables

Add to your `.zshenv` or `.zprofile`:

```bash
export DOTFILES="$HOME/.dotfiles"
export DEV="$HOME/Dev"  # Your projects directory
export XDG_CONFIG_HOME="$HOME/.config"
```

## Common Workflows

### Git Workflow

```bash
# Make changes to files
vim file.js

# Create smart commits (atomic or single)
gcr                    # Multiple thematic commits
gcr -s                 # Single commit

# Create a GitHub release
grel                   # Interactive, semantic versioning
```

### Dotfiles Workflow

```bash
# Modify dotfiles
vim ~/.zshrc

# Restow and sync
restow                 # Atomic commits + push
restow -s              # Single commit + push

# Track new installation
sto brew install ripgrep
```

### Project Navigation

```bash
# Fuzzy find and switch projects (Tmux)
Ctrl+F                 # Keybinding
tmux-sessionizer       # Command

# Direct navigation
tmux-sessionizer ~/Dev/myproject

# Fuzzy find and switch projects (Zellij)
zellij-sessionizer
```

### Repository Auto-Sync

```bash
# Add repository to nightly sync
gas add . nightly

# Add to weekly sync
gas add ~/Dev/project weekly

# List all auto-synced repos
gas list -a

# Manually sync
gas sync nightly
```

## Features Highlight

### AI-Powered Commits

Functions and scripts use Claude AI to analyze git diffs and generate:

- **Atomic commits**: Multiple focused commits grouped by theme
- **Conventional commits**: Proper formatting (feat, fix, chore, etc.)
- **Smart messages**: Concise, descriptive commit messages

**Example:**
```bash
# After making changes to auth, docs, and tests
gcr

# Output:
# Analyzing changes...
# Creating 3 commit(s)...
#   [1/3] feat(auth): add OAuth2 support
#   [2/3] test(auth): add OAuth2 test coverage
#   [3/3] docs: update authentication guide
```

### Semantic Versioning

Automatically calculates next version based on conventional commits:

- `feat!:` or `BREAKING CHANGE` → MAJOR bump (1.2.3 → 2.0.0)
- `feat:` → MINOR bump (1.2.3 → 1.3.0)
- `fix:`, `chore:`, etc. → PATCH bump (1.2.3 → 1.2.4)

**Example:**
```bash
grel

# Output:
# Calculating next version...
# Current version: v1.2.3
# Next version:    v1.3.0
#
# Commits since last tag:
# a1b2c3d feat: add dark mode
# d4e5f6g fix: resolve memory leak
```

### Interactive Workflows

Most tools provide interactive prompts with safety checks:

- Confirm before committing
- Preview changes before release
- Approve version bumps
- Cancel at any time with `q`

### Session Management

Quickly switch between projects with fuzzy finding:

- Scans configured project directories
- Creates/switches to sessions automatically
- Context-aware (inside/outside multiplexer)
- Consistent naming across sessions

## Keybindings

| Key | Function | Description |
|-----|----------|-------------|
| `Ctrl+F` | tmux-sessionizer | Fuzzy find and switch tmux sessions |
| `Ctrl+X E` | edit-command-line | Edit command in $EDITOR |

## Aliases

Common aliases defined in `.zshrc`:

| Alias | Command | Description |
|-------|---------|-------------|
| `lg` | `lazygit` | Git TUI |
| `ld` | `lazydocker` | Docker TUI |
| `v` | `nvim` | Neovim |
| `tf` | `tmux-sessionizer` | Tmux project switcher |
| `lt` | `l --tree` | Tree view directory listing |

See `.zshrc` for complete alias list.

## Configuration Files

### Git Auto-Sync

Location: `~/.git-autosync.cfg`

```ini
[nightly]
cron = "0 0 * * *"
paths = ["~/.dotfiles"]

[weekly]
cron = "0 0 * * 0"
paths = []
```

### Tmux

Location: `~/.config/tmux/tmux.conf`

Custom tmux configuration loaded by sessionizer scripts.

### Zellij

Location: `~/.config/zellij/config.kdl`

Includes `minimalist` layout used by `zellij-sessionizer`.

## Troubleshooting

### Claude CLI Issues

```bash
# Check if Claude is installed
command -v claude

# Test Claude
claude -p "Hello"

# Install/reinstall Claude CLI
# See: https://github.com/anthropics/claude-cli
```

### Git Auto-Sync Not Working

```bash
# Check config exists
cat ~/.git-autosync.cfg

# Verify cron jobs
crontab -l

# Update cron jobs
gas update-cron

# Check logs
tail -f ~/.log/git_auto_sync.log
```

### Sessionizer Not Finding Projects

```bash
# Verify environment variables
echo $DEV
echo $DOTFILES

# Test fd command
fd . $DEV --max-depth 1 --type d

# Test fzf
echo "test" | fzf
```

### Stow Conflicts

```bash
# Check for existing files
ls -la ~/ | grep -E '(zshrc|tmux.conf)'

# Backup existing files
mv ~/.zshrc ~/.zshrc.backup

# Restow
cd ~/.dotfiles
stow .
```

## Development

### Adding New Functions

1. Add function to `.zshrc`
2. Document in `docs/functions.md`
3. Add examples and usage
4. Update this README

### Adding New Scripts

1. Create script in `scripts/`
2. Make executable: `chmod +x scripts/script-name.sh`
3. Document in `docs/scripts.md`
4. Add to relevant function wrappers if needed
5. Update this README

### Documentation Style

- Clear, concise descriptions
- Practical examples
- Expected output shown
- Error cases documented
- Requirements listed
- Exit codes documented

## Philosophy

This dotfiles repository follows these principles:

### KISS (Keep It Simple, Stupid)

- Single-purpose tools
- Clear interfaces
- No over-engineering

### DRY (Don't Repeat Yourself)

- Shared logic extracted (e.g., `_commit_changes`)
- Reusable scripts
- Modular design

### UNIX Philosophy

- Do one thing well
- Work together
- Text-based interfaces

### Best Practices

- Time-tested approaches
- Well-documented code
- Minimal comments (self-documenting code)
- Conventional commits
- Semantic versioning

## Resources

### External Documentation

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [Tmux](https://github.com/tmux/tmux/wiki)
- [Zellij](https://zellij.dev/)
- [Claude CLI](https://github.com/anthropics/claude-cli)

### Related Projects

- [eza](https://github.com/eza-community/eza) - Modern ls replacement
- [glow](https://github.com/charmbracelet/glow) - Terminal markdown renderer
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [fd](https://github.com/sharkdp/fd) - Modern find replacement
- [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI

## Contributing

Improvements welcome! Please:

1. Follow existing code style
2. Update documentation
3. Test thoroughly
4. Use conventional commits

## License

MIT License - see LICENSE file for details.

---

**Last Updated:** 2026-01-03

For questions or issues, please open an issue on GitHub.
