#!/bin/bash

# Check if GIT_TRACE is set (which happens in verbose mode)
if [ -n "$GIT_TRACE" ]; then
    echo "Smudge filter running on: ${1:-<no filename provided>}" >&2
fi

sed -e "s|%%HOME%%|$HOME|g" \
    -e "s|%%GIT_NAME%%|$(git config user.name)|g" \
    -e "s|%%GIT_EMAIL%%|$(git config user.email)|g"
