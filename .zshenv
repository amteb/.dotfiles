# ~/.zshenv
#
# Sourced on ALL zsh invocations (interactive, non-interactive, login, non-login)
# This is the first file zsh reads, so it's always executed.
#
# What should go here:
#   - Environment variables needed by all shells and programs
#   - PATH and other search path variables
#   - Variables that other programs (not just zsh) need
#   - XDG base directory specifications
#
# What should NOT go here:
#   - Interactive shell features (prompts, aliases, key bindings)
#   - Anything that produces output
#   - Slow operations (this file is sourced frequently)
#   - Tool initialization that requires interactive shells
#
# Note: Keep this file fast and minimal since it's sourced by all zsh instances.

# XDG Base Directory Specification
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# Ensure XDG directories exist using anonymous function
# The () syntax creates an anonymous function that executes immediately
# ${(P)zdir} does parameter expansion to get the value of the variable named in $zdir
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

# Perl stuff
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"

# PATH modifications
typeset -U path

# Helper function to conditionally add directories to PATH
# Only adds a directory if it exists on the filesystem
_add_to_path() {
    local dir
    for dir in "$@"; do
        [[ -d "$dir" ]] && path+=("$dir")
    done
}

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
_add_to_path \
    "$HOME/squashfs-root/usr/bin" \
    "/usr/local/node/bin" \
    "/opt/mssql-tools18/bin" \
    "/home/linuxbrew/.linuxbrew/bin" \
    "$HOME/perl5/bin"

export PATH

# FZF configuration
if command -v fd > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fd --type file --color=always"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--ansi"
fi
