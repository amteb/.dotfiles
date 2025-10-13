#!/bin/sh

# Get script directory (macOS compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    SCRIPT_DIR=$(dirname "$(greadlink -f "$0" 2>/dev/null || readlink "$0" 2>/dev/null || echo "$0")")
else
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Function to prompt user for installation
prompt_install() {
    printf "Do you want to install %s? (y/n) " "$1"
    read -r REPLY
    case "$REPLY" in
        [Yy]*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Detect OS and set package manager
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
    PKG_MGR="brew install"
else
    OS="linux"
    PKG_MGR="sudo apt install -y"
fi

# Function to install a package based on OS
install_package() {
    local package="$1"
    case "$package" in
        # Cross-platform packages that work with standard package managers
        bat|fzf|ripgrep|jq|tmux|keychain|neovim|stow|unzip)
            if [[ "$OS" == "mac" ]]; then
                brew install "$package"
            else
                if [[ "$package" == "neovim" ]]; then
                    # Linux manual installation for latest version
                    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
                    && sudo rm -rf /opt/nvim \
                    && sudo tar -C /opt -xzf nvim-linux64.tar.gz \
                    && rm nvim-linux64.tar.gz
                elif [[ "$package" == "unzip" ]]; then
                    echo "unzip should be pre-installed"
                else
                    $PKG_MGR "$package"
                fi
            fi
            ;;
        # OS-specific package names
        fd)
            if [[ "$OS" == "mac" ]]; then
                brew install fd
            else
                $PKG_MGR fd-find
            fi
            ;;
        git-delta)
            if [[ "$OS" == "mac" ]]; then
                brew install git-delta
            else
                # Linux manual installation
                url=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.assets[] | select(.name | contains("delta-") and contains("x86_64-unknown-linux-gnu.tar.gz")) | .browser_download_url')
                wget "$url" -O /tmp/delta.tar.gz \
                && dirname=$(tar -tzf /tmp/delta.tar.gz | head -1 | cut -f1 -d"/") \
                && tar -xzf /tmp/delta.tar.gz -C /tmp \
                && mv "/tmp/$dirname/delta" "$HOME/.local/bin" \
                && rm -r "/tmp/$dirname" \
                && rm /tmp/delta.tar.gz
            fi
            ;;
        # Cross-platform curl installers
        zoxide|uv)
            if [[ "$package" == "zoxide" ]]; then
                curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
            else
                curl -LsSf https://astral.sh/uv/install.sh | sh
            fi
            ;;
        # Special cases
        eza)
            if [[ "$OS" == "mac" ]]; then
                brew install eza
            else
                wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz \
                && sudo chmod +x eza \
                && sudo chown root:root eza \
                && sudo mv eza /usr/local/bin/eza
            fi
            ;;
        tlrc)
            brew install tlrc  # Available on both platforms via brew
            ;;
        sd)
            if [[ "$OS" == "mac" ]]; then
                brew install sd
            else
                $PKG_MGR sd
            fi
            ;;
        build-essential)
            if [[ "$OS" == "linux" ]]; then
                $PKG_MGR build-essential
            fi
            ;;
        *)
            echo "Unknown package: $package"
            return 1
            ;;
    esac
}

# List of utility commands to install
if [[ "$OS" == "mac" ]]; then
    UTILS="curl wget git bat fd fzf ripgrep sd jq zoxide eza git-delta uv tlrc keychain tmux neovim stow"
else
    UTILS="curl wget git build-essential bat fd fzf ripgrep sd jq zoxide eza git-delta uv tlrc keychain tmux neovim unzip stow"
fi

# Install utility commands
for util in $UTILS; do
    if ! command_exists "$util"; then
        if prompt_install "$util"; then
            install_package "$util"
        fi
    else
        echo "$util is already installed."
    fi
done

# Update system packages
if [[ "$OS" == "mac" ]]; then
    echo "Updating Homebrew..."
    brew update
else
    echo "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
fi

# Install neofetch if not already installed
if ! command_exists neofetch; then
    if prompt_install "neofetch"; then
        if [[ "$OS" == "mac" ]]; then
            brew install neofetch
        else
            sudo apt install neofetch
        fi
    fi
else
    echo "neofetch is already installed."
fi

# Install Homebrew if not already installed (Linux only, macOS has it by default)
if [[ "$OS" == "linux" ]] && ! command_exists brew; then
    if prompt_install "Homebrew"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ -d /home/linuxbrew/.linuxbrew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
elif [[ "$OS" == "mac" ]]; then
    echo "Homebrew should be pre-installed on macOS."
fi

# Install and configure zsh if not already the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    if prompt_install "zsh and set it as your default shell"; then
        if [[ "$OS" == "mac" ]]; then
            echo "zsh is pre-installed on macOS"
        else
            sudo apt install zsh
        fi
        chsh -s "$(which zsh)"
    fi
else
    echo "zsh is already your default shell."
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

# Install Neovim if not already installed
if ! command_exists nvim; then
    if prompt_install "Neovim"; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
        && sudo rm -rf /opt/nvim \
        && sudo tar -C /opt -xzf nvim-linux64.tar.gz \
        && rm nvim-linux64.tar.gz
    fi
else
    echo "Neovim is already installed."
fi

# Install unzip if not already installed
if ! command_exists unzip; then
    if prompt_install "unzip"; then
        sudo apt install unzip
    fi
else
    echo "unzip is already installed."
fi

# Install antidote if not already installed
if ! command_exists antidote; then
    if prompt_install "antidote"; then
        brew install antidote
    fi
else
    echo "antidote is already installed."
fi

# Install GNU stow if not already installed
if ! command_exists stow; then
    if prompt_install "GNU stow"; then
        sudo apt install stow
    fi
else
    echo "GNU stow is already installed."
fi

# Prompt to stow dotfiles
if prompt_install "stow your dotfiles"; then
    stow .
fi

# Install gitleaks if not already installed
if ! command_exists gitleaks; then
    if prompt_install "gitleaks"; then
        brew install gitleaks
    fi
else
    echo "gitleaks is already installed."
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
    sh $SCRIPT_DIR/setup_smudge_clean.sh
fi

echo "Setup complete"
