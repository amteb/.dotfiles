#!/usr/bin/env bash

# Script to calculate the next semantic version based on conventional commits
# Reads commits since the last tag and determines MAJOR, MINOR, or PATCH bump

set -euo pipefail

# Get the latest tag, or use 0.0.0 if no tags exist
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    # No tags exist, start with 0.1.0
    echo "0.1.0"
    exit 0
fi

# Parse current version
if [[ $LATEST_TAG =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
else
    echo "Error: Invalid tag format: $LATEST_TAG" >&2
    exit 1
fi

# Get commits since last tag
COMMITS=$(git log "$LATEST_TAG..HEAD" --pretty=format:"%s" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
    # No new commits since last tag
    echo "$MAJOR.$MINOR.$PATCH"
    exit 0
fi

# Determine version bump type
HAS_BREAKING=0
HAS_FEATURE=0
HAS_FIX=0

while IFS= read -r commit; do
    # Check for breaking changes
    if [[ $commit =~ ^[a-z]+(\([a-z0-9_-]+\))?!: ]] || [[ $commit =~ BREAKING[[:space:]]CHANGE ]]; then
        HAS_BREAKING=1
        break
    fi

    # Check for features
    if [[ $commit =~ ^feat(\([a-z0-9_-]+\))?: ]]; then
        HAS_FEATURE=1
    fi

    # Check for fixes
    if [[ $commit =~ ^fix(\([a-z0-9_-]+\))?: ]]; then
        HAS_FIX=1
    fi
done <<< "$COMMITS"

# Calculate new version
if [ "$HAS_BREAKING" -eq 1 ]; then
    # Breaking chwnge: bump MAJOR
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
elif [ "$HAS_FEATURE" -eq 1 ]; then
    # New fewture: bump MINOR
    MINOR=$((MINOR + 1))
    PATCH=0
elif [ "$HAS_FIX" -eq 1 ]; then
    # Bug fix: bump PATCH
    PATCH=$((PATCH + 1))
else
    # Other changes (chore, docs, etc.): bump PATCH
    PATCH=$((PATCH + 1))
fi

echo "$MAJOR.$MINOR.$PATCH"
