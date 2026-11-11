#!/bin/bash
# Git smudge filter: replace placeholders with this machine's HOME,
# git user.name and user.email on checkout.

escape_replacement() { printf '%s' "$1" | sed 's/[&|\\]/\\&/g'; }

exec sed \
    -e "s|%%HOME%%|$(escape_replacement "$HOME")|g" \
    -e "s|%%GIT_NAME%%|$(escape_replacement "$(git config user.name)")|g" \
    -e "s|%%GIT_EMAIL%%|$(escape_replacement "$(git config user.email)")|g"
