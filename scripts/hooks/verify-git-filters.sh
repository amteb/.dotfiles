#!/bin/bash
# Verify git smudge/clean filters are configured

CLEAN_FILTER=$(git config --local filter.substitution.clean)
SMUDGE_FILTER=$(git config --local filter.substitution.smudge)

if [ -z "$CLEAN_FILTER" ] || [ -z "$SMUDGE_FILTER" ]; then
    echo "ERROR: Git smudge/clean filters not configured."
    echo "Run: ./scripts/setup_smudge_clean.sh"
    exit 1
fi

exit 0
