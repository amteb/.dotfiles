# Shell Aliases and Alias-like Functions

# Alias-like functions (wrappers with default arguments)
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

function md {
    mkdir -p "$1" && cd "$1"
}

# System aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias clip="pbcopy"
else
    alias clip="clip.exe"
fi

# Package management
alias bruu="brew update && brew upgrade"

# Editors
alias clod="claude"
alias clodo="claude --model opus"
alias clodp="claude --model opusplan"
alias clods="claude --model sonnet"
alias clodh="claude --model haiku"
alias oc="opencode"
alias v.="nvim ."
alias v="nvim"

# Shell management
alias esh="exec zsh"
alias se="source $HOME/.zshenv"
alias sp="source $HOME/.zprofile"
alias sz="source $HOME/.zshrc"

# Python virtual environment
alias sva="source .venv/bin/activate"
alias funcsync="uv sync && uv pip compile pyproject.toml --output-file requirements.txt --universal --emit-index-url --emit-index-annotation --no-strip-markers --quiet"

# CLI tools
alias f="fd"
alias fzv="v \$(fzf)"
alias ld="lazydocker"
alias lg="lazygit"
alias lt="l --tree"

# Tmux
alias t="tmux"
alias ta="tmux attach"
alias td="tmux detach"
alias tf="$DOTFILES/scripts/tmux-sessionizer"
alias tl="tmux list-sessions"
alias ts="tmux choose-tree -Zs"

# Zoxide navigation
alias z-="z -"
alias z.="z .."
alias z..="z ../.."
alias z...="z ../../.."
alias z....="z ../../../..."
