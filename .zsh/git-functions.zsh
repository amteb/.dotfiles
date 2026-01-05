# Git and Dotfiles Management Functions
# This file contains functions for managing dotfiles, git workflows, and releases

# Quiet directory navigation helpers
qpushd() {
    pushd "$1" >/dev/null
}

qpopd() {
    popd >/dev/null
}

# Install a package and add the command to setup.sh
function install_and_add_to_stow_setup() {
    local cmd="$*"

    if [ -z "$cmd" ]; then
        echo "No command provided."
        return 1
    fi

    eval "$cmd"
    if [ $? -ne 0 ]; then
        echo "Installation command failed: $cmd"
        return 1
    fi

    SETUP_SCRIPT="$DOTFILES/scripts/setup.sh"

    if grep -Fxq "$cmd" "$SETUP_SCRIPT"; then
        echo "Command already exists in setup.sh: $cmd"
    else
        echo "\n$cmd" >>"$SETUP_SCRIPT"

        qpushd "$DOTFILES"
        git add $SETUP_SCRIPT

        if ! git diff --cached --quiet; then
            git commit -m "feat: add new installation command: $cmd"
            git push

            echo "Installation command logged and dotfiles repo synced."
        else
            echo "No changes to commit."
        fi

        qpopd
    fi
}

# Restow dotfiles and commit changes with safety checks
function restow() {
    local original_dir
    original_dir="$(pwd)"
    local use_single_commit=0
    local skip_checks=0
    local force_stow=0

    # Colors
    local BLUE='\033[0;34m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--single)
                use_single_commit=1
                shift
                ;;
            --no-checks)
                skip_checks=1
                shift
                ;;
            --force)
                force_stow=1
                shift
                ;;
            -h|--help)
                echo "Usage: restow [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -s, --single      Use single commit instead of atomic commits"
                echo "  --no-checks       Skip pre-commit checks"
                echo "  --force           Skip stow dry-run simulation"
                echo "  -h, --help        Show this help message"
                return 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}" >&2
                echo "Usage: restow [-s|--single] [--no-checks] [--force]" >&2
                return 1
                ;;
        esac
    done

    cd "$DOTFILES" || {
        echo -e "${RED}Error: Cannot access $DOTFILES${NC}" >&2
        return 1
    }

    # Run pre-commit checks (unless skipped)
    if [ $skip_checks -eq 0 ]; then
        if command -v pre-commit >/dev/null 2>&1 && [ -f .pre-commit-config.yaml ]; then
            echo -e "${BLUE}Running pre-commit checks...${NC}"
            if ! pre-commit run --all-files 2>&1 | tail -20; then
                echo ""
                echo -e "${RED}Pre-commit checks failed.${NC}"
                echo -e "${YELLOW}Fix issues or skip with: restow --no-checks${NC}"
                [ "$original_dir" != "$DOTFILES" ] && cd "$original_dir"
                return 1
            fi
            echo ""
        fi
    fi

    # Stow dry-run simulation (unless forced)
    if [ $force_stow -eq 0 ]; then
        echo -e "${BLUE}Checking for stow conflicts...${NC}"
        local stow_output
        stow_output=$(stow --simulate . 2>&1)

        if echo "$stow_output" | grep -qi "warning\|error"; then
            echo -e "${YELLOW}Stow simulation found potential issues:${NC}"
            echo "$stow_output"
            echo ""
            echo -e "${YELLOW}Continue anyway or skip with: restow --force${NC}"
            [ "$original_dir" != "$DOTFILES" ] && cd "$original_dir"
            return 1
        fi
    fi

    echo -e "${BLUE}Stowing dotfiles...${NC}"
    if ! stow . 2>&1; then
        echo -e "${RED}Stow failed${NC}" >&2
        [ "$original_dir" != "$DOTFILES" ] && cd "$original_dir"
        return 1
    fi

    git add .

    if ! git diff --cached --quiet; then
        local success=0

        # Try atomic commits by default, unless -s flag is set
        if [ $use_single_commit -eq 0 ]; then
            echo -e "${BLUE}Analyzing changes for atomic commits...${NC}"
            if "$DOTFILES/scripts/atomic-commits.sh" 2>&1; then
                success=1
                echo -e "${GREEN}Created atomic commits${NC}"
            else
                echo -e "${YELLOW}Failed to analyze, falling back to single commit${NC}" >&2
            fi
        fi

        # Fall back to single commit if atomic commits failed or -s flag was used
        if [ $success -eq 0 ]; then
            local commit_msg
            if commit_msg=$("$DOTFILES/scripts/generate-commit-message.sh" 2>/dev/null); then
                echo -e "${GREEN}Created commit:${NC} $commit_msg"
                git commit -m "$commit_msg" --quiet
            else
                # Final fallback to default message
                echo -e "${YELLOW}Using default commit message${NC}"
                git commit -m "chore: update dotfiles" --quiet
            fi
        fi

        echo -e "${BLUE}Pushing to remote...${NC}"
        if git push; then
            echo -e "${GREEN}Synced .dotfiles repo${NC}"
        else
            echo -e "${RED}Push failed${NC}" >&2
            echo -e "${YELLOW}Changes are committed locally. Push manually when ready.${NC}"
            [ "$original_dir" != "$DOTFILES" ] && cd "$original_dir"
            return 1
        fi
    else
        echo -e "${GREEN}No changes to commit${NC}"
    fi

    # Only return to original directory if we're not already in DOTFILES
    if [ "$original_dir" != "$DOTFILES" ]; then
        cd "$original_dir"
    fi
}

