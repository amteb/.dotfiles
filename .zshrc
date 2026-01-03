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
    local original_dir
    original_dir="$(pwd)"
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

# Shared commit logic used by gcr and grel
function _commit_changes() {
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
                shift
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

        return 0
    else
        return 1
    fi
}

function gcr() {
    # Colors
    local GREEN='\033[0;32m'
    local NC='\033[0m'

    if _commit_changes "$@"; then
        echo -e "${GREEN}Committed changes (not pushed)${NC}"
    else
        echo "No changes to commit"
    fi
}

function grel() {
    local use_single_commit=0
    local skip_commit=0

    # Colors
    local BLUE='\033[0;34m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local CYAN='\033[0;36m'
    local NC='\033[0m'

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--single)
                use_single_commit=1
                shift
                ;;
            --skip-commit)
                skip_commit=1
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                echo "Usage: grel [-s|--single] [--skip-commit]" >&2
                return 1
                ;;
        esac
    done

    # Check if in a git repository
    if ! git rev-parse --git-dir &>/dev/null 2>&1; then
        echo -e "${RED}Error: Not in a git repository${NC}" >&2
        return 1
    fi

    # Check if gh CLI is installed
    if ! command -v gh &>/dev/null; then
        echo -e "${RED}Error: gh CLI is not installed${NC}" >&2
        echo "Install it with: brew install gh" >&2
        return 1
    fi

    # Check if we're authenticated with gh
    if ! gh auth status &>/dev/null; then
        echo -e "${RED}Error: Not authenticated with GitHub${NC}" >&2
        echo "Run: gh auth login" >&2
        return 1
    fi

    echo -e "${BLUE}=== GitHub Release Creator ===${NC}\n"

    # Step 1: Handle uncommitted changes
    if [ $skip_commit -eq 0 ]; then
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo -e "${YELLOW}You have uncommitted changes.${NC}"
            echo -n "Commit them now? [Y/n/q] "
            read -r response
            case "$response" in
                [Qq]*)
                    echo -e "${YELLOW}Release cancelled${NC}"
                    return 0
                    ;;
                [Nn]*)
                    echo -e "${YELLOW}Skipping commit. Release will use current HEAD.${NC}"
                    ;;
                *)
                    echo ""
                    if [ $use_single_commit -eq 1 ]; then
                        _commit_changes -s || return 1
                    else
                        _commit_changes || return 1
                    fi
                    echo ""
                    ;;
            esac
        fi
    fi

    # Step 2: Calculate next version
    echo -e "${BLUE}Calculating next version...${NC}"
    NEXT_VERSION=$("$DOTFILES/scripts/calculate-next-version.sh" 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$NEXT_VERSION" ]; then
        echo -e "${RED}Error: Failed to calculate next version${NC}" >&2
        return 1
    fi

    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

    echo -e "${CYAN}Current version:${NC} $LATEST_TAG"
    echo -e "${CYAN}Next version:${NC}    v$NEXT_VERSION"

    # Show commits that will be included
    echo -e "\n${CYAN}Commits since last tag:${NC}"
    if [ "$LATEST_TAG" = "none" ]; then
        git log --oneline --decorate --color=always | head -n 10
    else
        git log "$LATEST_TAG..HEAD" --oneline --decorate --color=always
    fi

    # Step 3: Confirm release
    echo -e "\n${YELLOW}This will:${NC}"
    echo "  1. Tag the current commit as v$NEXT_VERSION"
    echo "  2. Push the tag to origin"
    echo "  3. Create a GitHub release with auto-generated notes"
    echo ""
    echo -n "Proceed with release? [y/N/q] "
    read -r response

    case "$response" in
        [Qq]*)
            echo -e "${YELLOW}Release cancelled${NC}"
            return 0
            ;;
        [Yy]*)
            ;;
        *)
            echo -e "${YELLOW}Release cancelled${NC}"
            return 0
            ;;
    esac

    # Step 4: Create and push tag
    echo -e "\n${BLUE}Creating tag v$NEXT_VERSION...${NC}"
    if ! git tag -a "v$NEXT_VERSION" -m "Release v$NEXT_VERSION"; then
        echo -e "${RED}Error: Failed to create tag${NC}" >&2
        return 1
    fi

    echo -e "${BLUE}Pushing tag to origin...${NC}"
    if ! git push origin "v$NEXT_VERSION" && git push; then
        echo -e "${RED}Error: Failed to push tag${NC}" >&2
        echo -e "${YELLOW}Removing local tag...${NC}"
        git tag -d "v$NEXT_VERSION"
        return 1
    fi

    # Step 5: Create GitHub release
    echo -e "${BLUE}Creating GitHub release...${NC}"
    if gh release create "v$NEXT_VERSION" --generate-notes; then
        echo -e "\n${GREEN}✓ Release v$NEXT_VERSION created successfully!${NC}"
        echo -e "${CYAN}View release:${NC} $(gh release view "v$NEXT_VERSION" --json url -q .url)"
    else
        echo -e "${RED}Error: Failed to create GitHub release${NC}" >&2
        echo -e "${YELLOW}Note: Tag v$NEXT_VERSION was pushed but release creation failed${NC}"
        return 1
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
alias bruu="brew update && brew upgrade"
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
