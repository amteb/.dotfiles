#!/bin/bash

CONFIG_FILE="$HOME/.gitautosync.cfg"
SCRIPT_PATH="$( readlink -f "$0" )"

show_help() {
    echo "Usage: $COMMAND_NAME [OPTION]... COMMAND [ARGS]..."
    echo
    echo "Manage automatic Git repository synchronization."
    echo
    echo "Commands:"
    echo "  add REPO FREQ      Add a repository to a frequency"
    echo "  remove REPO FREQ   Remove a repository from a frequency"
    echo "  list [FREQ]        List repositories (for a specific frequency if provided)"
    echo "  list -a, --all     List all repositories for all frequencies"
    echo "  sync FREQ          Synchronize repositories for a frequency"
    echo "  sync -a, --all     Synchronize repositories for all frequencies"
    echo "  update-cron        Update cron jobs"
    echo "  add-freq FREQ CRON Add a new frequency with cron expression"
    echo "  remove-freq FREQ   Remove a frequency and its repositories"
    echo
    echo "Options:"
    echo "  -h                 Display this help message"
    echo "  --help             Display more detailed help"
}

show_detailed_help() {
    show_help
    echo
    echo "Detailed Command Descriptions:"
    echo "  add REPOSITORY FREQUENCY"
    echo "    Add a repository to be synced at the specified frequency."
    echo "    Use '.' as REPOSITORY to add the current directory."
    echo
    echo "  remove REPOSITORY FREQUENCY"
    echo "    Remove a repository from the specified frequency."
    echo "    Use '.' as REPOSITORY to remove the current directory."
    echo
    echo "  list [FREQUENCY]"
    echo "    List all frequencies if no FREQUENCY is provided,"
    echo "    or list repositories for the specified FREQUENCY."
    echo "    Use -a or --all to list all repositories for all frequencies."
    echo
    echo "  sync FREQUENCY"
    echo "    Manually trigger a sync for the specified FREQUENCY."
    echo "    Use -a or --all to sync repositories for all frequencies."
    echo
    echo "  update-cron"
    echo "    Update cron jobs based on the current configuration."
    echo
    echo "  add-freq FREQUENCY CRON_EXPRESSION"
    echo "    Add a new frequency with the specified cron expression."
    echo "    Example: $COMMAND_NAME add-freq weekly '0 0 * * 0'"
    echo
    echo "  remove-freq FREQUENCY"
    echo "    Remove a frequency and all its associated repositories."
    echo "    Example: $COMMAND_NAME remove-freq weekly"
    echo
    echo "Configuration File: $CONFIG_FILE"
    echo "This file stores the frequencies, cron expressions, and repositories."
    echo "By default, it includes nightly, weekly, and monthly frequencies."
}

check_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Warning: Config file not found: $CONFIG_FILE"
        return 1
    fi
    return 0
}

create_config() {
    echo "Creating new config file: $CONFIG_FILE"
    cat << EOF > "$CONFIG_FILE"
[nightly]
cron=0 0 * * *
paths=[]

[weekly]
cron=0 0 * * 0
paths=[]

[monthly]
cron=0 0 1 * *
paths=[]
EOF
    echo "Created config file with premade nightly, weekly, and monthly frequencies."
}

get_paths() {
    local freq="$1"
    if ! check_config; then
        return 1
    fi
    sed -n "/^\[$freq\]/,/^\[/p" "$CONFIG_FILE" | grep "^paths" | sed 's/paths=\[\(.*\)\]/\1/' | tr ',' '\n' | sed 's/^ *//; s/ *$//; s/^"\(.*\)"$/\1/'
}

get_cron() {
    local freq="$1"
    if ! check_config; then
        return 1
    fi
    sed -n "/^\[$freq\]/,/^\[/p" "$CONFIG_FILE" | grep "^cron" | cut -d'=' -f2- | sed 's/^ *//; s/ *$//'
}

list_freqs() {
    if ! check_config; then
        return 1
    fi
    grep '^\[.*\]$' "$CONFIG_FILE" | sed 's/^\[\(.*\)\]$/\1/'
}

sync_repos() {
    local freq="$1"
    if ! check_config; then
        return 1
    fi
    echo "Syncing repositories for frequency: $freq"
    while IFS= read -r repo; do
        echo "Syncing $repo"
        cd "$repo" || continue
        git add .
        git commit -m "chore: $freq sync"
        git pull
        git push
    done < <(get_paths "$freq")
}

sync_all_repos() {
    if ! check_config; then
        return 1
    fi
    while IFS= read -r freq; do
        sync_repos "$freq"
    done < <(list_freqs)
}

