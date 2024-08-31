#!/bin/bash

sed -e "s|$HOME|%%HOME%%|g" \
    -e "s|$(git config user.name)|%%GIT_NAME%%|g" \
    -e "s|$(git config user.email)|%%GIT_EMAIL%%|g"
