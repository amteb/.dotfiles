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

## install and stow
qpushd() {
    pushd "$1" >/dev/null
}

qpopd() {
    popd >/dev/null
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
        echo "\n$cmd" >>"$SETUP_SCRIPT"

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
    local original_dir="$(pwd)"
    cd "$DOTFILES"

    stow .
    git add .

    if ! git diff --cached --quiet; then
        git commit -m "chore: update dotfiles"
        git push
        echo "Synced .dotfiles repo"
    else
        echo "No changes to commit"
    fi

    # Only return to original directory if we're not already in DOTFILES
    if [ "$original_dir" != "$DOTFILES" ]; then
        cd "$original_dir"
    fi
}

function gas() {
    $DOTFILES/scripts/git-autosync "$@"
}

## utility functions
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

# jj completion
if command -v jj &> /dev/null; then
    source <(COMPLETE=zsh jj)
fi

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
