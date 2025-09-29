# XDG Base Directory Specification
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# Ensure Zsh directories exist
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || mkdir -p -- "${(P)zdir}"
  done
} XDG_{CONFIG,CACHE,DATA,STATE}_HOME

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
    "/usr/local/zig"
    "$HOME/go/bin"
)

# Conditional PATH additions
[[ -d "$HOME/squashfs-root/usr/bin" ]] && path+=("$HOME/squashfs-root/usr/bin")
[[ -d "/usr/local/node/bin" ]] && path+=("/usr/local/node/bin")
[[ -d "/opt/mssql-tools18/bin" ]] && path+=("/opt/mssql-tools18/bin")
[[ -d "/home/linuxbrew/.linuxbrew/bin" ]] && path+=("/home/linuxbrew/.linuxbrew/bin")

export PATH

# FZF configuration
if command -v fd > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fd --type file --color=always"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--ansi"
fi

export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=true

# opam configuration
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2>/dev/null
. "$HOME/.cargo/env"
