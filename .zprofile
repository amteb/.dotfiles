# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

# set PATH so it includes user's private bin if it exists
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# set PATH so it includes user's private bin if it exists
[ -d "$HOME/squashfs-root/usr/bin" ] && PATH="$PATH:$HOME/squashfs-root/usr/bin"

[ -d "/opt/nvim-linux64" ] && export PATH="$PATH:/opt/nvim-linux64/bin" && export EDITOR='nvim'

[ -d "$HOME/.modular" ] && export MODULAR_HOME="$HOME/.modular" && ([ -d "$HOME/.modular/pkg/packages.modular.com_mojo/bin" && export PATH="$PATH:$HOME/.modular/pkg/packages.modular.com_mojo/bin")

[ -d "/usr/local/node/bin/" ] && PATH="$PATH:/usr/local/node/bin"

[ -d "/opt/mssql-tools18/bin" ] && PATH="$PATH:/opt/mssql-tools18/bin"

[ -d "/usr/local/go/bin" ] && export PATH=$PATH:/usr/local/go/bin

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

[ -f "$HOME/.rye/env" ] && source "$HOME/.rye/env"

export HOMEBREW_NO_ENV_HINTS=TRUE
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=TRUE

if command -v fd > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fd --type file --color=always"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--ansi"
fi

# stow .dotfiles
export DOT="$HOME/.dotfiles"

export HOMEBREW_NO_ENV_HINTS=TRUE

if command -v fd > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fd --type file --color=always"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--ansi"
fi

# stow .dotfiles
export DOT="$HOME/.dotfiles"

[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
