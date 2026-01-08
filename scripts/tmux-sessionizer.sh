#!/usr/bin/env zsh
# shellcheck disable=SC2154,SC2034

add_paths_from_dir() {
    local base_dir=$1
    local fd_cmd=$2

    while IFS= read -r path; do
        display_path=${path#"$base_dir"}
        paths[${display_path%/}]=$path
    done < <($fd_cmd . "$base_dir" --max-depth 1 --type d --exclude '.*' --exclude '_*')
}

add_single_path() {
    local full_path=$1
    local display_name=${full_path:t}  # :t modifier gets basename

    # Skip if basename starts with _
    [[ $display_name == _* ]] && return

    paths[$display_name]=$full_path
}

add_path_with_alias() {
    local alias_name=$1
    local full_path=$2

    paths[$alias_name]=$full_path
}

get_project_paths() {
    local FD_CMD=${commands[fd]}
    local FZF_CMD=${commands[fzf]}
    local SORT_CMD=${commands[sort]}

    declare -A paths

    add_paths_from_dir "$CODE/" "$FD_CMD"
    add_paths_from_dir "$VAULT/Work/FinMath/CourseWork" "$FD_CMD"

    add_path_with_alias "FinMath" "$VAULT/Work/FinMath/CourseWork"

    add_single_path "$DOTFILES"
    add_single_path "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/"


    local -a keys=("${(@k)paths}")
    print -l "${(@)keys}" | $SORT_CMD -rf | $FZF_CMD | while read -r selected_display; do
        [[ -n $selected_display ]] && echo "${paths[$selected_display]}"
    done
}

selected=${1:-$(get_project_paths)}

# Early return using short-circuit operator
[[ -z $selected ]] && exit 0

create_or_attach_session() {
    local session_name=$1
    local session_path=$2
    local config_file=$3

    if ! tmux has-session -t="$session_name" 2>/dev/null; then
        tmux new-session -ds "$session_name" -c "$session_path"
        tmux source-file "$config_file"
    fi
}

selected_name=$(basename "$selected")
selected_name=${selected_name//\./_}
tmux_running=$(pgrep tmux)
TMUX_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"

if [[ -z $TMUX && -z $tmux_running ]]; then
    tmux -f "$TMUX_CONFIG" new-session -s "$selected_name" -c "$selected"
elif [[ -z $TMUX && -n $tmux_running ]]; then
    create_or_attach_session "$selected_name" "$selected" "$TMUX_CONFIG"
    tmux attach-session -t "$selected_name"
else
    create_or_attach_session "$selected_name" "$selected" "$TMUX_CONFIG"
    tmux switch-client -t "$selected_name"
fi
