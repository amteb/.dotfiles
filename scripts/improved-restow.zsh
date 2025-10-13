# Improved restow function with safety checks
# To use: source this file in .zshrc or copy the function

function restow() {
    local original_dir="$(pwd)"
    local dotfiles_dir="${DOTFILES:-$HOME/.dotfiles}"

    # Check if we're in the dotfiles directory
    if [[ "$(pwd)" != "$dotfiles_dir" ]]; then
        cd "$dotfiles_dir" || {
            echo "Error: Cannot access $dotfiles_dir"
            return 1
        }
    fi

    echo "🔄 Restowing dotfiles..."

    # Run pre-commit checks first (if available)
    if command -v pre-commit >/dev/null 2>&1 && [ -f .pre-commit-config.yaml ]; then
        echo "Running pre-commit checks..."
        if ! pre-commit run --all-files 2>&1 | tail -20; then
            echo ""
            echo "❌ Pre-commit checks failed. Fix issues before restowing."
            echo "Or skip with: SKIP_CHECKS=1 restow"
            [[ "$original_dir" != "$dotfiles_dir" ]] && cd "$original_dir"
            return 1
        fi
    fi

    # Dry run stow first to check for conflicts
    echo ""
    echo "Checking for stow conflicts..."
    local stow_output
    stow_output=$(stow --no-folding --simulate . 2>&1)

    if echo "$stow_output" | grep -qi "warning\|error"; then
        echo "⚠️  Stow simulation found issues:"
        echo "$stow_output"
        echo ""
        echo -n "Continue anyway? [y/N]: "
        read should_continue
        if [[ ! "$should_continue" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            [[ "$original_dir" != "$dotfiles_dir" ]] && cd "$original_dir"
            return 1
        fi
    fi

    # Actually stow
    if stow --no-folding . 2>&1; then
        echo "✅ Dotfiles restowed successfully"
    else
        echo "❌ Stow failed"
        [[ "$original_dir" != "$dotfiles_dir" ]] && cd "$original_dir"
        return 1
    fi

    # Git operations
    echo ""
    echo "Checking git status..."
    git add .

    if git diff --cached --quiet; then
        echo "✅ No changes to commit"
        [[ "$original_dir" != "$dotfiles_dir" ]] && cd "$original_dir"
        return 0
    fi

    # Show changes
    echo ""
    echo "📝 Changes to be committed:"
    git diff --cached --stat --color
    echo ""

    # Get commit message
    echo -n "Commit message (or 'skip' to abort, Enter for default): "
    read commit_msg

    if [[ "$commit_msg" == "skip" ]]; then
        echo "Skipping commit. Changes are staged."
        git reset > /dev/null
        [[ "$original_dir" != "$dotfiles_dir" ]] && cd "$original_dir"
        return 0
    fi

    # Commit
    git commit -m "${commit_msg:-chore: update dotfiles}" || {
        echo "❌ Commit failed"
        [[ "$original_dir" != "$dotfiles_dir" ]] && cd "$original_dir"
        return 1
    }

    # Ask about pushing
    echo ""
    echo -n "Push to remote? [Y/n]: "
    read should_push

    if [[ "$should_push" =~ ^[Nn]$ ]]; then
        echo "✅ Changes committed locally (not pushed)"
    else
        if git push; then
            echo "✅ Changes committed and pushed"
        else
            echo "❌ Push failed. Changes are committed locally."
            echo "Run 'git push' manually when ready."
        fi
    fi

    # Return to original directory
    [[ "$original_dir" != "$dotfiles_dir" ]] && cd "$original_dir"
}

# Quick restow without prompts (for automation)
function restow-auto() {
    local dotfiles_dir="${DOTFILES:-$HOME/.dotfiles}"
    cd "$dotfiles_dir"
    stow --no-folding .
    git add .
    if ! git diff --cached --quiet; then
        git commit -m "chore: update dotfiles"
        git push
    fi
    cd -
}

# Restow and show what changed
function restow-diff() {
    local dotfiles_dir="${DOTFILES:-$HOME/.dotfiles}"
    cd "$dotfiles_dir"
    git diff
    echo ""
    echo -n "Continue with restow? [y/N]: "
    read should_continue
    if [[ "$should_continue" =~ ^[Yy]$ ]]; then
        restow
    fi
    cd -
}
