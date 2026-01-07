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
if [ ${#FULL_DIFF} -gt "$MAX_DIFF_CHARS" ]; then
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

# Check if .pre-commit-config.yaml is in the staged changes
PRECOMMIT_CONFIG_MODIFIED=0
if git diff --cached --name-only | grep -q "^\.pre-commit-config\.yaml$"; then
    PRECOMMIT_CONFIG_MODIFIED=1
fi

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
            git add --all "$file" 2>/dev/null || {
                echo "Warning: Could not stage $file" >&2
            }
        fi
    done

    # If this is the first commit and .pre-commit-config.yaml was modified,
    # include it to satisfy pre-commit's safety check
    if [ "$i" -eq 0 ] && [ "$PRECOMMIT_CONFIG_MODIFIED" -eq 1 ]; then
        if ! echo "$FILES" | grep -q "^\.pre-commit-config\.yaml$"; then
            git add .pre-commit-config.yaml 2>/dev/null || true
        fi
    fi

    # Check if anything was staged
    if git diff --cached --quiet; then
        echo "Warning: No changes staged for commit: $MESSAGE" >&2
        continue
    fi

    # Remember which files are staged for this commit
    STAGED_FILES=$(git diff --cached --name-only)

    # Create the commit
    echo -e "  ${GREEN}[$((i + 1))/$NUM_COMMITS]${NC} $MESSAGE" >&2

    # Try to commit, handling pre-commit hooks that may modify files multiple times
    MAX_RETRIES=3
    RETRY_COUNT=0
    COMMIT_SUCCESS=0

    while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
        if git commit -m "$MESSAGE" --quiet >/dev/null 2>&1; then
            COMMIT_SUCCESS=1
            break
        fi

        # Check if there are unstaged changes (likely from pre-commit hooks auto-fixing files)
        if ! git diff --quiet 2>/dev/null; then
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; then
                echo -e "  ${YELLOW}Pre-commit hooks modified files, re-staging (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)...${NC}" >&2
                # Re-stage only the files that were part of this commit
                while IFS= read -r file; do
                    if [ -n "$file" ]; then
                        git add "$file" 2>/dev/null || true
                    fi
                done <<< "$STAGED_FILES"
            fi
        else
            # No unstaged changes means hooks failed for a different reason
            echo "Error: Pre-commit hooks failed for: $MESSAGE" >&2
            echo "Run 'pre-commit run --all-files' to see details" >&2
            exit 1
        fi
    done

    if [ "$COMMIT_SUCCESS" -eq 0 ]; then
        echo "Error: Failed to create commit after $MAX_RETRIES attempts: $MESSAGE" >&2
        echo "Pre-commit hooks may be making repeated modifications" >&2
        exit 1
    fi
done

# Verify all originally staged changes were committed
if ! git diff --cached --quiet; then
    echo "Warning: Some staged changes were not committed" >&2
    exit 1
fi

echo -e "${GREEN}Successfully created $NUM_COMMITS commit(s)${NC}" >&2
exit 0
