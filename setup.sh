# basic setup
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential
sudo apt install neofetch

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# zsh
sudo apt install zsh
curl -sS https://starship.rs/install.sh | sh
chsh -s $(which zsh)

# utility commands
# some are used in .zshrc
sudo apt install -y bat # cat alternative
sudo apt install -y fd-find # find alternative
sudo apt install -y fzf # fuzzy finding
sudo apt-get install ripgrep # grep alternative
sudo apt install sd # sed alternative
wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz \
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh # cd alternative
  && sudo chmod +x eza \
  && sudo chown root:root eza \
  && sudo mv eza /usr/local/bin/eza # ls alternative
curl -LsSf https://astral.sh/uv/install.sh | sh # pip alternative
curl -sSf https://rye.astral.sh/get | bash # WIP "cargo for python"
brew install tlrc # tldr, man alternative
sudo apt install keychain # for persistent github ssh sessions
# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
  && sudo rm -rf /opt/nvim \
  && sudo tar -C /opt -xzf nvim-linux64.tar.gz \
  && rm nvim-linux64.tar.gz

# GNU stow
# symlink manager for dotfiles
# used with https://github.com/atbraz/.dotfiles
# .zshrc contains helper functions
# https://www.gnu.org/software/stow/
sudo apt install stow
stow .
