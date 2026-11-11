#!/bin/sh
# Register the substitution filter used by .gitattributes, then re-checkout
# the filtered files so they get this machine's values.
set -e
cd "$(git rev-parse --show-toplevel)"

git config --local filter.substitution.clean scripts/clean.sh
git config --local filter.substitution.smudge scripts/smudge.sh

for f in $(git ls-files); do
    if [ "$(git check-attr filter -- "$f" | cut -d' ' -f3)" = substitution ]; then
        rm -f "$f"
        git checkout -- "$f"
    fi
done

echo "Smudge and clean filters configured."
