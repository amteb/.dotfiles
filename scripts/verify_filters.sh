#!/bin/bash
# Verify the substitution filter is configured, round-trips, and that no
# personal value reached the stored (index) copy of a filtered file.

cd "$(git rev-parse --show-toplevel)" || exit 1
source scripts/colors.sh

GIT_NAME=$(git config user.name)
GIT_EMAIL=$(git config user.email)
status=0

fail() { echo -e "${RED}✗ $*${NC}"; status=1; }
pass() { echo -e "${GREEN}✓ $*${NC}"; }

if [ -z "$(git config --local filter.substitution.clean)" ] || [ -z "$(git config --local filter.substitution.smudge)" ]; then
    fail "Filters not configured. Run: ./scripts/setup_smudge_clean.sh"
    exit 1
fi
pass "Filters configured"

[ -n "$GIT_NAME" ] || fail "git user.name is empty; names will not be filtered"
[ -n "$GIT_EMAIL" ] || fail "git user.email is empty; emails will not be filtered"

input="$HOME/x $GIT_NAME $GIT_EMAIL"
cleaned=$(printf '%s\n' "$input" | scripts/clean.sh)
if [ "$cleaned" = "%%HOME%%/x %%GIT_NAME%% %%GIT_EMAIL%%" ]; then
    pass "Clean filter replaces HOME, name and email"
else
    fail "Clean filter output: $cleaned"
fi

if [ "$(printf '%s\n' "$cleaned" | scripts/smudge.sh)" = "$input" ]; then
    pass "Smudge filter restores the original"
else
    fail "Smudge filter does not round-trip"
fi

while read -r f; do
    stored=$(git show ":$f" 2>/dev/null) || continue
    for value in "$HOME" "$GIT_NAME" "$GIT_EMAIL"; do
        [ -n "$value" ] && grep -qF -- "$value" <<<"$stored" && fail "$f: stored copy contains a personal value"
    done
done < <(git ls-files | git check-attr --stdin filter | awk -F': ' '$3 == "substitution" {print $1}')

[ "$status" -eq 0 ] && pass "Stored copies are clean"
exit "$status"
