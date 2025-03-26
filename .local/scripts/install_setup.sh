#/bin/bash 
echo "Configure Vconsole"

sudo pacman -S terminus-font
sudo bash -c 'echo "FONT=ter-128b" >> /etc/vconsole.conf'

echo "Installing Useful Utils"

sudo pacman -S jq tree ripgrep fzf man tldr whois pciutils usbutils iputils binutils dnsutils exa

echo "Installing Cli tools"

sudo pacman -S openssh ntfs-3g xdg-user-dirs android-tools wget curl tar unzip zip p7zip

echo "installing Cli applications"

sudo pacman -S git tmux vim neovim ansible cloc alacritty ghostty htop fastfetch pass pass-otp docker docker-compose flatpak

echo "Installing fonts"

sudo pacman -S awesome-terminal-fonts ttf-hack ttf-jetbrains-mono ttf-jetbrains-mono-nerd

echo "Installing Shell"

sudo pacman -S zsh starship zsh-autosuggestions zsh-syntax-highlighting

echo "Installing Bluetooth"

sudo pacman -S bluez bluez-utils

echo "Enabling System Services"
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable docker
sudo systemctl enable containerd

echo "Configuring Docker"
sudo groupadd docker
sudo usermod -aG docker $USER

echo "Setting up dotfies"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc
git clone --bare git@github.com:abhishek-kaith/dotfiles $HOME/.cfg
echo  "NOTE add .cfg in gitignore"
echo  "config config --local status.showUntrackedFiles no"
git clone git@github.com:abhishek-kaith/dotfiles $HOME/.dotfiles

echo "Install flatpaks"
flatpak install app.zen_browser.zen/x86_64/stable

echo "Setting Up Node.js"
curl https://get.volta.sh | bash

VOLTA_HOME=$HOME/.volta
export PATH=$VOLTA_HOME/bin

volta install node@lts
