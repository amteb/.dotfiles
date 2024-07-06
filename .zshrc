#plugins

# aliases
alias clip='clip.exe'
alias code='code-insiders'
alias v='nvim'

# functions
l (){
  eza \
    -a \
    -l \
    -F \
    -@ \
    --git \
    --git-repos \
    --group-directories-first \
    --header \
    --icons=always \
    --no-quotes \
    --time-style=relative \
    "$@"
}


# install and stow

qpushd() {
  pushd "$1" > /dev/null
}

qpopd() {
  popd > /dev/null
}

function install_and_add_to_stow_setup() {
    local cmd="$*"

    if [ -z "$cmd" ]; then
        echo "No command provided."
        return 1
    fi

    # Path to your setup.sh script
    SETUP_SCRIPT="$HOME/.dotfiles/setup.sh"

    # Check if the command is already in setup.sh
    if grep -Fxq "$cmd" "$SETUP_SCRIPT"; then
        echo "Command already exists in setup.sh: $cmd"
    else
        # Log the command to setup.sh
        echo "$cmd" >> "$SETUP_SCRIPT"

        # Execute the command
        eval "$cmd"
        if [ $? -ne 0 ]; then
            echo "Installation command failed: $cmd"
            return 1
        fi

        # Change to the dotfiles directory
        DOTFILES_DIR="$HOME/.dotfiles"
        qpushd "$DOTFILES_DIR"

        # Commit and push the changes
        git add setup.sh
        git commit -m "Added new installation command: $cmd"
        git push

        echo "Installation command logged and dotfiles repo synced."
        qpopd
    fi
}

function sto() {
    install_and_add_to_stow_setup "$@"
}

function restow() {
    qpushd "$HOME/.dotfiles"

    stow .
    git add .
    
    if ! git diff --cached --quiet; then
      git commit -m "Updated dotfiles"
      git push
      echo "Synced .dotfiles repo"
    else
      echo "No changes to commit"
    fi

    qpopd
}

function szsh() {
  source "$HOME/.zshrc"
  echo "Sourced .zshrc"
}

function szp() {
  source "$HOME/.zprofile"
  echo "Sourced .zprofile"
}

# sources
if [ -f "$HOME/.zprofile" ] ; then
  source "$HOME/.zprofile"
elif [ -f "$HOME/.profile" ] ; then
  source "$HOME/.profile"
fi

# keychain configuration
eval `keychain --eval --agents ssh id_ed25519`

# evals

if command -v atuin > /dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if command -v starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
