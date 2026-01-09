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
    add_paths_from_dir "$VAULT/Work/FinMath/Coursework" "$FD_CMD"

    add_path_with_alias "FinMath" "$VAULT/Work/FinMath/Coursework"

    add_single_path "$DOTFILES"
    add_single_path "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/"


    # Output: "display_name\tfull_path" for fzf to use
    local -a entries=()
    for key in '${(@k)paths}'; do
        entries+=("$key	${paths[$key]}")
    done

    # Preview script shows project markers and recent git activity
    local preview_cmd='
        dir="{2}"
        markers=""
        [[ -d "$dir/.git" ]] && markers+="git "
        [[ -f "$dir/package.json" ]] && markers+="node "
        [[ -f "$dir/Cargo.toml" ]] && markers+="rust "
        [[ -f "$dir/go.mod" ]] && markers+="go "
        [[ -f "$dir/pyproject.toml" || -f "$dir/setup.py" ]] && markers+="python "
        [[ -n "$markers" ]] && echo "[$markers]" || echo "[directory]"
        echo "---"
        if [[ -d "$dir/.git" ]]; then
            git -C "$dir" log --oneline -5 2>/dev/null || echo "No commits"
        else
            ls -la "$dir" 2>/dev/null | head -10
        fi
    '

    print -l "${(@)entries}" | $SORT_CMD -rf | \
        $FZF_CMD --delimiter='\t' \
                 --with-nth=1 \
                 --preview "$preview_cmd" \
                 --preview-window=right:50%:wrap \
                 --height=80% | \
        cut -f2
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
