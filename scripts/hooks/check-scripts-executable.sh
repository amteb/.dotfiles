#!/bin/bash
# Check that shell scripts are executable

ERRORS=0

for file in "$@"; do
    if [[ "$file" == scripts/*.sh ]] && [[ ! -x "$file" ]]; then
        echo "ERROR: $file should be executable. Run: chmod +x $file"
        ERRORS=1
    fi
done

exit $ERRORS
