#!/bin/bash
# Check for common dotfile mistakes

ERRORS=0

# Check for bash sourcing in zsh configs
if git diff --cached --name-only | xargs grep -l "source.*\.bash" 2>/dev/null; then
    echo "WARNING: Found .bash sourcing in dotfiles (should use zsh)"
    ERRORS=1
fi

# Check for PATH overwrites
if git diff --cached | grep -q "export PATH=.*:" 2>/dev/null; then
    echo "WARNING: PATH should be appended, not overwritten (use path+= or add to array)"
fi

exit $ERRORS
