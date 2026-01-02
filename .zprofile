# ~/.zprofile
#
# Sourced for LOGIN shells only (after .zshenv, before .zshrc)
# Login shells are typically created when you first log in to your system.
#
# What should go here:
#   - Commands that should run once per login session
#   - Setting up PATH additions from tools (Homebrew, cargo, etc.)
#   - SSH agent initialization
#   - System-specific login configurations
#   - One-time startup tasks (key management, etc.)
#
# What should NOT go here:
#   - Interactive shell features (those go in .zshrc)
#   - Environment variables (those go in .zshenv)
#   - Things that should run for every new shell
#
# Note: This runs once per login, not for every terminal window.

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

# Load any local configurations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Source cargo env if it exists
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# opam configuration
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2>&1

[[ -f "$HOME/.local/share/../bin/env" ]] && . "$HOME/.local/share/../bin/env"

# SSH Agent Management
# Ensures a single SSH agent runs across all sessions and persists between logins
SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "Initializing new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}

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
