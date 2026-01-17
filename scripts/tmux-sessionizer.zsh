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

    add_single_path "$DOTFILES"
    add_single_path "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/"

    add_paths_from_dir "$CODE/" "$FD_CMD"
    add_paths_from_dir "$CODE/FinMath/" "$FD_CMD"
    add_paths_from_dir "$CODE/Clones/" "$FD_CMD"
    add_paths_from_dir "$CODE/Projects/" "$FD_CMD"


    # Output: "display_name\tfull_path" for fzf to use
    local -a entries=()
    for key in ${(@k)paths}; do
        entries+=("$key	${paths[$key]}")
    done

    # Preview script shows project markers and recent git activity (POSIX sh compatible)
    local preview_cmd='
        dir={2}
        markers=""
        [ -d "$dir/.git" ] && markers="$markers git"
        [ -f "$dir/package.json" ] && markers="$markers node"
        [ -f "$dir/Cargo.toml" ] && markers="$markers rust"
        [ -f "$dir/go.mod" ] && markers="$markers go"
        [ -f "$dir/pyproject.toml" ] && markers="$markers python"
        [ -f "$dir/setup.py" ] && markers="$markers python"
        if [ -n "$markers" ]; then echo "[$markers ]"; else echo "[directory]"; fi
        echo "---"
        if [ -d "$dir/.git" ]; then
            branch=$(/usr/bin/git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || echo "detached")
            git_status=$(/usr/bin/git -C "$dir" status --porcelain 2>/dev/null)
            conflicted=$(echo "$git_status" | /usr/bin/grep -c "^UU\|^AA\|^DD" || true)
            deleted=$(echo "$git_status" | /usr/bin/grep -c "^ D\|^D " || true)
            renamed=$(echo "$git_status" | /usr/bin/grep -c "^R" || true)
            modified=$(echo "$git_status" | /usr/bin/grep -c "^ M" || true)
            staged=$(echo "$git_status" | /usr/bin/grep -c "^M\|^A" || true)
            untracked=$(echo "$git_status" | /usr/bin/grep -c "^\?\?" || true)
            stashed=$(/usr/bin/git -C "$dir" stash list 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d " ")
            upstream=$(/usr/bin/git -C "$dir" rev-parse --abbrev-ref @{u} 2>/dev/null)
            if [ -n "$upstream" ]; then
                ahead=$(/usr/bin/git -C "$dir" rev-list @{u}..HEAD 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d " ")
                behind=$(/usr/bin/git -C "$dir" rev-list HEAD..@{u} 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d " ")
            fi
            status_str=" $branch "
            [ "$conflicted" -gt 0 ] && status_str="${status_str}\033[31mc${conflicted}\033[0m"
            [ "$deleted" -gt 0 ] && status_str="${status_str}\033[31mx${deleted}\033[0m"
            [ "$renamed" -gt 0 ] && status_str="${status_str}\033[33mr${renamed}\033[0m"
            [ "$modified" -gt 0 ] && status_str="${status_str}\033[33mm${modified}\033[0m"
            [ "$staged" -gt 0 ] && status_str="${status_str}\033[32mg${staged}\033[0m"
            [ "$untracked" -gt 0 ] && status_str="${status_str}\033[32mu${untracked}\033[0m"
            [ "$stashed" -gt 0 ] && status_str="${status_str}\033[90ms${stashed}\033[0m"
            [ -n "$ahead" ] && [ "$ahead" -gt 0 ] && status_str="${status_str}\033[36ma${ahead}\033[0m"
            [ -n "$behind" ] && [ "$behind" -gt 0 ] && status_str="${status_str}\033[36mb${behind}\033[0m"
            echo "$status_str"
            echo "---"
            /usr/bin/git -C "$dir" log --oneline --color=always -5 2>/dev/null || echo "No commits"
            echo "---"
        fi
        /opt/homebrew/bin/eza -la --color=always "$dir" 2>/dev/null | /usr/bin/head -15
    '

    print -l "${(@)entries}" | $SORT_CMD -rf | \
        $FZF_CMD --delimiter='\t' \
                 --with-nth=1 \
                 --preview "$preview_cmd" \
                 --preview-window=right:50%:wrap \
                 --ansi \
                 --height=80% | \
        /usr/bin/cut -f2
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
