#!/bin/bash

# Log to a file for debugging
if [ -n "$GIT_TRACE" ]; then
    {
        echo "Clean filter running at $(date). Args: $*"
        env
        echo "---"
    } >> /tmp/git_clean_filter.log
fi

# Replace actual values with placeholders for storage in git
sed -e "s|$HOME|%%HOME%%|g" \
   -e "s|$(git config user.name)|%%GIT_NAME%%|g" \
    -e "s|$(git config user.email)|%%GIT_EMAIL%%|g"
