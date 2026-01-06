#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2206,SC2128,SC2086
# SC2206: zsh array syntax differs from bash
# SC2128: zsh intentionally expands arrays without index in some contexts
# SC2086: zsh handles word splitting differently

# git-autosync: Automatic Git repository synchronization
# Manages periodic sync of multiple repositories with configurable frequencies

setopt null_glob

CONFIG_FILE="${HOME}/.git-autosync.cfg"
SCRIPT_PATH="${0:A}"
COMMAND_NAME="${0:t}"
LOG_FILE="${HOME}/.log/git_auto_sync.log"
USE_ATOMIC_COMMITS=0

typeset -A frequencies

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    print "Usage: $COMMAND_NAME [OPTION]... COMMAND [ARGS]...

Manage automatic Git repository synchronization.

Commands:
  add REPO FREQ      Add a repository to a frequency
  remove REPO FREQ   Remove a repository from a frequency
  list [FREQ]        List repositories (for a specific frequency if provided)
  list -a, --all     List all repositories for all frequencies
  sync FREQ          Synchronize repositories for a frequency
  sync -a, --all     Synchronize repositories for all frequencies
  update-cron        Update cron jobs
  add-freq FREQ CRON Add a new frequency with cron expression
  remove-freq FREQ   Remove a frequency and its repositories

Options:
  -h, --help         Display this help message
  --atomic           Use atomic commit messages (requires DOTFILES env var)

Environment:
  DOTFILES           Path to dotfiles directory (required for --atomic)

Examples:
  $COMMAND_NAME add . daily                    # Add current repo to daily sync
  $COMMAND_NAME sync weekly                    # Sync all weekly repos
  $COMMAND_NAME sync -a --atomic               # Sync all with atomic commits
  $COMMAND_NAME list                           # List all frequencies
  $COMMAND_NAME add-freq hourly '0 * * * *'   # Add hourly frequency"
}

log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Ensure log directory exists
    mkdir -p "${LOG_FILE:h}"

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    # Also print to stdout with colors
    case "$level" in
        ERROR)
            echo -e "${RED}✗${NC} $message" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}✓${NC} $message"
            ;;
        INFO)
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
    esac
}

check_git_repo() {
    local dir="$1"

    [[ "$dir" == "." ]] && dir="$PWD"

    if ! command -v git >/dev/null 2>&1; then
        log_message ERROR "git command not found"
        return 1
    fi

    if ! cd "$dir" 2>/dev/null; then
        log_message ERROR "Cannot access directory: $dir"
        return 1
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_message ERROR "Not a git repository: $dir"
        return 1
    fi

    return 0
}

check_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_message WARN "Config file not found: $CONFIG_FILE"
        return 1
    fi
    return 0
}

create_config() {
    log_message INFO "Creating new config file: $CONFIG_FILE"

    mkdir -p "${CONFIG_FILE:h}"

    if cat << 'EOF' > "$CONFIG_FILE"
[daily]
cron = "0 0 * * *"
paths = []

[weekly]
cron = "0 0 * * 0"
paths = []

[monthly]
cron = "0 0 1 * *"
paths = []
EOF
    then
        log_message SUCCESS "Created config file with daily, weekly, and monthly frequencies"
        return 0
    else
        log_message ERROR "Failed to create config file"
        return 1
    fi
}

load_config() {
    local current_freq=""
    local current_cron=""
    local current_paths=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue

        case "$line" in
            \[*\])
                # Save previous frequency if exists
                if [[ -n "$current_freq" ]]; then
                    frequencies[$current_freq]="${current_cron}:${(j:,:)current_paths}"
                fi
                # Start new frequency
                current_freq="${line:1:-1}"
                current_cron=""
                current_paths=()
                ;;
            cron*=*)
                current_cron="${line#*=}"
                current_cron="${current_cron#"${current_cron%%[! ]*}"}"
                current_cron="${current_cron#[\"\']}"
                current_cron="${current_cron%[\"\']}"
                ;;
            paths*=*)
                local paths_str="${line#*=}"
                paths_str="${paths_str#"${paths_str%%[! ]*}"}"
                paths_str="${paths_str#\[}"
                paths_str="${paths_str%\]}"

                if [[ -n "$paths_str" ]]; then
                    local IFS=,
                    current_paths=()
                    for path in ${=paths_str}; do
                        path="${path#"${path%%[! ]*}"}"
                        path="${path%"${path##*[! ]}"}"
                        path="${path#[\"\']}"
                        path="${path%[\"\']}"
                        [[ -n "$path" ]] && current_paths+=("$path")
                    done
                fi
                ;;
        esac
    done < "$CONFIG_FILE"

    # Save last frequency
    [[ -n "$current_freq" ]] && frequencies[$current_freq]="${current_cron}:${(j:,:)current_paths}"
}