# Shared commit logic used by gcr and grel
function _commit_changes() {
    local use_single_commit=0

    # Colors
    local BLUE='\033[0;34m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m'

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--single)
                use_single_commit=1
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Check if in a git repository
    if ! git rev-parse --git-dir &>/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi

    git add .

    if ! git diff --cached --quiet; then
        local success=0

        # Try atomic commits by default, unless -s flag is set
        if [ $use_single_commit -eq 0 ]; then
            if "$DOTFILES/scripts/atomic-commits.sh" 2>&1; then
                success=1
            else
                echo -e "${YELLOW}Failed to analyze, falling back to single commit${NC}" >&2
            fi
        fi

        # Fall back to single commit if atomic commits failed or -s flag was used
        if [ $success -eq 0 ]; then
            local commit_msg
            if commit_msg=$("$DOTFILES/scripts/generate-commit-message.sh" 2>/dev/null); then
                echo -e "${GREEN}Created commit:${NC} $commit_msg"
                git commit -m "$commit_msg" --quiet
            else
                # Final fallback to default message
                echo -e "${YELLOW}Using default commit message${NC}"
                git commit -m "chore: update repository" --quiet
            fi
        fi

        return 0
    else
        return 1
    fi
}

# Git commit and remain (don't push)
function gcr() {
    # Colors
    local GREEN='\033[0;32m'
    local NC='\033[0m'

    if _commit_changes "$@"; then
        echo -e "${GREEN}Committed changes (not pushed)${NC}"
    else
        echo "No changes to commit"
    fi
}

