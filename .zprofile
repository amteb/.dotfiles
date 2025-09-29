# Login shell specific settings

# Set umask
umask 022

# Load Homebrew in login shells (if installed)
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS Homebrew
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  # Linux Homebrew
  if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# Source cargo env if it exists
[[ -f "$HOME/.cargo/env" ]] && 
# Initialize keychain
# SSH Agent Management
SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "Initializing new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# Initialize keychain
if command -v keychain > /dev/null 2>&1; then
    eval `keychain --eval --agents ssh --inherit any id_ed25519 -q`
fi

# Initialize starship prompt
if command -v starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Initialize zoxide
if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
