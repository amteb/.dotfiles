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

# Keybindings
bindkey -e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line
bindkey '\ev' edit-command-line

# Better word movement - respect path separators
# Removes '/' from WORDCHARS so Ctrl+W stops at directory boundaries
# Example: /usr/local/bin -> Ctrl+W removes 'bin', next Ctrl+W removes 'local'
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# Alternative word selection styles for different contexts
autoload -U select-word-style
select-word-style bash

# Completion system
source ~/.dotfiles/.zsh/completions.zsh

# Named directories
hash -d dev="$HOME/Dev"
hash -d dot="$HOME/.dotfiles"
hash -d downloads="$HOME/Downloads"

# Load modular configuration
source ~/.dotfiles/.zsh/git-functions.zsh
source ~/.dotfiles/.zsh/aliases.zsh
source ~/.dotfiles/.zsh/widgets.zsh
source ~/.dotfiles/.zsh/integrations.zsh
