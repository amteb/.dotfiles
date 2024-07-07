# basic setup
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential
sudo apt install neofetch

# install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# GNU stow
# symlink manager for dotfiles
# used with https://github.com/atbraz/.dotfiles
# .zshrc contains helper functions
# https://www.gnu.org/software/stow/
sudo apt install stow

# for persistent github ssh sessions
sudo apt install keychain

# utility commands
# referenced in .zshrc
sudo apt install -y bat

sudo apt install -y fd-find

sudo apt install -y fzf

sudo apt install

sudo apt-get install ripgrep

wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz \
  && sudo chmod +x eza \
  && sudo chown root:root eza \
  && sudo mv eza /usr/local/bin/eza

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
  && sudo rm -rf /opt/nvim \
  && sudo tar -C /opt -xzf nvim-linux64.tar.gz \
  && rm nvim-linux64.tar.gz

sudo apt install sd

brew install tlrc

curl -LsSf https://astral.sh/uv/install.sh | sh

curl -sSf https://rye.astral.sh/get | bash

sudo apt install zsh
