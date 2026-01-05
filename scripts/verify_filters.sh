#!/bin/bash

# Verify that git smudge/clean filters are working correctly
# This script checks that personal information is being filtered out

echo "=== Git Filter Verification Script ==="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if filters are configured
echo "1. Checking if git filters are configured..."
CLEAN_FILTER=$(git config --local filter.substitution.clean)
SMUDGE_FILTER=$(git config --local filter.substitution.smudge)

if [ -z "$CLEAN_FILTER" ] || [ -z "$SMUDGE_FILTER" ]; then
    echo -e "${RED}✗ Filters not configured!${NC}"
    echo "  Run: ./scripts/setup_smudge_clean.sh"
    exit 1
else
    echo -e "${GREEN}✓ Filters are configured${NC}"
    echo "  Clean:  $CLEAN_FILTER"
    echo "  Smudge: $SMUDGE_FILTER"
fi

echo ""
echo "2. Testing filter scripts..."

# Test clean filter
TEST_INPUT="$HOME/test path $(git config user.name) $(git config user.email)"
CLEAN_OUTPUT=$(echo "$TEST_INPUT" | ./scripts/clean.sh)

if [[ "$CLEAN_OUTPUT" == *"%%HOME%%"* ]] && [[ "$CLEAN_OUTPUT" == *"%%GIT_NAME%%"* ]] && [[ "$CLEAN_OUTPUT" == *"%%GIT_EMAIL%%"* ]]; then
    echo -e "${GREEN}✓ Clean filter working${NC}"
    echo "  Input:  $TEST_INPUT"
    echo "  Output: $CLEAN_OUTPUT"
else
    echo -e "${RED}✗ Clean filter not working properly${NC}"
    echo "  Input:  $TEST_INPUT"
    echo "  Output: $CLEAN_OUTPUT"
    exit 1
fi

# Test smudge filter
TEST_INPUT="%%HOME%%/test path %%GIT_NAME%% %%GIT_EMAIL%%"
SMUDGE_OUTPUT=$(echo "$TEST_INPUT" | ./scripts/smudge.sh)

if [[ "$SMUDGE_OUTPUT" == *"$HOME"* ]] && [[ "$SMUDGE_OUTPUT" == *"$(git config user.name)"* ]] && [[ "$SMUDGE_OUTPUT" == *"$(git config user.email)"* ]]; then
    echo -e "${GREEN}✓ Smudge filter working${NC}"
    echo "  Input:  $TEST_INPUT"
    echo "  Output: $SMUDGE_OUTPUT"
else
    echo -e "${RED}✗ Smudge filter not working properly${NC}"
    echo "  Input:  $TEST_INPUT"
    echo "  Output: $SMUDGE_OUTPUT"
    exit 1
fi

echo ""
echo "3. Checking what will be committed to git..."

# Get current git user info
GIT_NAME=$(git config user.name)
GIT_EMAIL=$(git config user.email)

# Stage all changes temporarily
git add -A > /dev/null 2>&1

# Search for personal information patterns
if git diff --cached | grep -q "$HOME" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Found $HOME in staged changes${NC}"
fi

if git diff --cached | grep -q "$GIT_NAME" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Found git name '$GIT_NAME' in staged changes${NC}"
fi

if git diff --cached | grep -q "$GIT_EMAIL" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Found git email '$GIT_EMAIL' in staged changes${NC}"
fi

# Check that placeholders exist in what will be stored
PLACEHOLDERS_FOUND=0
if git diff --cached --diff-filter=AM | grep -q "%%HOME%%" 2>/dev/null; then
    ((PLACEHOLDERS_FOUND++))
fi
if git diff --cached --diff-filter=AM | grep -q "%%GIT_NAME%%" 2>/dev/null; then
    ((PLACEHOLDERS_FOUND++))
fi
if git diff --cached --diff-filter=AM | grep -q "%%GIT_EMAIL%%" 2>/dev/null; then
    ((PLACEHOLDERS_FOUND++))
fi

# Unstage changes
git reset > /dev/null 2>&1

if [ "$PLACEHOLDERS_FOUND" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $PLACEHOLDERS_FOUND placeholder(s) in files that will be stored in git${NC}"
else
    echo -e "${YELLOW}⚠ No placeholders found (this is ok if you're not changing files with personal info)${NC}"
fi

echo ""
echo "4. Checking for common personal info patterns in repo..."

# Check if any files in the repo contain personal information
FILES_WITH_ISSUES=()

if grep -r "$GIT_EMAIL" --exclude-dir=.git --exclude="verify_filters.sh" . 2>/dev/null | grep -v "%%GIT_EMAIL%%" > /dev/null; then
    FILES_WITH_ISSUES+=("$GIT_EMAIL")
fi

if [ ${#FILES_WITH_ISSUES[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found personal information in working directory:${NC}"
    for info in "${FILES_WITH_ISSUES[@]}"; do
        echo "  - $info"
    done
    echo "  This is expected in the working directory (smudge filter applies them)"
    exit 1
else
    echo -e "${GREEN}✓ No hardcoded personal information found${NC}"
    exit 0
fi
