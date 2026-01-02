# Dotfiles Repository Improvement Suggestions

This document contains recommendations to enhance your dotfiles repository and workflow.

## Table of Contents
1. [Workflow Automation](#workflow-automation)
2. [Documentation](#documentation)
3. [Testing & Validation](#testing--validation)
4. [Organization](#organization)
5. [Backup & Recovery](#backup--recovery)
6. [Development Tools](#development-tools)
7. [Security Enhancements](#security-enhancements)
8. [Cross-Platform Support](#cross-platform-support)

---

## Workflow Automation

### 1. Add a Makefile/Justfile for Common Tasks

**Why:** Simplify common operations with memorable commands

**Implementation:**
```makefile
# Makefile
.PHONY: help install update sync test clean

help:
	@echo "Available commands:"
	@echo "  make install  - Run setup.sh and install dotfiles"
	@echo "  make update   - Update dependencies and pre-commit hooks"
	@echo "  make sync     - Stow and sync dotfiles to git"
	@echo "  make test     - Run all validation checks"
	@echo "  make clean    - Remove broken symlinks"

install:
	./scripts/setup.sh
	stow .

update:
	brew upgrade || true
	pre-commit autoupdate
	nvim --headless "+Lazy! sync" +qa

sync:
	stow .
	git add .
	git diff --cached --quiet || (git commit -m "chore: update dotfiles" && git push)

test:
	./scripts/verify_filters.sh
	pre-commit run --all-files
	stow --simulate .

clean:
	find ~ -xtype l -delete  # Remove broken symlinks
```

**Alternative:** Use `just` (modern alternative to make):
```justfile
# justfile
default:
    @just --list

# Install dotfiles on a new system
install:
    ./scripts/setup.sh
    stow .

# Update all dependencies
update:
    brew upgrade || true
    pre-commit autoupdate

# Sync dotfiles to git
sync:
    ./scripts/restow

# Run all tests
test:
    ./scripts/verify_filters.sh
    pre-commit run --all-files
```

### 2. Improve the `restow` Function

**Current Issue:** Auto-commits and pushes without review

**Suggested Improvement:**
```zsh
function restow() {
    local original_dir="$(pwd)"
    cd "$DOTFILES"

    # Run pre-commit checks first
    if ! pre-commit run --all-files; then
        echo "Pre-commit checks failed. Fix issues before restowing."
        cd "$original_dir"
        return 1
    fi

    # Dry run stow first
    if ! stow --no-folding --simulate . 2>&1 | grep -q "WARNING\|ERROR"; then
        stow --no-folding .
        echo "Dotfiles restowed successfully"
    else
        echo "Stow simulation failed. Check for conflicts."
        cd "$original_dir"
        return 1
    fi

    # Stage and show diff
    git add .
    if ! git diff --cached --quiet; then
        echo "Changes to be committed:"
        git diff --cached --stat

        # Prompt for commit message
        echo -n "Commit message (or 'skip' to not commit): "
        read commit_msg

        if [[ "$commit_msg" != "skip" ]]; then
            git commit -m "${commit_msg:-chore: update dotfiles}"

            # Ask before pushing
            echo -n "Push to remote? [y/N]: "
            read should_push
            [[ "$should_push" =~ ^[Yy]$ ]] && git push
        fi
    else
        echo "No changes to commit"
    fi

    [[ "$original_dir" != "$DOTFILES" ]] && cd "$original_dir"
}
```

### 3. Add Git Aliases for Common Operations

Add to `.gitconfig.dotfiles`:
```gitconfig
[alias]
    # Dotfile-specific aliases
    df-sync = !cd $DOTFILES && git add . && git commit -m \"chore: update dotfiles\" && git push
    df-diff = !cd $DOTFILES && git diff
    df-status = !cd $DOTFILES && git status
    df-log = !cd $DOTFILES && git log --oneline -10

    # Undo last commit but keep changes
    uncommit = reset --soft HEAD~1

    # Show what will be committed
    staged = diff --cached

    # Interactive rebase for cleaning up commits
    tidy = rebase -i HEAD~10
```

---

## Documentation

### 1. Add Architecture Decision Records (ADRs)

**Why:** Document why you made certain choices

**Implementation:**
```bash
mkdir -p docs/adr
```

Example ADR:
```markdown
# ADR-001: Use GNU Stow for Dotfile Management

## Status
Accepted

## Context
Need a way to manage dotfiles that:
- Creates symlinks automatically
- Doesn't require custom tooling
- Works across different systems

## Decision
Use GNU Stow to create symlinks from ~/.dotfiles to $HOME

## Consequences
- Simple and standard
- Requires stow to be installed
- Some files need to be in .stow-local-ignore
```

### 2. Create a CHANGELOG.md

Track significant changes:
```markdown
# Changelog

## [Unreleased]
- Added comprehensive pre-commit hooks
- Implemented git smudge/clean filters
- Created verification scripts

## [1.0.0] - 2025-01-15
### Added
- Initial Neovim configuration
- Tmux configuration with plugins
- Zsh setup with starship prompt

### Changed
- Migrated from bash to zsh

### Fixed
- PATH ordering issues on macOS
```

### 3. Add a FAQ.md

Common questions and solutions:
```markdown
# FAQ

## How do I update my dotfiles on another machine?
cd ~/.dotfiles && git pull && stow .

## Why are my personal values showing in files?
Run: ./scripts/verify_filters.sh to check if filters are working

## How do I add a new config file?
1. Add it to ~/.dotfiles
2. Add to .gitattributes if it contains personal info
3. Run: restow
```

---

## Testing & Validation

### 1. Add a Comprehensive Test Script

Create `scripts/test.sh`:
```bash
#!/bin/bash
set -e

echo "=== Dotfiles Test Suite ==="

# Check required tools
echo "1. Checking required tools..."
REQUIRED_TOOLS="git stow zsh nvim tmux"
for tool in $REQUIRED_TOOLS; do
    if ! command -v $tool &> /dev/null; then
        echo "❌ Missing: $tool"
        exit 1
    fi
    echo "✅ Found: $tool"
done

# Verify git filters
echo ""
echo "2. Verifying git filters..."
./scripts/verify_filters.sh || exit 1

# Run pre-commit hooks
echo ""
echo "3. Running pre-commit hooks..."
pre-commit run --all-files || exit 1

# Simulate stow
echo ""
echo "4. Simulating stow..."
stow --simulate --no-folding . || exit 1

# Check for broken symlinks
echo ""
echo "5. Checking for broken symlinks..."
BROKEN=$(find ~ -maxdepth 3 -xtype l 2>/dev/null | wc -l)
if [ $BROKEN -gt 0 ]; then
    echo "⚠️  Found $BROKEN broken symlinks"
    find ~ -maxdepth 3 -xtype l 2>/dev/null
else
    echo "✅ No broken symlinks"
fi

# Validate shell syntax
echo ""
echo "6. Validating shell files..."
for file in .zshrc .zshenv .zprofile; do
    zsh -n "$file" && echo "✅ $file syntax OK" || echo "❌ $file syntax error"
done

echo ""
echo "=== All tests passed! ==="
```

### 2. Add GitHub Actions CI (Optional)

Create `.github/workflows/test.yml`:
```yaml
name: Test Dotfiles

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y stow zsh shellcheck

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.x'

      - name: Install pre-commit
        run: pip install pre-commit

      - name: Run pre-commit
        run: pre-commit run --all-files

      - name: Verify git filters
        run: |
          git config --local user.name "Test User"
          git config --local user.email "test@example.com"
          ./scripts/setup_smudge_clean.sh
          ./scripts/verify_filters.sh

      - name: Test stow
        run: stow --simulate --no-folding .
```

---

## Organization

### 1. Split Large Config Files

**Current:** Single `.zshrc` with everything

**Suggested Structure:**
```
.config/zsh/
├── .zshrc           # Main file that sources others
├── aliases.zsh      # All aliases
├── functions.zsh    # All functions
├── completions.zsh  # Completion config
├── keybindings.zsh  # Key bindings
├── plugins.zsh      # Plugin management
└── local.zsh        # Machine-specific (in .gitignore)
```

Then in `.zshrc`:
```zsh
# Source all zsh config files
for config in $XDG_CONFIG_HOME/zsh/*.zsh; do
    [[ -f "$config" ]] && source "$config"
done
```

### 2. Create a `bin/` Directory for Scripts

Move frequently used scripts to a dedicated bin:
```bash
mkdir -p bin
# Move utility scripts here
# Add to PATH in .zshenv: path+=("$DOTFILES/bin")
```

### 3. Add a `docs/` Directory

```
docs/
├── setup/           # Setup guides for different OSes
│   ├── macos.md
│   ├── ubuntu.md
│   └── wsl.md
├── adr/             # Architecture decisions
├── troubleshooting.md
└── tools.md         # List of installed tools and why
```

---

## Backup & Recovery

### 1. Add Backup Script

Create `scripts/backup.sh`:
```bash
#!/bin/bash
# Backup important files that aren't in dotfiles

BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup SSH keys (encrypted)
if [ -d "$HOME/.ssh" ]; then
    tar czf - "$HOME/.ssh" | gpg -c > "$BACKUP_DIR/ssh.tar.gz.gpg"
fi

# Backup GPG keys
if command -v gpg &> /dev/null; then
    gpg --export-secret-keys --armor > "$BACKUP_DIR/gpg-secret.asc"
fi

# Backup application data
cp -r "$HOME/.config/gh" "$BACKUP_DIR/" 2>/dev/null || true

echo "Backup created at: $BACKUP_DIR"
```

### 2. Add Recovery Documentation

Create `docs/recovery.md`:
```markdown
# Disaster Recovery

## Fresh Machine Setup
1. Install git: `xcode-select --install` (macOS) or `apt install git`
2. Clone: `git clone git@github.com:atbraz/.dotfiles.git ~/.dotfiles`
3. Run: `cd ~/.dotfiles && ./scripts/setup.sh`
4. Restore SSH keys from backup
5. Restore GPG keys from backup

## Restore from Backup
See `scripts/backup.sh` for backup location
```

### 3. Git Worktree for Experimentation

Add an alias to test changes safely:
```bash
# In .zshrc
alias df-experiment='git worktree add /tmp/dotfiles-test && cd /tmp/dotfiles-test'
```

---

## Development Tools

### 1. Add EditorConfig

Create `.editorconfig`:
```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{sh,zsh,bash}]
indent_style = space
indent_size = 4

[*.{lua,toml,yaml,yml}]
indent_style = space
indent_size = 2

[Makefile]
indent_style = tab
```

### 2. Add a .nvmrc / .node-version

If you use Node.js:
```bash
echo "lts/*" > .nvmrc
```

### 3. Add Direnv Support

Create `.envrc` (gitignored):
```bash
# Auto-load development environment
export DOTFILES_DEV=1
```

---

## Security Enhancements

### 1. Add git-crypt for Sensitive Configs

For files that MUST contain secrets:
```bash
# Install git-crypt
brew install git-crypt

# Add to .gitattributes
echo ".env.* filter=git-crypt diff=git-crypt" >> .gitattributes

# Initialize
git-crypt init
git-crypt export-key ~/dotfiles-key.gpg
```

### 2. Add SOPS for Secret Management

Alternative to git-crypt using age encryption:
```bash
# Install sops and age
brew install sops age

# Create age key
age-keygen -o ~/.config/sops/age/keys.txt

# Add to .sops.yaml
```

### 3. Enhanced gitleaks Configuration

Create `.gitleaks.toml`:
```toml
[extend]
useDefault = true

[[rules]]
id = "dotfiles-personal-info"
description = "Personal information in dotfiles"
regex = '''a@b\.com|/Users/a|a@c'''
[rules.allowlist]
paths = ['''^\.git/''', '''^scripts/hooks/''']
```

---

## Cross-Platform Support

### 1. Add Platform Detection Functions

Create `scripts/platform.sh`:
```bash
#!/bin/bash

is_macos() { [[ "$OSTYPE" == "darwin"* ]]; }
is_linux() { [[ "$OSTYPE" == "linux-gnu"* ]]; }
is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
is_ubuntu() { [ -f /etc/lsb-release ] && grep -qi ubuntu /etc/lsb-release; }
is_debian() { [ -f /etc/debian_version ]; }

get_platform() {
    if is_macos; then echo "macos"
    elif is_wsl; then echo "wsl"
    elif is_ubuntu; then echo "ubuntu"
    elif is_debian; then echo "debian"
    else echo "linux"; fi
}
```

### 2. Add Conditional Stowing

Create platform-specific directories:
```
macos/        # macOS-only configs
linux/        # Linux-only configs
wsl/          # WSL-only configs
```

Add to setup.sh:
```bash
PLATFORM=$(get_platform)
stow --no-folding .
[ -d "$PLATFORM" ] && stow --no-folding "$PLATFORM"
```

### 3. Add Platform-Specific README

Create `docs/setup/macos.md`, `docs/setup/ubuntu.md`, etc.

---

## Additional Suggestions

### 1. Version Pinning

Create `.tool-versions` (for asdf):
```
nodejs lts
python 3.11.0
ruby 3.2.0
```

### 2. Add Benchmarking

Create `scripts/benchmark.sh`:
```bash
#!/bin/bash
echo "Benchmarking shell startup time..."
for i in {1..10}; do
    /usr/bin/time -p zsh -i -c exit
done 2>&1 | grep real | awk '{sum+=$2; count++} END {print "Average: " sum/count "s"}'
```

### 3. Add Health Check Script

Create `scripts/health.sh`:
```bash
#!/bin/bash
# Check dotfiles health

echo "🏥 Dotfiles Health Check"
echo ""

# Check if dotfiles are stowed
[ -L ~/.zshrc ] && echo "✅ Dotfiles are stowed" || echo "❌ Dotfiles not stowed"

# Check if git filters work
./scripts/verify_filters.sh > /dev/null && echo "✅ Git filters working" || echo "❌ Git filters broken"

# Check for updates
cd $DOTFILES
git fetch
BEHIND=$(git rev-list HEAD..origin/main --count)
[ $BEHIND -eq 0 ] && echo "✅ Up to date" || echo "⚠️  $BEHIND commits behind"

# Check for broken symlinks
BROKEN=$(find ~ -maxdepth 2 -xtype l 2>/dev/null | wc -l)
[ $BROKEN -eq 0 ] && echo "✅ No broken symlinks" || echo "⚠️  $BROKEN broken symlinks"
```

### 4. Add Tags/Releases

Use semantic versioning for your dotfiles:
```bash
git tag -a v1.0.0 -m "Initial stable release"
git push --tags
```

---

## Priority Recommendations

**High Priority:**
1. ✅ Add Makefile/Justfile for common tasks
2. ✅ Improve restow function with safety checks
3. ✅ Add comprehensive test script
4. ✅ Create health check script

**Medium Priority:**
5. Split large config files for maintainability
6. Add proper documentation (FAQ, Recovery, ADRs)
7. Add EditorConfig for consistency
8. Version pin your tools

**Low Priority (Nice to Have):**
9. REMOVED
10. Git worktrees for experimentation
11. SOPS/git-crypt for secrets
12. Benchmarking scripts

---

## Implementation Plan

```bash
# Week 1: Essential improvements
make install script
improve restow function
add test suite
add health check

# Week 2: Organization
split zsh configs
create docs/ structure
add FAQ and troubleshooting

# Week 3: Polish
add EditorConfig
create CHANGELOG
add git aliases
version tagging
```

Let me know which suggestions you'd like me to implement!
