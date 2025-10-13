# Pre-commit Hooks Guide

This document provides detailed information about the pre-commit hooks configured in this dotfiles repository.

## Quick Start

```bash
# Install and set up hooks
pre-commit install

# Run all hooks on all files
pre-commit run --all-files

# Run a specific hook
pre-commit run shellcheck --all-files

# Update hooks to latest versions
pre-commit autoupdate
```

## Hook Categories

### 1. File Quality Checks

**Purpose:** Ensure consistent formatting and prevent common file issues

- `trailing-whitespace` - Removes trailing whitespace from files
- `end-of-file-fixer` - Ensures files end with a newline
- `mixed-line-ending` - Fixes mixed line endings (enforces LF)
- `check-case-conflict` - Detects files that would conflict on case-insensitive filesystems

**Why it matters:** Prevents unnecessary git diffs and compatibility issues across systems.

### 2. Syntax Validation

**Purpose:** Catch syntax errors before committing

- `check-yaml` - Validates YAML syntax (supports custom tags)
- `check-toml` - Validates TOML syntax
- `check-json` - Validates JSON syntax

**Why it matters:** Prevents broken config files from being committed.

### 3. Security Checks

**Purpose:** Prevent accidental commit of sensitive data

- `gitleaks` - Scans for hardcoded secrets, API keys, tokens
- `detect-private-key` - Finds accidentally committed SSH/GPG keys
- `verify-no-personal-info` - Custom check for your personal information
- `verify-git-filters-configured` - Ensures smudge/clean filters are set up

**Why it matters:** Protects credentials and personal information from being exposed in git history.

### 4. Code Quality

**Purpose:** Maintain high-quality shell scripts and configs

- `shellcheck` - Lint shell scripts for common errors and bad practices
- `bashate` - Check shell script style compliance
- `stylua` - Format Lua code (Neovim configs)
- `yamllint` - Lint YAML files for style and errors

**Why it matters:** Catches bugs early and maintains consistent code style.

### 5. Permission Checks

**Purpose:** Ensure scripts have correct permissions

- `check-executables-have-shebangs` - Ensures executable files have proper shebangs
- `check-shebang-scripts-are-executable` - Ensures files with shebangs are executable
- `check-shell-scripts-executable` - Custom check for scripts directory

**Why it matters:** Prevents "permission denied" errors when running scripts.

### 6. Size Checks

**Purpose:** Prevent accidentally committing large files

- `check-added-large-files` - Detects files larger than 1MB
- `check-merge-conflict` - Detects unresolved merge conflict markers

**Why it matters:** Keeps repository size manageable and prevents accidents.

### 7. Custom Dotfile Checks

**Purpose:** Enforce dotfile-specific best practices

- `check-common-mistakes` - Detects:
  - Bash sourcing in zsh configs
  - PATH overwrites (should use `path+=()`)

**Why it matters:** Prevents shell-specific compatibility issues.

## Configuration Files

### `.shellcheckrc`
Configures shellcheck to:
- Ignore SC1090/SC1091 (non-constant source paths)
- Ignore SC2148 (missing shebang for config files)
- Ignore SC2296 (zsh-specific syntax)

### `.yamllint`
Configures yamllint to:
- Allow 120 character lines
- Disable document-start requirement
- Allow common boolean values

### `.pre-commit-config.yaml`
Main configuration file with all hook definitions.

## Skipping Hooks

### Skip for a single commit
```bash
# Skip all hooks
git commit --no-verify

# Skip specific hook
SKIP=shellcheck git commit -m "message"

# Skip multiple hooks
SKIP=shellcheck,yamllint git commit -m "message"
```

### Skip permanently for a file
Add to `.pre-commit-config.yaml`:
```yaml
-   id: shellcheck
    exclude: ^path/to/file\.sh$
```

## Troubleshooting

### Hook fails with "file not executable"
```bash
chmod +x path/to/file.sh
```

### Hook reports false positive
1. Check if there's a configuration file (`.shellcheckrc`, `.yamllint`)
2. Add exceptions to the config
3. Or skip the hook for that file

### Hooks are slow
Pre-commit caches environments. First run is slow, subsequent runs are fast.

### Update hooks after config change
```bash
pre-commit clean
pre-commit install --install-hooks
```

### Manual hook execution
```bash
# Run on staged files
pre-commit run

# Run on all files
pre-commit run --all-files

# Run on specific files
pre-commit run --files file1 file2
```

## Best Practices

1. **Run hooks before pushing**: `pre-commit run --all-files`
2. **Update regularly**: `pre-commit autoupdate` monthly
3. **Don't skip security hooks**: Never skip gitleaks or personal info checks
4. **Fix warnings**: Don't just skip hooks, fix the underlying issues
5. **Test after updates**: Run on all files after updating hook versions

## Hook Scripts Location

Custom hook scripts are in `scripts/hooks/`:
- `verify-no-personal-info.sh` - Check for personal information
- `verify-git-filters.sh` - Verify git filters are configured
- `check-scripts-executable.sh` - Check script permissions
- `check-common-mistakes.sh` - Check for common dotfile mistakes

## Adding New Hooks

1. Browse available hooks: https://pre-commit.com/hooks.html
2. Add to `.pre-commit-config.yaml`:
```yaml
-   repo: https://github.com/username/repo
    rev: version
    hooks:
    -   id: hook-id
```
3. Install: `pre-commit install`
4. Test: `pre-commit run hook-id --all-files`

## Recommended Additions

Consider adding these hooks in the future:

- **markdownlint**: Lint markdown files
- **prettier**: Format JSON, YAML, Markdown
- **commitizen**: Enforce commit message format
- **detect-secrets**: Alternative to gitleaks
- **no-commit-to-branch**: Prevent commits to main/master

## Performance Tips

- Use `files:` or `exclude:` to limit hook scope
- Set `stages: [commit]` for commit-only hooks
- Use `pass_filenames: false` when appropriate
- Consider `minimum_pre_commit_version` for compatibility

## Resources

- [Pre-commit documentation](https://pre-commit.com/)
- [Shellcheck wiki](https://www.shellcheck.net/wiki/)
- [Yamllint docs](https://yamllint.readthedocs.io/)
- [StyLua docs](https://github.com/JohnnyMorganz/StyLua)
