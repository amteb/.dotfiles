#!/bin/sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

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

# List of utility commands to install
UTILS="curl wget git build-essential bat fd-find fzf ripgrep sd jq zoxide eza delta uv tlrc keychain tmux"

# Install utility commands
for util in $UTILS; do
    if ! command_exists "$util"; then
        if prompt_install "$util"; then
            case "$util" in
                bat) sudo apt install -y bat ;;
                fd-find) sudo apt install -y fd-find ;;
                fzf) sudo apt install -y fzf ;;
                ripgrep) sudo apt-get install ripgrep ;;
                sd) sudo apt install sd ;;
                jq) sudo apt-get install jq ;;
                zoxide) curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh ;;
                eza)
                    wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz \
                    && sudo chmod +x eza \
                    && sudo chown root:root eza \
                    && sudo mv eza /usr/local/bin/eza
                    ;;
                delta)
                    url=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.assets[] | select(.name | contains("delta-") and contains("x86_64-unknown-linux-gnu.tar.gz")) | .browser_download_url')
                    wget "$url" -O /tmp/delta.tar.gz \
                    && dirname=$(tar -tzf /tmp/delta.tar.gz | head -1 | cut -f1 -d"/") \
                    && tar -xzf /tmp/delta.tar.gz -C /tmp \
                    && mv "/tmp/$dirname/delta" "$HOME/.local/bin" \
                    && rm -r "/tmp/$dirname" \
                    && rm /tmp/delta.tar.gz
                    ;;
                uv) curl -LsSf https://astral.sh/uv/install.sh | sh ;;
                tlrc) brew install tlrc ;;
                keychain) sudo apt install keychain ;;
            esac
        fi
    else
        echo "$util is already installed."
    fi
done

# Update and upgrade system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install build-essential if not already installed
if ! dpkg -s build-essential > /dev/null 2>&1; then
    echo "Installing build-essential..."
    sudo apt install -y build-essential
else
    echo "build-essential is already installed."
fi

# Install neofetch if not already installed
if ! command_exists neofetch; then
    if prompt_install "neofetch"; then
        sudo apt install neofetch
    fi
else
    echo "neofetch is already installed."
fi

# Install Homebrew if not already installed
if ! command_exists brew; then
    if prompt_install "Homebrew"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ -d /home/linuxbrew/.linuxbrew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
else
    echo "Homebrew is already installed."
fi

# Install and configure zsh if not already the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    if prompt_install "zsh and set it as your default shell"; then
        sudo apt install zsh
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
