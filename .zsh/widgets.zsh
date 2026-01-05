# Zsh Line Editor (ZLE) Widgets and Keybindings

# Tmux sessionizer widget - bound to Ctrl+F
function tmux_sessionizer_widget() {
    LBUFFER=""
    RBUFFER=""
    zle redisplay
    zsh -c "$DOTFILES/scripts/tmux-sessionizer"
    zle reset-prompt
}
zle -N tmux_sessionizer_widget
bindkey '^F' tmux_sessionizer_widget
