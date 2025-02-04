#!/bin/sh

sed -e "s|~|$HOME|g" \
    -e "s||$(git config user.name)|g" \
    -e "s||$(git config user.email)|g"
