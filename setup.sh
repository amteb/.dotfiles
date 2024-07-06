sudo apt update && sudo apt upgrade -y
sudo apt install stow
sudo apt install keychain
sudo apt install -y build-essential
sudo apt install -y bat
sudo apt install -y fd-find
sudo apt install -y fzf
wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
sudo chmod +x eza
sudo chown root:root eza
sudo mv eza /usr/local/bin/eza
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
sudo apt install neofetch
