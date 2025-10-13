# dotfiles

Cross-platform, system-agnostic dotfiles for UNIX-based systems (macOS, Linux, WSL) managed with GNU Stow.

## Overview

This repository contains my personal configuration files (dotfiles) for zsh and various development tools. The configurations are designed to be:

- **Cross-platform**: Works on macOS, Linux (Debian/Ubuntu), and WSL
- **System-agnostic**: Uses `$HOME` and XDG paths instead of hardcoded usernames
- **Portable**: Easy to deploy on new systems using GNU Stow
- **Modular**: Organized following the XDG Base Directory Specification

## Contents

### Shell Configuration

- **`.zshenv`** - Environment variables and PATH configuration (sourced for all zsh invocations)
- **`.zprofile`** - Login shell initialization (Homebrew, SSH agent, cargo)
- **`.zshrc`** - Interactive shell configuration (aliases, functions, completions)
- **`.zsh/`** - Additional zsh configurations and completions

### Application Configs (`.config/`)

The repository includes configurations for:

- **alacritty** - GPU-accelerated terminal emulator
- **atuin** - Shell history sync tool
- **bottom/btop** - System monitoring tools
- **fish** - Alternative shell configs
- **ghostty** - Terminal emulator
- **hatch** - Python project manager
- **lazygit** - Terminal UI for git
- **neofetch** - System information tool
- **nvim** - Neovim text editor configuration
- **posting** - API testing tool
- **starship.toml** - Cross-shell prompt configuration
- **tmux** - Terminal multiplexer
- **warp-terminal** - Modern terminal
- **WindowsTerminal** - Windows Terminal (for WSL)

### Scripts (`scripts/`)

Utility scripts for system setup and workflow automation:

- **`setup.sh`** - Main setup script for installing dependencies and configuring the system
- **`git-autosync`** - Automatically sync git repositories
- **`tmux-sessionizer`** - Fuzzy finder for tmux sessions (bound to `Ctrl+F`)
- **`tmux-windowizer`** - Fuzzy finder for tmux windows
- **`smudge.sh` / `clean.sh`** - Git filters for username-agnostic configs
- **`setup_smudge_clean.sh`** - Configure git smudge/clean filters

### Other Files

- **`.gitconfig.dotfiles`** - Git configuration (included in `~/.gitconfig`)
- **`.pre-commit-config.yaml`** - Pre-commit hooks configuration
- **`.stow-local-ignore`** - Files to exclude from stowing
- **`.hushlogin`** - Suppress login messages

## Prerequisites

The following tools are required or recommended:

### Required
- **zsh** - Shell
- **git** - Version control
- **stow** - Symlink manager

### Recommended
- **Homebrew** - Package manager (macOS/Linux)
- **neovim** - Text editor
- **tmux** - Terminal multiplexer
- **starship** - Shell prompt
- **fd** - Fast file finder
- **ripgrep** - Fast grep alternative
- **fzf** - Fuzzy finder
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls replacement
- **zoxide** - Smarter cd command
- **git-delta** - Better git diffs
- **lazygit** - Terminal UI for git

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
```

### 2. Run the setup script

The setup script will install dependencies and configure your system:

```bash
./scripts/setup.sh
```

This script will:
- Detect your OS (macOS/Linux)
- Prompt you to install missing dependencies
- Configure git with the included `.gitconfig.dotfiles`
- Set up git smudge/clean filters
- Optionally run `stow` to symlink dotfiles

### 3. Manual stowing (if needed)

If you didn't run stow during setup:

```bash
cd $HOME/.dotfiles
stow .
```

This creates symlinks from `$HOME` to the files in this repository.

### 4. Restart your shell

```bash
exec zsh
```

## Usage

### Shell Functions

The dotfiles include several custom functions:

- **`restow`** - Re-stow dotfiles and sync to git
  ```bash
  restow
  ```

- **`sto <command>`** - Run an install command and add it to setup.sh
  ```bash
  sto brew install htop
  ```

- **`gas [path]`** - Run git-autosync on a repository
  ```bash
  gas ~/projects/myrepo
  ```

- **`l [options]`** - Enhanced ls using eza
  ```bash
  l          # List files with icons and git status
  lt         # Tree view
  ```

### Key Bindings

- **`Ctrl+F`** - Launch tmux-sessionizer (fuzzy find projects and create/switch tmux sessions)
- **`Ctrl+X Ctrl+E`** - Edit current command in $EDITOR

### Aliases

Common aliases included:

```bash
v, v.       # nvim, nvim .
c, c.       # code, code .
g           # git
lg          # lazygit
t, ta, tl   # tmux, tmux attach, tmux list-sessions
tf          # tmux-sessionizer
sz, sp      # source ~/.zshrc, source ~/.zprofile
```

### Named Directories

Quick navigation using `~` shorthand:

```bash
cd ~dot        # $HOME/.dotfiles
cd ~projects   # $HOME/projects
cd ~downloads  # $HOME/Downloads
```

## Configuration Philosophy

### XDG Base Directory Compliance

Configurations follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):

- `XDG_CONFIG_HOME` - `~/.config` (configuration files)
- `XDG_CACHE_HOME` - `~/.cache` (cached data)
- `XDG_DATA_HOME` - `~/.local/share` (data files)
- `XDG_STATE_HOME` - `~/.local/state` (state data)

### Username-Agnostic Paths

All configurations use `$HOME` instead of hardcoded paths like `/Users/username`. Git smudge/clean filters help maintain this when pulling configs between systems.

### Shell Startup Files

The zsh configuration is split across three files:

1. **`.zshenv`** - Always sourced first
   - Environment variables
   - PATH configuration
   - XDG directory setup

2. **`.zprofile`** - Sourced for login shells
   - Homebrew initialization
   - SSH agent setup
   - One-time login tasks

3. **`.zshrc`** - Sourced for interactive shells
   - Aliases and functions
   - Prompt configuration
   - Interactive features

## Customization

### Local Overrides

Create `~/.zshrc.local` for machine-specific configurations that won't be committed:

```bash
# ~/.zshrc.local
export CUSTOM_VAR="value"
alias custom="command"
```

### Adding New Configs

1. Add the config file/directory to this repository
2. Update `.stow-local-ignore` if needed
3. Run `restow` to symlink and commit

### Modifying Setup Script

To add new tools to the setup process, edit `scripts/setup.sh` and add to the `UTILS` variable or create a new installation block.

## Git Integration

### Included Git Configuration

The repository includes `.gitconfig.dotfiles` with settings for:

- Git delta as the diff pager
- Useful aliases
- Better diff and merge tools
- Sensible defaults

This file is included in your main `~/.gitconfig` via:

```gitconfig
[include]
    path = ~/.gitconfig.dotfiles
