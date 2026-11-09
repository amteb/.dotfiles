#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

command_exists() {
    command -v "$1" > /dev/null 2>&1
}

prompt_install() {
    printf "Do you want to install %s? (y/n) " "$1"
    read -r REPLY
    [[ "$REPLY" =~ ^[Yy] ]]
}

# Detect OS, architecture and native package manager
case "$(uname -m)" in
    x86_64|amd64) ARCH="x86_64"; NVIM_ARCH="x86_64" ;;
    arm64|aarch64) ARCH="aarch64"; NVIM_ARCH="arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
    PM="brew"
elif command_exists apt-get; then
    OS="linux"
    PM="apt"
elif command_exists dnf; then
    OS="linux"
    PM="dnf"
elif command_exists pacman; then
    OS="linux"
    PM="pacman"
else
    echo "No supported package manager found (brew, apt, dnf, pacman)"
    exit 1
fi

# Install via the native package manager
pm_install() {
    case "$PM" in
        brew) brew install "$@" ;;
        apt) sudo apt-get install -y "$@" ;;
        dnf) sudo dnf install -y "$@" ;;
        pacman) sudo pacman -S --needed --noconfirm "$@" ;;
    esac
}

pm_update() {
    case "$PM" in
        brew) brew update ;;
        apt) sudo apt-get update && sudo apt-get upgrade -y ;;
        dnf) sudo dnf upgrade -y ;;
        pacman) sudo pacman -Syu --noconfirm ;;
    esac
}

# Package names that differ from the command name
pkg_name() {
    case "$PM:$1" in
        apt:fd|dnf:fd) echo "fd-find" ;;
        apt:bat) echo "bat" ;;
        *) echo "$1" ;;
    esac
}

# Fetch a GitHub release tarball and extract a single binary into ~/.local/bin
install_release_binary() {
    local url="$1" binary="$2" tmp
    tmp=$(mktemp -d)
    mkdir -p "$HOME/.local/bin"
    curl -fsSL "$url" | tar -xz -C "$tmp"
    install -m 755 "$(find "$tmp" -type f -name "$binary" | head -1)" "$HOME/.local/bin/$binary"
    rm -rf "$tmp"
}

install_neovim() {
    if [[ "$OS" == "mac" || "$PM" == "pacman" ]]; then
        pm_install neovim
        return
    fi
    local tarball="nvim-linux-${NVIM_ARCH}.tar.gz"
    curl -fLO "https://github.com/neovim/neovim/releases/latest/download/$tarball"
    sudo rm -rf "/opt/nvim-linux-${NVIM_ARCH}"
    sudo tar -C /opt -xzf "$tarball"
    sudo ln -sf "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim
    rm "$tarball"
}

install_package() {
    local package="$1"
    case "$package" in
        neovim) install_neovim ;;
        fd) pm_install "$(pkg_name fd)" ;;
        build-essential)
            case "$PM" in
                apt) pm_install build-essential ;;
                dnf) sudo dnf group install -y development-tools ;;
                pacman) pm_install base-devel ;;
            esac
            ;;
        git-delta)
            if [[ "$OS" == "mac" ]]; then
                pm_install git-delta
            else
                local url
                url=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest \
                    | jq -r --arg a "$ARCH-unknown-linux-gnu.tar.gz" '.assets[] | select(.name | startswith("delta-") and endswith($a)) | .browser_download_url' \
                    | head -1)
                install_release_binary "$url" delta
            fi
            ;;
        eza)
            if [[ "$OS" == "mac" || "$PM" == "pacman" ]]; then
                pm_install eza
            else
                install_release_binary "https://github.com/eza-community/eza/releases/latest/download/eza_${ARCH}-unknown-linux-gnu.tar.gz" eza
            fi
            ;;
        zoxide) curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh ;;
        uv) curl -LsSf https://astral.sh/uv/install.sh | sh ;;
        # Not in apt/dnf: use Homebrew, which is installed below on Linux
        tlrc|antidote|gitleaks|sd)
            if [[ "$OS" == "mac" || "$PM" == "pacman" && "$package" == "sd" ]]; then
                pm_install "$package"
            else
                command_exists brew || { echo "Homebrew required for $package, install it first"; return 1; }
                brew install "$package"
            fi
            ;;
        *) pm_install "$package" ;;
    esac
}

# Install Homebrew first on Linux so brew-only packages resolve
if [[ "$OS" == "linux" ]] && ! command_exists brew; then
    if prompt_install "Homebrew"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ -d /home/linuxbrew/.linuxbrew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
elif [[ "$OS" == "mac" ]] && ! command_exists brew; then
    echo "Homebrew not found. Install it from https://brew.sh and rerun."
    exit 1
fi

echo "Updating system packages..."
pm_update

# Map a package to the command it provides
cmd_for() {
    case "$1" in
        neovim) echo nvim ;;
        ripgrep) echo rg ;;
        git-delta) echo delta ;;
        fd) command_exists fd && echo fd || echo fdfind ;;
        build-essential) echo make ;;
        *) echo "$1" ;;
    esac
}

UTILS="curl wget git bat fd fzf ripgrep sd jq zoxide eza git-delta uv tlrc keychain tmux neovim stow unzip zsh antidote gitleaks"
[[ "$OS" == "linux" ]] && UTILS="build-essential $UTILS"

for util in $UTILS; do
    if command_exists "$(cmd_for "$util")" || { [[ "$util" == "antidote" ]] && [ -d "${HOMEBREW_PREFIX:-}/opt/antidote" ]; }; then
        echo "$util is already installed."
    elif prompt_install "$util"; then
        install_package "$util"
    fi
done

# Install Claude Code via its official installer
if ! command_exists claude && prompt_install "Claude Code"; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Set zsh as the default shell
if command_exists zsh && [ "$SHELL" != "$(command -v zsh)" ]; then
    if prompt_install "zsh as your default shell"; then
        if command_exists chsh; then
            chsh -s "$(command -v zsh)"
        else
            echo "chsh not found (install util-linux-user or passwd); skipping default shell change."
        fi
    fi
fi

# Install starship prompt if not already installed
if ! command_exists starship; then
    if prompt_install "starship prompt"; then
        curl -sS https://starship.rs/install.sh | sh
    fi
else
    echo "starship prompt is already installed."
fi

# Install pre-commit if not already installed
if ! command_exists pre-commit; then
    if prompt_install "pre-commit"; then
        uv tool install pre-commit
        pre-commit install
    fi
else
    echo "pre-commit is already installed."
fi

# Prompt to stow dotfiles
if prompt_install "stow your dotfiles"; then
    (cd "$SCRIPT_DIR/.." && stow --no-folding .)
fi

# Setup .gitconfig
if [ ! -f "$HOME/.gitconfig" ]; then
   echo "[include]" > "$HOME/.gitconfig"
   echo "    path = $HOME/.gitconfig.dotfiles" >> "$HOME/.gitconfig"
   echo "Created .gitconfig with include directive"
else
   if ! grep -q ".gitconfig.dotfiles" "$HOME/.gitconfig"; then
       echo "[include]" >> "$HOME/.gitconfig"
       echo "    path = $HOME/.gitconfig.dotfiles" >> "$HOME/.gitconfig"
       echo "Added include directive to existing .gitconfig"
   else
       echo ".gitconfig already includes .gitconfig.dotfiles"
   fi
fi

# Setup smudge and clean filters
if prompt_install "set up Git smudge and clean filters"; then
    sh "$SCRIPT_DIR/setup_smudge_clean.sh"
fi

echo "Setup complete"
