#!/usr/bin/env bash

######################################################################################################

AUR_HELPER="yay"
USERNAME="wn"
GITLAB_USER="waildots"
GITLAB_REPO="dots"
GITHUB_USER="wailnotes"
GITHUB_REPO=

######################################################################################################

# Install Yay 
cd /home/$USERNAME
git clone "https://aur.archlinux.org/$AUR_HELPER.git"
cd /home/$USERNAME/$AUR_HELPER
makepkg -si --noconfirm
cd /home/$USERNAME
rm -r /home/$USERNAME/$AUR_HELPER

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

pacman -S --noconfirm --needed git
git clone https://gitlab.com/"$GITLAB_USER"/"$GITLAB_REPO".git
rm -fr "$GITLAB_REPO"/.git
cp -R "$GITHUB_REPO"/* /home/"${$USERNAME}"/
rm -fr "$GITHUB_REPO"


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