```

### Smudge/Clean Filters

This repository uses Git's smudge/clean filters to keep configurations username-agnostic while maintaining functionality on your local system.

**How it works:**

1. **Clean filter** (when committing): Replaces personal values with placeholders
   - `$HOME` → `%%HOME%%`
   - Your git name → `%%GIT_NAME%%`
   - Your git email → `%%GIT_EMAIL%%`

2. **Smudge filter** (when checking out): Replaces placeholders with your values
   - `%%HOME%%` → `$HOME`
   - `%%GIT_NAME%%` → Your git name
   - `%%GIT_EMAIL%%` → Your git email

**Benefits:**
- Repository stores generic placeholders
- Your working directory has real, functional values
- Works seamlessly across different machines with different usernames
- No hardcoded personal information in the repository

**Setup:**

The filters are configured automatically when you run `scripts/setup.sh`. To manually set them up:

```bash
./scripts/setup_smudge_clean.sh
```

**Verification:**

To verify the filters are working correctly:

```bash
./scripts/verify_filters.sh
```

This script will check that:
- Filters are configured in git
- The clean script properly converts values to placeholders
- The smudge script properly converts placeholders to values
- Files will be stored correctly in git

**What gets filtered:**

Files configured in `.gitattributes` with `filter=substitution`:
- `.zshrc`, `.zshenv`, `.zprofile`
- `.config/hatch/config.toml`
- Any other config files with personal information

**Note:** The filters operate transparently. You edit files with real values in your working directory, but git stores them with placeholders automatically.

## Pre-commit Hooks

This repository uses [pre-commit](https://pre-commit.com/) hooks to maintain code quality and prevent common mistakes.

### Included Hooks

**Standard Checks:**
- Remove trailing whitespace
- Ensure files end with a newline
- Validate YAML, TOML, and JSON syntax
- Detect large files (>1MB)
- Check for merge conflicts
- Ensure executables have shebangs
- Detect private keys
- Fix line endings (LF)
- Check for case conflicts

**Security:**
- **gitleaks**: Scan for secrets and credentials
- **detect-private-key**: Find accidentally committed private keys
- **verify-no-personal-info**: Ensure personal information is filtered out

**Code Quality:**
- **shellcheck**: Lint shell scripts for common errors
- **bashate**: Check shell script style
- **stylua**: Format Lua code (Neovim configs)
- **yamllint**: Lint YAML files

**Custom Checks:**
- **verify-git-filters-configured**: Ensure smudge/clean filters are set up
- **check-shell-scripts-executable**: Verify scripts in `scripts/` are executable
- **check-common-mistakes**: Detect bash sourcing in zsh configs, PATH overwrites
- **verify-xdg-paths**: Suggest using XDG variables for portability

### Setup

Pre-commit should be installed automatically by the setup script. If not:

```bash
# Install pre-commit
uv tool install pre-commit

# Install the git hooks
pre-commit install
```

### Usage

Hooks run automatically on `git commit`. To run manually:

```bash
# Run on all files
pre-commit run --all-files

# Run specific hook
pre-commit run shellcheck --all-files

# Skip hooks for a commit (use sparingly)
git commit --no-verify
```

### Updating Hooks

```bash
# Update to latest versions
pre-commit autoupdate

# Clean and reinstall
pre-commit clean
pre-commit install
```

### Disabling Specific Hooks

If a hook is too noisy, you can skip it in `.pre-commit-config.yaml` or for specific commits:

```bash
SKIP=shellcheck git commit -m "message"
```

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:

```bash
# Backup existing files
mv ~/.zshrc ~/.zshrc.backup

# Try stowing again
cd $HOME/.dotfiles
stow .
```

### Missing Dependencies

Run the setup script again to install missing tools:

```bash
cd $HOME/.dotfiles
./scripts/setup.sh
```

### Shell Not Switching

If zsh isn't your default shell:

```bash
chsh -s $(which zsh)
```

Then log out and log back in.

### PATH Issues

Ensure your PATH includes the necessary directories. Check `.zshenv`:

```bash
echo $PATH
```

If Homebrew commands aren't found, source `.zprofile` manually:

```bash
source ~/.zprofile
```

## License

GLWTS (Good Luck With That Shit) Public License - See [LICENSE.md](LICENSE.md)

## Contributing

These are personal dotfiles, but feel free to fork and adapt them for your own use. If you find bugs or have suggestions, issues and pull requests are welcome.

## Acknowledgments

Inspired by the dotfiles community and countless hours of configuration tweaking. Special thanks to the developers of the tools configured here.
