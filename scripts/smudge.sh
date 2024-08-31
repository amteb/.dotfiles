#!/bin/bash

sed -e "s|%%HOME%%|$HOME|g" \
    -e "s|%%GIT_NAME%%|$(git config user.name)|g" \
    -e "s|%%GIT_EMAIL%%|$(git config user.email)|g"
