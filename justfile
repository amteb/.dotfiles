# List available commands
default:
    @just --list

# Run setup.sh and stow dotfiles
install:
    @echo "Installing dotfiles..."
    ./scripts/setup.sh
    stow --no-folding .

# Update dependencies and pre-commit hooks
update:
    @echo "Updating dependencies..."
    @if command -v brew >/dev/null 2>&1; then brew upgrade; fi
    @if command -v pre-commit >/dev/null 2>&1; then pre-commit autoupdate; fi
    @echo "Update complete!"

# Stow and sync dotfiles to git
sync:
    @echo "Syncing dotfiles..."
    @stow --no-folding .
    @git add .
    @if ! git diff --cached --quiet; then \
        git status --short; \
        echo ""; \
        read -p "Commit message (or press Enter for default): " msg; \
        git commit -m "$${msg:-chore: update dotfiles}"; \
        read -p "Push to remote? [y/N]: " push; \
        if [ "$$push" = "y" ] || [ "$$push" = "Y" ]; then git push; fi; \
    else \
        echo "No changes to sync"; \
    fi

# Run all validation checks
test:
    @echo "Running test suite..."
    @if [ -f scripts/test.sh ]; then \
        ./scripts/test.sh; \
    else \
        echo "Running basic tests..."; \
        ./scripts/verify_filters.sh; \
        pre-commit run --all-files; \
        stow --simulate --no-folding .; \
    fi

# Verify git filters are working
verify:
    @./scripts/verify_filters.sh

# Check dotfiles health
health:
    @if [ -f scripts/health.sh ]; then \
        ./scripts/health.sh; \
    else \
        echo "Health check script not yet implemented"; \
        echo "Run: just test"; \
    fi

# Remove broken symlinks from home directory
clean:
    @echo "Finding broken symlinks in home directory..."
    @find ~ -maxdepth 2 -xtype l 2>/dev/null || echo "No broken symlinks found"
    @read -p "Remove broken symlinks? [y/N]: " confirm; \
    if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
        find ~ -maxdepth 2 -xtype l -delete 2>/dev/null; \
        echo "Broken symlinks removed"; \
    fi
