#!/usr/bin/env bash

#----------------#

AUR_HELPER="yay"
USERNAME="wn"

#----------------#

clear
echo -ne "
-------------------------------------------------------------------------
                        Installing $AUR_HELPER
-------------------------------------------------------------------------
"

cd /home/$USERNAME
git clone "https://aur.archlinux.org/$AUR_HELPER.git"
cd /home/$USERNAME/$AUR_HELPER
makepkg -si --noconfirm
cd /home/$USERNAME
rm -rf /home/$USERNAME/$AUR_HELPER


clear
echo -ne "
-------------------------------------------------------------------------
                     Getting the fastest Mirrors
-------------------------------------------------------------------------
"
sudo reflector --latest 200 --sort rate --save /etc/pacman.d/mirrorlist


clear
echo -ne "
-------------------------------------------------------------------------
                         Installing Packages
-------------------------------------------------------------------------
"

sudo pacman -S --noconfirm --needed wget

# Getting the packages lists
cd /home/$USERNAME
wget https://gitlab.com/waildots/dots/-/raw/master/.config/epackages.txt
wget https://gitlab.com/waildots/dots/-/raw/master/.config/aurpackages.txt

sudo pacman -S --noconfirm --needed - < epackages.txt
$AUR_HELPER -S --noconfirm --needed - < aurpackages.txt

# Adb sync
#git clone https://github.com/google/adb-sync
#cd adb-sync
#cp adb-sync /usr/local/bin/

# Enabling services
systemctl --user enable mpd.service
sudo systemctl enable bluetooth.service
#sudo gpasswd -a $USERS vboxusers
#sudo modprobe vboxdrv

clear
echo -ne "
-------------------------------------------------------------------------
                      Installing Suckless Programs
-------------------------------------------------------------------------
"

install_suckless() {
    cd /home/$USERNAME
    git clone https://gitlab.com/waildots/$1.git
    cd /home/$USERNAME/$1
    sudo make clean install
    cd /home/$USERNAME
    rm -rf $1/
}

install_suckless dwm
install_suckless dwmblocks
install_suckless st
# install_suckless slock #Add an slock repo


clear
echo -ne "
-------------------------------------------------------------------------
                         Restoring dotfiles
-------------------------------------------------------------------------
"

# dots
cd /home/$USERNAME
sudo pacman -S --noconfirm --needed git
git clone -b master https://gitlab.com/waildots/dots.git
rm -fr dots/.git
cp -rfv dots/* /home/$USERNAME/
cp -rfv dots/.* /home/$USERNAME/
rm -fr dots
sudo mkdir /etc/X11/xorg.conf.d/
sudo cp -f /home/$USERNAME/.config/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
sudo cp -f /home/$USERNAME/.config/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf


vimplugininstall() {
	# Installs vim plugins.
	mkdir -p "/home/$USERNAME/.config/nvim/autoload"
	curl -Ls "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" >  "/home/$USERNAME/.config/nvim/autoload/plug.vim"
	chown -R "$USERNAME:wheel" "/home/$USERNAME/.config/nvim"
	sudo -u "$USERNAME" nvim -c "PlugInstall|q|q"
}

# Install vim plugins if not alread present.
[ ! -f "/home/$USERNAME/.config/nvim/autoload/plug.vim" ] && vimplugininstall


# Android
sed -i 's/^#user_allow_other/user_allow_other/' /etc/fuse.conf


clear
echo -ne "
-------------------------------------------------------------------------
                     Cleaning the home directory
-------------------------------------------------------------------------
"
rm /home/$USERNAME/epackages.txt
rm /home/$USERNAME/aurpackages.txt

remove_if_empty() {
    if [ -z "$(ls -A $1)" ]; then
    rm -rf $1
    else
    mv -v $1/* /home/$USERNAME/dl
    rm -rf $1
    fi
}

mkdir pc dl temp
remove_if_empty /home/$USERNAME/Desktop
remove_if_empty /home/$USERNAME/Downloads
remove_if_empty /home/$USERNAME/Documents
remove_if_empty /home/$USERNAME/Music
remove_if_empty /home/$USERNAME/Pictures
remove_if_empty /home/$USERNAME/Public
remove_if_empty /home/$USERNAME/Templates
remove_if_empty /home/$USERNAME/Videos

xdg-user-dirs-update

printf "\n"
ls -lAh --color --group-directories-first

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Setup QEMU
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------



