#!/bin/bash
# Verify no personal information is accidentally committed
# Checks that git clean filters converted actual values to placeholders

# Files that should have substitution filter applied
filtered_files=(".zshrc" ".zshenv" ".zprofile" ".config/hatch/config.toml")

# Get actual personal values that should be filtered out
home_path="$HOME"
git_email=$(git config user.email 2>/dev/null)
git_name=$(git config user.name 2>/dev/null)

errors=()

for file in "${filtered_files[@]}"; do
    # Check if this file is staged
    if ! git diff --cached --name-only | grep -qx "$file"; then
        continue
    fi

    # Get staged content (what will actually be committed)
    content=$(git show ":$file" 2>/dev/null) || continue

    # Check for actual personal info that should have been filtered
    if [[ -n "$home_path" ]] && echo "$content" | grep -qF "$home_path"; then
        errors+=("$file: contains actual HOME path")
    fi
    if [[ -n "$git_email" ]] && echo "$content" | grep -qF "$git_email"; then
        errors+=("$file: contains actual git email")
    fi
    if [[ -n "$git_name" ]] && echo "$content" | grep -qF "$git_name"; then
        errors+=("$file: contains actual git name")
    fi
done

if [[ ${#errors[@]} -gt 0 ]]; then
    echo "ERROR: Found personal information in staged files:"
    printf '  %s\n' "${errors[@]}"
    echo ""
    echo "Git clean filters may not be configured. Run: ./scripts/setup_smudge_clean.sh"
    exit 1
fi

exit 0
