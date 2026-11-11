#!/bin/bash
# Git clean filter: replace this machine's HOME, git user.name and user.email
# with placeholders before content is stored in git.

escape_regex() { printf '%s' "$1" | sed 's/[][\.*^$|]/\\&/g'; }

args=(-e '')
for pair in "$HOME=%%HOME%%" "$(git config user.name)=%%GIT_NAME%%" "$(git config user.email)=%%GIT_EMAIL%%"; do
    value=${pair%=*}
    [ -n "$value" ] && args+=(-e "s|$(escape_regex "$value")|${pair##*=}|g")
done

exec sed "${args[@]}"