# Git release - create a semantic version tag and GitHub release
function grel() {
    local use_single_commit=0
    local skip_commit=0

    # Colors
    local BLUE='\033[0;34m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local CYAN='\033[0;36m'
    local NC='\033[0m'

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--single)
                use_single_commit=1
                shift
                ;;
            --skip-commit)
                skip_commit=1
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                echo "Usage: grel [-s|--single] [--skip-commit]" >&2
                return 1
                ;;
        esac
    done

    # Check if in a git repository
    if ! git rev-parse --git-dir &>/dev/null 2>&1; then
        echo -e "${RED}Error: Not in a git repository${NC}" >&2
        return 1
    fi

    # Check if gh CLI is installed
    if ! command -v gh &>/dev/null; then
        echo -e "${RED}Error: gh CLI is not installed${NC}" >&2
        echo "Install it with: brew install gh" >&2
        return 1
    fi

    # Check if we're authenticated with gh
    if ! gh auth status &>/dev/null; then
        echo -e "${RED}Error: Not authenticated with GitHub${NC}" >&2
        echo "Run: gh auth login" >&2
        return 1
    fi

    echo -e "${BLUE}=== GitHub Release Creator ===${NC}\n"

    # Step 1: Handle uncommitted changes
    if [ $skip_commit -eq 0 ]; then
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo -e "${YELLOW}You have uncommitted changes.${NC}"
            echo -n "Commit them now? [Y/n/q] "
            read -r response
            case "$response" in
                [Qq]*)
                    echo -e "${YELLOW}Release cancelled${NC}"
                    return 0
                    ;;
                [Nn]*)
                    echo -e "${YELLOW}Skipping commit. Release will use current HEAD.${NC}"
                    ;;
                *)
                    echo ""
                    if [ $use_single_commit -eq 1 ]; then
                        _commit_changes -s || return 1
                    else
                        _commit_changes || return 1
                    fi
                    echo ""
                    ;;
            esac
        fi
    fi

    # Step 2: Calculate next version
    echo -e "${BLUE}Calculating next version...${NC}"
    NEXT_VERSION=$("$DOTFILES/scripts/calculate-next-version.sh" 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$NEXT_VERSION" ]; then
        echo -e "${RED}Error: Failed to calculate next version${NC}" >&2
        return 1
    fi

    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

    echo -e "${CYAN}Current version:${NC} $LATEST_TAG"
    echo -e "${CYAN}Next version:${NC}    v$NEXT_VERSION"

    # Show commits that will be included
    echo -e "\n${CYAN}Commits since last tag:${NC}"
    if [ "$LATEST_TAG" = "none" ]; then
        git log --oneline --decorate --color=always | head -n 10
    else
        git log "$LATEST_TAG..HEAD" --oneline --decorate --color=always
    fi

    # Step 3: Confirm release
    echo -e "\n${YELLOW}This will:${NC}"
    echo "  1. Tag the current commit as v$NEXT_VERSION"
    echo "  2. Push the tag to origin"
    echo "  3. Create a GitHub release with auto-generated notes"
    echo ""
    echo -n "Proceed with release? [y/N/q] "
    read -r response

    case "$response" in
        [Qq]*)
            echo -e "${YELLOW}Release cancelled${NC}"
            return 0
            ;;
        [Yy]*)
            ;;
        *)
            echo -e "${YELLOW}Release cancelled${NC}"
            return 0
            ;;
    esac

    # Step 4: Create and push tag
    echo -e "\n${BLUE}Creating tag v$NEXT_VERSION...${NC}"
    if ! git tag -a "v$NEXT_VERSION" -m "Release v$NEXT_VERSION"; then
        echo -e "${RED}Error: Failed to create tag${NC}" >&2
        return 1
    fi

    echo -e "${BLUE}Pushing tag to origin...${NC}"
    if ! git push origin "v$NEXT_VERSION" && git push; then
        echo -e "${RED}Error: Failed to push tag${NC}" >&2
        echo -e "${YELLOW}Removing local tag...${NC}"
        git tag -d "v$NEXT_VERSION"
        return 1
    fi

    # Step 5: Create GitHub release
    echo -e "${BLUE}Creating GitHub release...${NC}"
    if gh release create "v$NEXT_VERSION" --generate-notes; then
        echo -e "\n${GREEN}✓ Release v$NEXT_VERSION created successfully!${NC}"
        echo -e "${CYAN}View release:${NC} $(gh release view "v$NEXT_VERSION" --json url -q .url)"
    else
        echo -e "${RED}Error: Failed to create GitHub release${NC}" >&2
        echo -e "${YELLOW}Note: Tag v$NEXT_VERSION was pushed but release creation failed${NC}"
        return 1
    fi
}

# Git autosync - wrapper for git-autosync script
function gas() {
    $DOTFILES/scripts/git-autosync.sh "$@"
}

# Short alias for install_and_add_to_stow_setup
function sto() {
    install_and_add_to_stow_setup "$@"
}