save_config() {
    local config_dir="${CONFIG_FILE:h}"
    mkdir -p "$config_dir" || {
        log_message ERROR "Cannot create config directory: $config_dir"
        return 1
    }

    # Create backup
    [[ -f "$CONFIG_FILE" ]] && cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

    : > "$CONFIG_FILE" || {
        log_message ERROR "Cannot write to config file: $CONFIG_FILE"
        return 1
    }

    # Write each frequency section
    local freq cron paths
    for freq in ${(k)frequencies}; do
        cron="${frequencies[$freq]%%:*}"
        paths=(${(s:,:)${frequencies[$freq]#*:}})

        {
            print -r -- "[$freq]"
            print -r -- "cron = \"$cron\""

            local quoted_paths=()
            local path
            for path in $paths; do
                quoted_paths+=("\"$path\"")
            done
            print -r -- "paths = [${(j:, :)quoted_paths}]"
            print
        } >> "$CONFIG_FILE"
    done

    log_message SUCCESS "Configuration saved"
    return 0
}

generate_commit_message() {
    # repo_dir is passed but not used in this function
    local freq="$2"
    local message=""

    # Try atomic commits if flag is set and DOTFILES is configured
    if (( USE_ATOMIC_COMMITS )) && [[ -n "$DOTFILES" ]] && [[ -x "$DOTFILES/scripts/atomic-commits.sh" ]]; then
        log_message INFO "Attempting atomic commit message generation"
        if "$DOTFILES/scripts/atomic-commits.sh" 2>&1; then
            # atomic-commits.sh creates commits directly
            return 0
        else
            log_message WARN "Atomic commits failed, falling back to generated message"
        fi
    fi

    # Try generate-commit-message.sh
    if [[ -n "$DOTFILES" ]] && [[ -x "$DOTFILES/scripts/generate-commit-message.sh" ]]; then
        if message=$("$DOTFILES/scripts/generate-commit-message.sh" 2>/dev/null); then
            echo "$message"
            return 0
        fi
    fi

    # Final fallback
    echo "chore: auto-sync ($freq)"
    return 0
}

sync_repo() {
    local repo="$1"
    local freq="$2"

    log_message INFO "Syncing: $repo"

    (
        if ! cd "$repo" 2>/dev/null; then
            log_message ERROR "Cannot access: $repo"
            return 1
        fi

        if ! git rev-parse --git-dir >/dev/null 2>&1; then
            log_message ERROR "Not a git repository: $repo"
            return 1
        fi

        # Step 1: Pull latest changes
        log_message INFO "Pulling latest changes..."
        if ! git pull --rebase 2>&1 | tee -a "$LOG_FILE"; then
            log_message ERROR "Pull failed for $repo - may have conflicts"
            return 1
        fi

        # Step 2: Check for local changes
        if git diff --quiet && git diff --staged --quiet; then
            log_message INFO "No local changes to commit"
        else
            # Step 3: Add and commit changes
            log_message INFO "Local changes detected, committing..."
            git add .

            if (( USE_ATOMIC_COMMITS )); then
                # Let generate_commit_message handle it (atomic-commits creates commits directly)
                if ! generate_commit_message "$repo" "$freq"; then
                    log_message ERROR "Commit failed for $repo"
                    return 1
                fi
            else
                # Generate message and commit
                local commit_msg
                commit_msg=$(generate_commit_message "$repo" "$freq")
                if ! git commit -m "$commit_msg" --quiet; then
                    log_message ERROR "Commit failed for $repo"
                    return 1
                fi
                log_message SUCCESS "Committed: $commit_msg"
            fi
        fi

        # Step 4: Push changes
        log_message INFO "Pushing changes..."
        if ! git push 2>&1 | tee -a "$LOG_FILE"; then
            log_message ERROR "Push failed for $repo"
            return 1
        fi

        log_message SUCCESS "Sync completed: $repo"
        return 0
    )

    return $?
}

sync_repos() {
    local freq="$1"
    local paths=(${(s:,:)${frequencies[$freq]#*:}})

    if [[ ${#paths[@]} -eq 0 ]]; then
        log_message WARN "No repositories configured for frequency: $freq"
        return 0
    fi

    log_message INFO "Syncing ${#paths[@]} repositories for frequency: $freq"

    local success_count=0
    local fail_count=0
    local repo

    for repo in $paths; do
        if sync_repo "$repo" "$freq"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done

    log_message INFO "Sync summary: $success_count succeeded, $fail_count failed"

    return 0
}

add_repo() {
    local repo="$1"
    local freq="$2"

    # Resolve to absolute path
    if [[ "$repo" == "." ]]; then
        if ! check_git_repo "$PWD"; then
            return 1
        fi
        repo="$PWD"
    else
        if ! check_git_repo "$repo"; then
            return 1
        fi
        repo="${repo:A}"  # Get absolute path
    fi

    check_config || create_config || return 1
    load_config

    # Create frequency if it doesn't exist
    if [[ -z "${frequencies[$freq]}" ]]; then
        log_message WARN "Frequency '$freq' not found, creating it..."
        add_freq "$freq" || return 1
        load_config
    fi

    # Check if repo already exists in this frequency
    local cron="${frequencies[$freq]%%:*}"
    local paths=(${(s:,:)${frequencies[$freq]#*:}})

    if (( ${paths[(I)$repo]} )); then
        log_message WARN "Repository already in $freq: $repo"
        return 0
    fi

    paths+=("$repo")
    frequencies[$freq]="${cron}:${(j:,:)paths}"

    if save_config; then
        log_message SUCCESS "Added $repo to $freq"
        update_cron_for_freq "$freq"
        return 0
    fi

    return 1
}

remove_repo() {
    local repo="$1"
    local freq="$2"

    # Resolve to absolute path
    if [[ "$repo" == "." ]]; then
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            log_message ERROR "Current directory is not a git repository"
            return 1
        fi
        repo=$(git rev-parse --show-toplevel)
    else
        repo="${repo:A}"
    fi

    check_config || {
        log_message ERROR "Cannot remove repository - config file not found"
        return 1
    }

    load_config

    if [[ -z "${frequencies[$freq]}" ]]; then
        log_message ERROR "Frequency not found: $freq"
        return 1
    fi

    local cron="${frequencies[$freq]%%:*}"
    local paths=(${(s:,:)${frequencies[$freq]#*:}})

    if ! (( ${paths[(I)$repo]} )); then
        log_message WARN "Repository not in $freq: $repo"
        return 0
    fi

    paths=(${paths:#$repo})
    frequencies[$freq]="${cron}:${(j:,:)paths}"

    if save_config; then
        log_message SUCCESS "Removed $repo from $freq"
        update_cron
        return 0
    fi

    return 1
}

list_repos() {
    local freq="$1"

    check_config || return 1
    load_config

    if [[ -z "${frequencies[$freq]}" ]]; then
        log_message ERROR "Frequency not found: $freq"
        return 1
    fi

    local paths=(${(s:,:)${frequencies[$freq]#*:}})

    if [[ ${#paths[@]} -eq 0 ]]; then
        echo "No repositories configured for $freq"
        return 0
    fi

    echo "Repositories for $freq (${#paths[@]}):"
    print -l -- $paths
}

list_all_repos() {
    check_config || return 1
    load_config

    if [[ ${#frequencies[@]} -eq 0 ]]; then
        echo "No frequencies configured"
        return 0
    fi

    for freq in ${(k)frequencies}; do
        local paths=(${(s:,:)${frequencies[$freq]#*:}})
        printf "\n%s (%d repositories):" "$freq" "${#paths[@]}"
        if [[ ${#paths[@]} -gt 0 ]]; then
            print -l -- $paths | while read -r line; do
                print "  $line"
            done
        else
            echo "  (none)"
        fi
    done
}

update_cron_for_freq() {
    local freq="$1"
    local temp_crontab

    temp_crontab=$(crontab -l 2>/dev/null || echo "")

    # Remove existing entry for this frequency
    temp_crontab=$(echo "$temp_crontab" | grep -v "$SCRIPT_PATH sync $freq")

    # Get cron expression
    local cron_expression="${frequencies[$freq]%%:*}"

    if [[ -n "$cron_expression" ]]; then
        local atomic_flag=""
        (( USE_ATOMIC_COMMITS )) && atomic_flag="--atomic "

        # Add new entry
        echo "$temp_crontab
$cron_expression $SCRIPT_PATH ${atomic_flag}sync $freq >> $LOG_FILE 2>&1" | crontab -

        log_message SUCCESS "Updated cron job for $freq"
    else
        # Just write back without this frequency
        echo "$temp_crontab" | crontab -
        log_message INFO "Removed cron job for $freq"
    fi
}

update_cron() {
    check_config || return 1
    load_config

    log_message INFO "Updating all cron jobs..."

    for freq in ${(k)frequencies}; do
        update_cron_for_freq "$freq"
    done

    log_message SUCCESS "All cron jobs updated"
}

add_freq() {
    local freq="$1"
    local cron_expression="$2"

    if [[ -z "$cron_expression" ]]; then
        read -r "cron_expression?Enter cron expression for $freq (e.g., 0 0 * * * for daily at midnight): "
    fi

    if [[ -z "$cron_expression" ]]; then
        log_message ERROR "Cron expression is required"
        return 1
    fi

    frequencies[$freq]="${cron_expression}:"

    if save_config; then
        log_message SUCCESS "Added frequency: $freq with cron: $cron_expression"
        update_cron
        return 0
    fi

    return 1
}

remove_freq() {
    local freq="$1"

    check_config || {
        log_message ERROR "Cannot remove frequency - config file not found"
        return 1
    }

    load_config

    if [[ -z "${frequencies[$freq]}" ]]; then
        log_message ERROR "Frequency not found: $freq"
        return 1
    fi

    unset "frequencies[$freq]"

    if save_config; then
        log_message SUCCESS "Removed frequency: $freq"
        update_cron
        return 0
    fi

    return 1
}

# Parse global flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --atomic)
            USE_ATOMIC_COMMITS=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            log_message ERROR "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Main command dispatch
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

# Load config for all commands except help
check_config || create_config || exit 1
load_config

case "$1" in
    add)
        if [[ $# -lt 3 ]]; then
            log_message ERROR "Usage: $COMMAND_NAME add REPO FREQ"
            exit 1
        fi
        add_repo "$2" "$3"
        ;;
    remove)
        if [[ $# -lt 3 ]]; then
            log_message ERROR "Usage: $COMMAND_NAME remove REPO FREQ"
            exit 1
        fi
        remove_repo "$2" "$3"
        ;;
    list)
        case "$2" in
            "")
                echo "Available frequencies:"
                print -l -- ${(k)frequencies}
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
                log_message ERROR "Please specify a frequency or use -a/--all"
                exit 1
                ;;
            -a|--all)
                for freq in ${(k)frequencies}; do
                    sync_repos "$freq"
                done
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
        if [[ $# -lt 2 ]]; then
            log_message ERROR "Usage: $COMMAND_NAME add-freq FREQ [CRON]"
            exit 1
        fi
        add_freq "$2" "$3"
        ;;
    remove-freq)
        if [[ $# -lt 2 ]]; then
            log_message ERROR "Usage: $COMMAND_NAME remove-freq FREQ"
            exit 1
        fi
        remove_freq "$2"
        ;;
    *)
        log_message ERROR "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
