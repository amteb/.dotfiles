#!/bin/bash

# Log to a file for debugging
if [ -n "$GIT_TRACE" ]; then
    echo "Clean filter running at $(date). Args: $@" >> /tmp/git_clean_filter.log
    env >> /tmp/git_clean_filter.log
    echo "---" >> /tmp/git_clean_filter.log
fi

sed -e "s|$HOME|~|g" \
    -e "s|$(git config user.name)|atbraz|g" \
    -e "s|$(git config user.email)|user@example.com|g"
