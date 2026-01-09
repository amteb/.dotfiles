#!/bin/bash

# Dotfiles Health Check Script
# Checks the overall health of your dotfiles installation

set -e

# Source centralized colors
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/colors.sh"

echo -e "${BLUE}Dotfiles Health Check${NC}"
echo ""

ERRORS=0
WARNINGS=0

# 1. Check if dotfiles are stowed
echo -n "Checking if dotfiles are stowed... "
if [ -L "$HOME/.zshrc" ] && [ -L "$HOME/.zshenv" ]; then
    echo -e "${GREEN}✅ Dotfiles are stowed${NC}"
else
    echo -e "${RED}❌ Dotfiles not stowed${NC}"
    echo "   Run: cd ~/.dotfiles && stow ."
    ((ERRORS++))
fi

# 2. Check git filters
echo -n "Checking git filters... "
if ./scripts/verify_filters.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Git filters working${NC}"
else
    echo -e "${RED}❌ Git filters broken${NC}"
    echo "   Run: ./scripts/setup_smudge_clean.sh"
    ((ERRORS++))
fi

# 3. Check for repository updates
echo -n "Checking for updates... "
cd "$DOTFILES" 2>/dev/null || cd "$HOME/.dotfiles"
git fetch --quiet
BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
if [ "$BEHIND" -eq 0 ]; then
    echo -e "${GREEN}✅ Up to date${NC}"
else
    echo -e "${YELLOW}⚠️  $BEHIND commits behind${NC}"
    echo "   Run: git pull"
    ((WARNINGS++))
fi

# 4. Check for broken symlinks
echo -n "Checking for broken symlinks... "
BROKEN=$(find ~ -maxdepth 2 -xtype l 2>/dev/null | wc -l | tr -d ' ')
if [ "$BROKEN" -eq 0 ]; then
    echo -e "${GREEN}✅ No broken symlinks${NC}"
else
    echo -e "${YELLOW}⚠️  $BROKEN broken symlinks found${NC}"
    echo "   Run: make clean"
    ((WARNINGS++))
fi

# 5. Check if pre-commit is installed
echo -n "Checking pre-commit... "
if command -v pre-commit >/dev/null 2>&1; then
    if [ -d .git/hooks ] && grep -q "pre-commit" .git/hooks/pre-commit 2>/dev/null; then
        echo -e "${GREEN}✅ Pre-commit installed and configured${NC}"
    else
        echo -e "${YELLOW}⚠️  Pre-commit installed but not configured${NC}"
        echo "   Run: pre-commit install"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️  Pre-commit not installed${NC}"
    echo "   Run: uv tool install pre-commit"
    ((WARNINGS++))
fi

# 6. Check required tools
echo -n "Checking required tools... "
MISSING_TOOLS=()
for tool in git stow zsh; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All required tools installed${NC}"
else
    echo -e "${RED}❌ Missing tools: ${MISSING_TOOLS[*]}${NC}"
    echo "   Run: ./scripts/setup.sh"
    ((ERRORS++))
fi

# 7. Check shell
echo -n "Checking default shell... "
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
    echo -e "${GREEN}✅ Using zsh${NC}"
else
    echo -e "${YELLOW}⚠️  Current shell is $CURRENT_SHELL${NC}"
    echo "   Run: chsh -s \$(which zsh)"
    ((WARNINGS++))
fi

# 8. Check for uncommitted changes
echo -n "Checking for uncommitted changes... "
if git diff --quiet && git diff --cached --quiet; then
    echo -e "${GREEN}✅ No uncommitted changes${NC}"
else
    echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
    echo "   Run: git status"
    ((WARNINGS++))
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Your dotfiles are healthy.${NC}"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warning(s). Consider addressing them.${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS error(s) found. Please fix them.${NC}"
    [ "$WARNINGS" -gt 0 ] && echo -e "${YELLOW}⚠️  Also $WARNINGS warning(s).${NC}"
    exit 1
fi
