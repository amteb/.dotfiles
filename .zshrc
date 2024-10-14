# ~/.zshrc: executed by zsh for interactive shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# Zsh options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB
unsetopt CORRECT
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# Completion system
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle :compinstall filename '%%HOME%%/.zshrc'
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# History completion configuration
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Functions

## install and stow
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

    eval "$cmd"
    if [ $? -ne 0 ]; then
        echo "Installation command failed: $cmd"
        return 1
    fi

    SETUP_SCRIPT="$DOTFILES/scripts/setup.sh"

    if grep -Fxq "$cmd" "$SETUP_SCRIPT"; then
        echo "Command already exists in setup.sh: $cmd"
    else
        echo "\n$cmd" >> "$SETUP_SCRIPT"

        qpushd "$DOTFILES"
        git add $SETUP_SCRIPT

        if ! git diff --cached --quiet; then
            git commit -m "feat: add new installation command: $cmd"
            git push

            echo "Installation command logged and dotfiles repo synced."
        else
            echo "No changes to commit."
        fi

        qpopd
    fi
}

function sto() {
    install_and_add_to_stow_setup "$@"
}

function restow() {
    qpushd "$DOTFILES"

    stow .
    git add .

    if ! git diff --cached --quiet; then
      git commit -m "chore: update dotfiles"
      git push
      echo "Synced .dotfiles repo"
    else
      echo "No changes to commit"
    fi

    qpopd
}

function gas(){
    $DOTFILES/scripts/git-autosync "$@"
}

## utility functions
function l {
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

# Aliases
alias clip="clip.exe"
alias code="code-insiders"
alias c.="code-insiders ."
alias v="nvim"
alias v.="nvim ."
alias sva="source .venv/bin/activate"
alias sz="source $HOME/.zshrc"
alias sp="source $HOME/.zprofile"
alias cat="bat"
alias z.="z .."
alias z-="z -"
alias c="code-insiders"
alias f="fd"
alias g="git"
alias t="tmux"
alias ta="tmux attach"
alias tl="tmux list-sessions"
alias tm="tmux new-session -s main"
alias tf="$DOTFILES/scripts/tmux-sessionizer"

# Named directories
hash -d dot="$HOME/.dotfiles"
hash -d projects="$HOME/projects"
hash -d downloads="$HOME/Downloads"

# Antidote plugin management
zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt
fpath=(${ZDOTDIR:-$HOME}/.antidote/functions $fpath)
autoload -Uz antidote
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
  autoload -Uz compinit
  compinit
  )
  (
    source ".antidote/antidote.zsh"
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi
source ${zsh_plugins}.zsh

# Load any local configurations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

function check_ssh_agent() {
  ssh-add -l &>/dev/null
  if [ 0 = 2 ]; then
    echo No ssh-agent running
  elif [ 0 = 1 ]; then
    echo ssh-agent has no identities
  else
    echo ssh-agent has at least one identity
  fi
  echo SSH_AUTH_SOCK=/tmp/ssh-nn2x11zHDkIj/agent.75973
}

. "$HOME/.cargo/env"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '%%HOME%%/.opam/opam-init/init.zsh' ]] || source '%%HOME%%/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
