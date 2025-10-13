# ~/.zshrc
#
# Sourced for INTERACTIVE shells only (after .zshenv and .zprofile if login shell)
# This runs every time you open a new terminal window or tab.
#
# What should go here:
#   - Aliases and shell functions
#   - Key bindings and command line editing
#   - Prompt configuration (starship, etc.)
#   - Completion system setup
#   - History settings
#   - Interactive shell options (AUTO_CD, AUTO_PUSHD, etc.)
#   - Tool initialization for interactive use (zoxide, fzf, etc.)
#
# What should NOT go here:
#   - Environment variables (use .zshenv)
#   - One-time login tasks (use .zprofile)
#   - Anything that produces output in non-interactive mode
#
# Note: This file should enhance the interactive shell experience.

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

bindkey -e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Completion system
fpath=(~/.dotfiles/.zsh/completions $fpath)
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle :compinstall filename "$HOME/.zshrc"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# History completion configuration
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Functions

## Helper functions
qpushd() {
    pushd "$1" >/dev/null
}

qpopd() {
    popd >/dev/null
}

# Helper to commit and push changes if there are any staged changes
# Usage: _git_commit_and_push "commit message" "optional success message"
_git_commit_and_push() {
    local commit_message="$1"
    local success_message="${2:-Changes synced successfully}"

    if ! git diff --cached --quiet; then
        git commit -m "$commit_message"
        git push
        echo "$success_message"
        return 0
    else
        echo "No changes to commit"
        return 1
    fi
}

# Helper to conditionally initialize shell tools
# Only runs initialization if the tool is installed
# Usage: _init_shell_tool "tool_name" "initialization_command"
_init_shell_tool() {
    local tool="$1"
    local init_cmd="$2"

    if command -v "$tool" > /dev/null 2>&1; then
        eval "$init_cmd"
    fi
}

## Dotfiles management functions

# Executes an installation command and logs it to setup.sh for reproducibility
# If the command succeeds and isn't already logged, commits and pushes to dotfiles repo
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
        echo "\n$cmd" >>"$SETUP_SCRIPT"

        qpushd "$DOTFILES"
        git add $SETUP_SCRIPT
        _git_commit_and_push "feat: add new installation command: $cmd" "Installation command logged and dotfiles repo synced."
        qpopd
    fi
}

function sto() {
    install_and_add_to_stow_setup "$@"
}

# Restows dotfiles and commits/pushes any changes
function restow() {
    qpushd "$DOTFILES"
    stow .
    git add .
    _git_commit_and_push "chore: update dotfiles" "Synced .dotfiles repo"
    qpopd
}

function gas() {
    $DOTFILES/scripts/git-autosync "$@"
}

## Utility functions

function l {
    eza \
        -a \
        -l \
        -F \
        --git \
        --git-repos \
        --group-directories-first \
        --header \
        --icons=always \
        --no-quotes \
        --time-style=relative \
        "$@"
}

# Zle widget to invoke tmux-sessionizer via key binding
# Clears command line, runs sessionizer, then resets prompt
function tmux_sessionizer_widget() {
    LBUFFER=""
    RBUFFER=""
    zle redisplay
    zsh -c "$DOTFILES/scripts/tmux-sessionizer"
    zle reset-prompt
}
zle -N tmux_sessionizer_widget
bindkey '^F' tmux_sessionizer_widget

# Aliases
alias lt="l --tree"
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias clip="pbcopy"
else
    alias clip="clip.exe"
fi
alias c.="code ."
alias v="nvim"
alias v.="nvim ."
alias sva="source .venv/bin/activate"
alias sz="source $HOME/.zshrc"
alias sp="source $HOME/.zprofile"
alias z.="z .."
alias z-="z -"
alias c="code"
alias f="fd"
alias fzv="v \$(fzf)"
alias g="git"
alias t="tmux"
alias ta="tmux attach"
alias tl="tmux list-sessions"
alias tm="tmux new-session -s main"
alias tf="$DOTFILES/scripts/tmux-sessionizer"
alias funcsync="uv sync && uv pip compile pyproject.toml --output-file requirements.txt --universal --emit-index-url --emit-index-annotation --no-strip-markers --quiet"
alias lg="lazygit"
alias ld="lazydocker"

# Named directories
hash -d dot="$HOME/.dotfiles"
hash -d projects="$HOME/projects"
hash -d downloads="$HOME/Downloads"

# Load any local configurations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Initialize interactive shell tools
_init_shell_tool "starship" 'eval "$(starship init zsh)"'
_init_shell_tool "zoxide" 'eval "$(zoxide init zsh)"'
_init_shell_tool "jj" 'source <(COMPLETE=zsh jj)'

# Source local bin env if it exists
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
