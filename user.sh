#!/usr/bin/env bash

######################################################################################################

AUR_HELPER="yay"
USERNAME="wn"
DOTS_REPO="https://gitlab.com/waildots/dots.git"

######################################################################################################

# Install Yay 
cd /home/$USERNAME
git clone "https://aur.archlinux.org/$AUR_HELPER.git"
cd /home/$USERNAME/$AUR_HELPER
makepkg -si --noconfirm
cd /home/$USERNAME
rm -rf /home/$USERNAME/$AUR_HELPER

####################### $AUR_HELPER -S --noconfirm --needed ${line}

# video driver
pacman -S --noconfirm --needed xf86-video-intel libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils


# xorg
pacman -S --needed --noconfirm xorg xorg-xinit


# Install Packages
pacman -S --noconfirm --needed - < epackages.txt
pacman -S --noconfirm --needed - < aurpackages.txt


# vim Plug

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'





# enable services

systemctl --user enable mpd.service
sudo systemctl enable bluetooth.service


# Get fonts

git clone https://gitlab.com/waildots/linux-fonts.git
sudo fc-cache -fv


##########################################################################################################################################################################
# Get dotfiles
##########################################################################################################################################################################

# dots
cd /home/$USERNAME
sudo pacman -S --noconfirm --needed git
git clone -b master $DOTS_REPO
rm -fr $DOTS_REPO/.git
cp -rfv $DOTS_REPO/* /home/$USERNAME/
cp -rfv $DOTS_REPO/.* /home/$USERNAME/
rm -fr $DOTS_REPO


install_suckless() {
    cd /home/$USERNAME
    git clone https://gitlab.com/waildots/$1.git
    cd /home/$USERNAME/$1
    sudo make clean install
    cd /home/$USERNAME
    rm -rf $1/
}

install_suckless dwmblocks



#----


# Enable services
systemctl --user enable mpd.service
sudo systemctl enable bluetooth.service


# Setup virtualbox
sudo gpasswd -a $USERS vboxusers
sudo modprobe vboxdrv



# Adb sync
git clone https://github.com/google/adb-sync
cd adb-sync
cp adb-sync /usr/local/bin/
