#!/usr/bin/env bash
# Quick theme validation script

theme_file="$1"

if [[ ! -f "$theme_file" ]]; then
    echo "Usage: $0 <theme-file>"
    exit 1
fi

required_vars=(
    "@text_main"
    "@text_selected"
    "@text_unselected"
    "@text_unselected_recent"
    "@text_active"
    "@text_secondary"
    "@text_tertiary"
    "@text_accent"
    "@text_sync"
    "@border_active"
    "@border_inactive"
    "@bg_visual"
)

echo "Validating theme: $theme_file"
echo ""

missing=0
for var in "${required_vars[@]}"; do
    if ! grep -q "set -g $var" "$theme_file"; then
        echo "❌ Missing: $var"
        ((missing++))
    else
        echo "✅ Found: $var"
    fi
done

echo ""
if [[ $missing -eq 0 ]]; then
    echo "✅ Theme is valid! All required variables defined."
    exit 0
else
    echo "❌ Theme is incomplete. Missing $missing variable(s)."
    exit 1
fi
