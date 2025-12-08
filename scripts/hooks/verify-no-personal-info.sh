#!/bin/bash
# Verify no personal information is accidentally committed

if git diff --cached --name-only | xargs grep -l "user@example.com\|~\|abraz@example" 2>/dev/null; then
    echo "ERROR: Found personal information in staged files. Make sure git filters are configured."
    exit 1
fi

exit 0
