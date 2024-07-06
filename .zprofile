# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/squashfs-root/usr/bin" ] ; then
    PATH="$PATH:$HOME/squashfs-root/usr/bin"
fi

if [ -d "$HOME/.cargo/env" ] ; then
  source "$HOME/.cargo/env"
fi

if [ -d "$HOME/.rye/env" ] ; then
  source "$HOME/.rye/env"
fi

if [ -d "$HOME/.config/broot/launcher/bash/br" ] ; then
  source "$HOME/.config/broot/launcher/bash/br"
fi

if command -v nvim > /dev/null 2>&1; then
  export EDITOR='nvim'
fi

if [ -d "$HOME/.modular" ]; then
  export MODULAR_HOME="$HOME/.modular"
  if [ -d "$HOME/.modular/pkg/packages.modular.com_mojo/bin" ]; then
    export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"
  fi
fi

export HOMEBREW_NO_ENV_HINTS=TRUE

if command -v fd > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fd --type file --color=always"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--ansi"
fi
