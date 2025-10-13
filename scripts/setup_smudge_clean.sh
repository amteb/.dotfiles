#!/bin/sh

# Ensure scripts directory exists
mkdir -p scripts

# Create .gitattributes in the root directory if it doesn't exist
if [ ! -f .gitattributes ]; then
    echo "* filter=substitution" > .gitattributes
    echo "Created .gitattributes"
else
    echo ".gitattributes already exists"
fi

# Create clean script if it doesn't exist
if [ ! -f scripts/clean.sh ]; then
    cat > scripts/clean.sh << 'EOL'
#!/bin/bash

# Log to a file for debugging
if [ -n "$GIT_TRACE" ]; then
    echo "Clean filter running at $(date). Args: $@" >> /tmp/git_clean_filter.log
    env >> /tmp/git_clean_filter.log
    echo "---" >> /tmp/git_clean_filter.log
fi

# Replace actual values with placeholders for storage in git
sed -e "s|$HOME|%%HOME%%|g" \
    -e "s|$(git config user.name)|%%GIT_NAME%%|g" \
    -e "s|$(git config user.email)|%%GIT_EMAIL%%|g"
EOL
    chmod +x scripts/clean.sh
    echo "Created clean.sh"
else
    echo "clean.sh already exists"
fi

# Create smudge script if it doesn't exist
if [ ! -f scripts/smudge.sh ]; then
    cat > scripts/smudge.sh << 'EOL'
#!/bin/bash

# Check if GIT_TRACE is set (which happens in verbose mode)
if [ -n "$GIT_TRACE" ]; then
    echo "Smudge filter running on: ${1:-<no filename provided>}" >&2
fi

# Replace placeholders with actual values from environment
sed -e "s|%%HOME%%|$HOME|g" \
    -e "s|%%GIT_NAME%%|$(git config user.name)|g" \
    -e "s|%%GIT_EMAIL%%|$(git config user.email)|g"
EOL
    chmod +x scripts/smudge.sh
    echo "Created smudge.sh"
else
    echo "smudge.sh already exists"
fi

# Configure Git to use these scripts
git config --local filter.substitution.clean "scripts/clean.sh"
git config --local filter.substitution.smudge "scripts/smudge.sh"

echo "Smudge and clean filters have been set up successfully."
