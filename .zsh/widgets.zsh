# Zsh Line Editor (ZLE) Widgets and Keybindings

# Ctrl+Z toggle - suspend/resume foreground process
# If command line is empty, brings last suspended job to foreground
# If command line has content, suspends current input (push-input)
function _ctrl_z_toggle() {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N _ctrl_z_toggle
bindkey '^Z' _ctrl_z_toggle

# Tmux sessionizer widget - bound to Ctrl+F
function tmux_sessionizer_widget() {
    LBUFFER=""
    RBUFFER=""
    zle redisplay
    zsh -c "$DOTFILES/scripts/tmux-sessionizer.sh"
    zle reset-prompt
}
zle -N tmux_sessionizer_widget
bindkey '^F' tmux_sessionizer_widget
