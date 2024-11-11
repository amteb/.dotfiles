#!/bin/bash

# Log to a file for debugging
if [ -n "$GIT_TRACE" ]; then
    echo "Clean filter running at $(date). Args: $@" >> /tmp/git_clean_filter.log
    env >> /tmp/git_clean_filter.log
    echo "---" >> /tmp/git_clean_filter.log
fi

# If the file is .gitconfig.dotfiles, don't apply any substitutions
if [[ "${1}" == *".gitconfig.dotfiles" ]]; then
    cat
else
    sed -e "s|$HOME|%%HOME%%|g" \
        -e "s|$(git config user.name)||g" \
        -e "s|$(git config user.email)||g"
fi
