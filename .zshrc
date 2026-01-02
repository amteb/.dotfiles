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


function restow() {
    local original_dir="$(pwd)"
    local use_single_commit=0

    # Colors
    local BLUE='\033[0;34m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m'

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--single)
                use_single_commit=1
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                echo "Usage: restow [-s|--single]" >&2
                return 1
                ;;
        esac
    done

    cd "$DOTFILES"

    echo -e "${BLUE}Stowing dotfiles...${NC}"
    stow .
    git add .

    if ! git diff --cached --quiet; then
        local success=0

        # Try thematic commits by default, unless -s flag is set
        if [ $use_single_commit -eq 0 ]; then
            if "$DOTFILES/scripts/atomic-commits.sh" 2>&1; then
                success=1
            else
                echo -e "${YELLOW}Failed to analyze, falling back to single commit${NC}" >&2
            fi
        fi

        # Fall back to single commit if atomic commits failed or -s flag was used
        if [ $success -eq 0 ]; then
            local commit_msg
            if commit_msg=$("$DOTFILES/scripts/generate-commit-message.sh" 2>/dev/null); then
                echo -e "${GREEN}Created commit:${NC} $commit_msg"
                git commit -m "$commit_msg" --quiet
            else
                # Final fallback to default message
                echo -e "${YELLOW}Using default commit message${NC}"
                git commit -m "chore: update dotfiles" --quiet
            fi
        fi

        echo -e "${BLUE}Pushing to remote...${NC}"
        git push
        echo -e "${GREEN}Synced .dotfiles repo${NC}"
    else
        echo "No changes to commit"
    fi

    # Only return to original directory if we're not already in DOTFILES
    if [ "$original_dir" != "$DOTFILES" ]; then
        cd "$original_dir"
    fi
}

## script functions
function sto() {
    install_and_add_to_stow_setup "$@"
}

function gcr() {
    local use_single_commit=0

    # Colors
    local BLUE='\033[0;34m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m'

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--single)
                use_single_commit=1
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                echo "Usage: gcr [-s|--single]" >&2
                return 1
                ;;
        esac
    done

    # Check if in a git repository
    if ! git rev-parse --git-dir &>/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi

    git add .

    if ! git diff --cached --quiet; then
        local success=0

        # Try atomic commits by default, unless -s flag is set
        if [ $use_single_commit -eq 0 ]; then
            if "$DOTFILES/scripts/atomic-commits.sh" 2>&1; then
                success=1
            else
                echo -e "${YELLOW}Failed to analyze, falling back to single commit${NC}" >&2
            fi
        fi

        # Fall back to single commit if atomic commits failed or -s flag was used
        if [ $success -eq 0 ]; then
            local commit_msg
            if commit_msg=$("$DOTFILES/scripts/generate-commit-message.sh" 2>/dev/null); then
                echo -e "${GREEN}Created commit:${NC} $commit_msg"
                git commit -m "$commit_msg" --quiet
            else
                # Final fallback to default message
                echo -e "${YELLOW}Using default commit message${NC}"
                git commit -m "chore: update repository" --quiet
            fi
        fi

        echo -e "${GREEN}Committed changes (not pushed)${NC}"
    else
        echo "No changes to commit"
    fi
}

function gas() {
    $DOTFILES/scripts/git-autosync "$@"
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

## alias functions
function g {
    glow -t "$@"
}

function l {
    eza \
        -F \
        -a \
        -l \
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
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias clip="pbcopy"
else
    alias clip="clip.exe"
fi
alias buu="brew update && brew upgrade"
alias c.="code ."
alias c="code"
alias clod="claude"
alias esh="exec zsh"
alias f="fd"
alias funcsync="uv sync && uv pip compile pyproject.toml --output-file requirements.txt --universal --emit-index-url --emit-index-annotation --no-strip-markers --quiet"
alias fzv="v \$(fzf)"
alias ld="lazydocker"
alias lg="lazygit"
alias lt="l --tree"
alias se="source $HOME/.zshenv"
alias sp="source $HOME/.zprofile"
alias sz="source $HOME/.zshrc"
alias sva="source .venv/bin/activate"
alias oc="opencode"
alias t="tmux"
alias ta="tmux attach"
alias td="tmux detach"
alias tf="$DOTFILES/scripts/tmux-sessionizer"
alias tl="tmux list-sessions"
alias ts="tmux choose-tree -Zs"
alias v.="nvim ."
alias v="nvim"
alias z-="z -"
alias z.="z .."
alias z..="z ../.."
alias z...="z ../../.."
alias z....="z ../../../..."

# Named directories
hash -d dev="$HOME/Dev"
hash -d dot="$HOME/.dotfiles"
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


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '%%HOME%%/.opam/opam-init/init.zsh' ]] || source '%%HOME%%/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
# Another test
