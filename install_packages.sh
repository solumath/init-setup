#!/bin/sh
INSTALL="copyq docker docker-compose ffmpeg flake8 gimp git gnome-shell-extension-manager gnome-tweaks
gparted htop libdvd-pkg libdvdnav4 mpv nomacs neofetch opera-stable python3-pip steam tmux 
ubuntu-restricted-extras xsel"
DOWNLOAD="https://discord.com/api/download?platform=linux&format=deb 
https://go.microsoft.com/fwlink/?LinkID=760868 
https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb 
https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-6.22.515-Linux-x64.deb 
https://www.gitkraken.com/download/linux-deb 
https://download.opera.com/download/get/?partner=www&opsys=Linux"
REMOVE="firefox remina"

apt-get update

# download and install apps
for url in $DOWNLOAD
do 
    wget -O package.deb $url
    sudo dpkg -i package.deb
done
rm package.deb

# install packages
apt-get install -y $INSTALL
apt purge $REMOVE

# setup grub theme
tar -xf vimix.tar.xz
cd Vimix-1080p
./install.sh&

# copy dotfiles
cp -r dotfiles/* ~/

# copy gnome terminal profile
dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf
dconf dump / < saved_settings.dconf