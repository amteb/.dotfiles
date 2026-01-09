#!/usr/bin/env bash

# Script to generate a commit message using Claude API
# Falls back silently if Claude is not available

set -euo pipefail

# Source centralized colors
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/colors.sh"

MAX_CHARS=20000

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

# Get the git diff for context
DIFF=$(git diff --cached --stat)
DIFF_DETAIL=$(git diff --cached)
DIFF_LENGTH=${#DIFF_DETAIL}

# Check if diff is too large and prompt for confirmation
if [ "$DIFF_LENGTH" -gt "$MAX_CHARS" ]; then
    echo "Diff is large (${DIFF_LENGTH} chars). Send to Claude for commit message? [y/N] " >&2
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
    DIFF_TO_SEND="${DIFF_DETAIL:0:$MAX_CHARS}"
else
    DIFF_TO_SEND="$DIFF_DETAIL"
fi

# Create a prompt for Claude
PROMPT="Based on the following git diff, generate a concise commit message following conventional commits format (e.g., 'chore:', 'feat:', 'fix:').

Provide ONLY the commit message text, nothing else. No explanations, no markdown, no preamble.

Git diff stat:
${DIFF}

Git diff detail:
${DIFF_TO_SEND}"

echo -e "${BLUE}Generating commit message with Claude...${NC}" >&2

# Try to get commit message from Claude
COMMIT_MSG=$(claude -p "$PROMPT" 2>/dev/null | head -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Validate the commit message
if [ -z "$COMMIT_MSG" ]; then
    exit 1
fi

# Remove any markdown code blocks or quotes that Claude might add
# shellcheck disable=SC2016 # Backticks are literal, not command substitution
COMMIT_MSG=$(echo "$COMMIT_MSG" | sed 's/^`\+//;s/`\+$//;s/^"//;s/"$//')

# Output the commit message
echo "$COMMIT_MSG"
