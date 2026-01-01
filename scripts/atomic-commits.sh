#!/usr/bin/env bash

# Script to create atomic, thematic commits using Claude
# Analyzes staged changes and groups them into logical commits

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if claude command is available
if ! command -v claude &>/dev/null; then
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir &>/dev/null 2>&1; then
    echo "Error: Not in a git repository" >&2
    exit 1
fi

# Check if there are staged changes
if git diff --cached --quiet; then
    echo "Error: No staged changes to commit" >&2
    exit 1
fi

# Get list of changed files and their diffs
CHANGED_FILES=$(git diff --cached --name-only)
DIFF_STAT=$(git diff --cached --stat)
FULL_DIFF=$(git diff --cached)

# Limit full diff to reasonable size
MAX_DIFF_CHARS=30000
if [ ${#FULL_DIFF} -gt $MAX_DIFF_CHARS ]; then
    FULL_DIFF="${FULL_DIFF:0:$MAX_DIFF_CHARS}

... (diff truncated for length)"
fi

echo -e "${BLUE}Analyzing changes...${NC}" >&2

# Create prompt for Claude
PROMPT="You are analyzing git changes to suggest atomic, thematic commits following Conventional Commits format.

Changed files:
${CHANGED_FILES}

Diff stat:
${DIFF_STAT}

Full diff:
${FULL_DIFF}

Analyze these changes and group them into atomic, thematic commits. Each commit should represent a single logical change.

Return ONLY a JSON array with no markdown, no explanation, no preamble. Format:
[
  {
    \"files\": [\"file1\", \"file2\"],
    \"message\": \"feat: add feature description\"
  },
  {
    \"files\": [\"file3\"],
    \"message\": \"chore: update configuration\"
  }
]

Rules:
1. Use conventional commit prefixes (feat, fix, chore, refactor, docs, style, test)
2. Each commit should be focused and atomic
3. Group related changes together
4. Keep commit messages concise (50-72 chars)
5. ALL files must be included in exactly one commit
6. Return valid JSON only, no other text"

echo -e "${BLUE}Waiting for Claude to analyze diff...${NC}" >&2

# Get Claude's response
RESPONSE=$(claude -p "$PROMPT" 2>/dev/null || echo "")

# Check if we got a response
if [ -z "$RESPONSE" ]; then
    echo "Error: No response from Claude" >&2
    exit 1
fi

# Clean up response - remove markdown code blocks if present
RESPONSE=$(echo "$RESPONSE" | sed -e 's/^```json//' -e 's/^```//' -e 's/```$//' | grep -v '^```' | jq -c '.' 2>/dev/null || echo "")

if [ -z "$RESPONSE" ] || [ "$RESPONSE" = "null" ]; then
    echo "Error: Invalid JSON response from Claude" >&2
    exit 1
fi

# Validate JSON structure
if ! echo "$RESPONSE" | jq -e 'type == "array"' >/dev/null 2>&1; then
    echo "Error: Response is not a JSON array" >&2
    exit 1
fi

# Get number of commits
NUM_COMMITS=$(echo "$RESPONSE" | jq 'length')

if [ "$NUM_COMMITS" -eq 0 ]; then
    echo "Error: No commits suggested" >&2
    exit 1
fi

echo -e "${GREEN}Creating $NUM_COMMITS commit(s)...${NC}" >&2

# Unstage all changes first
git reset HEAD --quiet

# Process each commit group
for i in $(seq 0 $((NUM_COMMITS - 1))); do
    FILES=$(echo "$RESPONSE" | jq -r ".[$i].files[]")
    MESSAGE=$(echo "$RESPONSE" | jq -r ".[$i].message")

    if [ -z "$FILES" ] || [ -z "$MESSAGE" ] || [ "$MESSAGE" = "null" ]; then
        echo "Error: Invalid commit group at index $i" >&2
        # Re-stage all changes before failing
        git add .
        exit 1
    fi

    # Stage files for this commit
    echo "$FILES" | while read -r file; do
        if [ -n "$file" ]; then
            git add "$file" 2>/dev/null || {
                echo "Warning: Could not stage $file" >&2
            }
        fi
    done

    # Check if anything was staged
    if git diff --cached --quiet; then
        echo "Warning: No changes staged for commit: $MESSAGE" >&2
        continue
    fi

    # Create the commit
    echo -e "  ${GREEN}[$((i + 1))/$NUM_COMMITS]${NC} $MESSAGE" >&2
    git commit -m "$MESSAGE" --quiet || {
        echo "Error: Failed to create commit: $MESSAGE" >&2
        exit 1
    }
done

# Verify all originally staged changes were committed
if ! git diff --cached --quiet; then
    echo "Warning: Some staged changes were not committed" >&2
    exit 1
fi

echo -e "${GREEN}Successfully created $NUM_COMMITS commit(s)${NC}" >&2
exit 0
