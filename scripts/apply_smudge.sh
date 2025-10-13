#!/bin/sh

# Ensure we're in the root of the git repository
cd "$(git rev-parse --show-toplevel)" || exit

# Ensure the smudge filter is set up
git config filter.substitution.smudge "scripts/smudge.sh"

# Remove all files from the index
git rm -r --cached .

# Re-add all files to the index
git add .

# Checkout all files, which will apply the smudge filter
git checkout -- .

echo "Smudge filter has been applied to all files in the repository."
