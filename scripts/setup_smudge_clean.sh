#!/bin/bash

# Ensure scripts directory exists
mkdir -p scripts

# Create .gitattributes in the root directory
echo "* filter=substitution" > .gitattributes

# Create clean script
cat > scripts/clean.sh << EOL
#!/bin/bash

sed -e "s|\$HOME|%%HOME%%|g" \\
    -e "s|\$(git config user.name)|%%GIT_NAME%%|g" \\
    -e "s|\$(git config user.email)|%%GIT_EMAIL%%|g"
EOL

# Create smudge script
cat > scripts/smudge.sh << EOL
#!/bin/bash

sed -e "s|%%HOME%%|\$HOME|g" \\
    -e "s|%%GIT_NAME%%|\$(git config user.name)|g" \\
    -e "s|%%GIT_EMAIL%%|\$(git config user.email)|g"
EOL

# Make scripts executable
chmod +x scripts/clean.sh scripts/smudge.sh

# Configure Git to use these scripts
git config --local filter.substitution.clean "$(pwd)/scripts/clean.sh"
git config --local filter.substitution.smudge "$(pwd)/scripts/smudge.sh"

echo "Smudge and clean filters have been set up successfully."
