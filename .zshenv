# Environment variables
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export HOMEBREW_NO_ENV_HINTS=TRUE
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=TRUE
export DOTFILES="$HOME/.dotfiles"

# PATH modifications
typeset -U path
path=(
    $path
    "$HOME/bin"
    "$HOME/.local/bin"
    "/usr/local/bin"
    "/opt/nvim-linux64/bin"
    "/usr/local/go/bin"
)

# Conditional PATH additions
[[ -d "$HOME/squashfs-root/usr/bin" ]] && path+=("$HOME/squashfs-root/usr/bin")
[[ -d "/usr/local/node/bin" ]] && path+=("/usr/local/node/bin")
[[ -d "/opt/mssql-tools18/bin" ]] && path+=("/opt/mssql-tools18/bin")

export PATH

# FZF configuration
if command -v fd > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fd --type file --color=always"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--ansi"
fi

export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=true