add_repo() {
    local repo="$1"
    local freq="$2"

    if [ "$repo" = "." ]; then
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
            repo=$(git rev-parse --show-toplevel)
        else
            echo "Error: Current directory is not a git repository."
            return 1
        fi
    fi

    if ! check_config; then
        create_config
    fi
    if ! grep -q "^\[$freq\]" "$CONFIG_FILE"; then
        add_freq "$freq"
    fi
    escaped_repo=$(printf '%s\n' "$repo" | sed 's:[][\/.^$*]:\\&:g')

    sed -i "/^\[$freq\]/,/^\[/ s/paths=\[\(.*\)\]/paths=[\1, \"$escaped_repo\"]/" "$CONFIG_FILE"
    sed -i "/^\[$freq\]/,/^\[/ s/paths=\[, /paths=[/" "$CONFIG_FILE"
    echo "Added $repo to $freq in the configuration."
    update_cron_for_freq "$freq"
}

remove_repo() {
    local repo="$1"
    local freq="$2"

    if [ "$repo" = "." ]; then
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
            repo=$(git rev-parse --show-toplevel)
        else
            echo "Error: Current directory is not a git repository."
            return 1
        fi
    fi

    if ! check_config; then
        echo "Error: Cannot remove repository. Config file not found."
        return 1
    fi
    sed -i "/^\[$freq\]/,/^\[/ s/\"$(printf '%s\n' "$repo" | sed 's:[][\/.^$*]:\\&:g')\"[, ]*//g" "$CONFIG_FILE"
    sed -i "/^\[$freq\]/,/^\[/ s/paths=\[, /paths=[/" "$CONFIG_FILE"
    sed -i "/^\[$freq\]/,/^\[/ s/paths=\[,/paths=[/" "$CONFIG_FILE"
    sed -i "/^\[$freq\]/,/^\[/ s/paths=\[ /paths=[/" "$CONFIG_FILE"
    echo "Removed $repo from $freq in the configuration."
    update_cron
}

list_repos() {
    local freq="$1"
    if ! check_config; then
        return 1
    fi
    echo "Repositories for $freq:"
    get_paths "$freq"
}

list_all_repos() {
    if ! check_config; then
        return 1
    fi
    while IFS= read -r freq; do
        echo "Repositories for $freq:"
        get_paths "$freq" | sed 's/^/  /'
        echo
    done < <(list_freqs)
}

update_cron_for_freq() {
    local freq="$1"
    crontab -l | grep -v "$SCRIPT_PATH sync $freq" | crontab -

    cron_expression=$(get_cron "$freq")
    if [ -n "$cron_expression" ]; then
        (crontab -l ; echo "$cron_expression $SCRIPT_PATH sync $freq >> $HOME/.log/git_auto_sync.log 2>&1") | crontab -
        echo "Updated cron job for $freq"
    fi
}

update_cron() {
    while IFS= read -r freq; do
        update_cron_for_freq "$freq"
    done < <(list_freqs)
}

add_freq() {
    local freq="$1"
    local cron_expression="$2"

    if [ -z "$cron_expression" ]; then
        read -p "Enter cron expression for $freq (e.g., 0 0 * * * for daily at midnight): " cron_expression
    fi

    echo -e "\n[$freq]\ncron=$cron_expression\npaths=[]" >> "$CONFIG_FILE"
    echo "Added new frequency: $freq with cron expression: $cron_expression"
    update_cron
}

remove_freq() {
    local freq="$1"

    if ! check_config; then
        echo "Error: Cannot remove frequency. Config file not found."
        return 1
    fi

    if ! grep -q "^\[$freq\]" "$CONFIG_FILE"; then
        echo "Error: Frequency '$freq' not found in the configuration."
        return 1
    fi

    sed -i "/^\[$freq\]/,/^\[/d" "$CONFIG_FILE"

    sed -i '${/^$/d;}' "$CONFIG_FILE"

    echo "Removed frequency '$freq' and its associated repositories from the configuration."
    update_cron
}

case "$1" in
    -h)
        show_help
        exit 0
        ;;
    --help)
        show_detailed_help
        exit 0
        ;;
    add)
        add_repo "$2" "$3"
        ;;
    remove)
        remove_repo "$2" "$3"
        ;;
    list)
        case "$2" in
            "")
                echo "Available frequencies:"
                list_freqs
                ;;
            -a|--all)
                list_all_repos
                ;;
            *)
                list_repos "$2"
                ;;
        esac
        ;;
    sync)
        case "$2" in
            "")
                echo "Please specify a frequency to sync or use -a/--all to sync all frequencies."
                exit 1
                ;;
            -a|--all)
                sync_all_repos
                ;;
            *)
                sync_repos "$2"
                ;;
        esac
        ;;
    update-cron)
        update_cron
        ;;
    add-freq)
        add_freq "$2" "$3"
        ;;
    remove-freq)
        if [ -z "$2" ]; then
            echo "Please specify a frequency to remove."
            exit 1
        fi
        remove_freq "$2"
        ;;
    *)
        echo "Usage: $COMMAND_NAME {add|remove|list|sync|update-cron|add-freq|remove-freq} [repo] [freq]"
        echo "Use '$COMMAND_NAME -h' for brief help, or '$COMMAND_NAME --help' for detailed help."
        exit 1
        ;;
esac
