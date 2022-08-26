#!/usr/bin/env bash

######################################################################################################

AUR_HELPER="yay"


######################################################################################################

# Install Yay 
cd ~
git clone "https://aur.archlinux.org/$AUR_HELPER.git"
cd ~/$AUR_HELPER
makepkg -si --noconfirm
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



# Get dotfiles




putgitrepo() {
	# Downloads a gitrepo $1 and places the files in $2 only overwriting conflicts
	whiptail --infobox "Downloading and installing config files..." 7 60
	[ -z "$3" ] && branch="master" || branch="$repobranch"
	dir=$(mktemp -d)
	[ ! -d "$2" ] && mkdir -p "$2"
	chown "$name":wheel "$dir" "$2"
	sudo -u "$name" git -C "$repodir" clone --depth 1 \
		--single-branch --no-tags -q --recursive -b "$branch" \
		--recurse-submodules "$1" "$dir"
	sudo -u "$name" cp -rfT "$dir" "$2"
}

vimplugininstall() {
	# Installs vim plugins.
	whiptail --infobox "Installing neovim plugins..." 7 60
	mkdir -p "/home/$name/.config/nvim/autoload"
	curl -Ls "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" >  "/home/$name/.config/nvim/autoload/plug.vim"
	chown -R "$name:wheel" "/home/$name/.config/nvim"
	sudo -u "$name" nvim -c "PlugInstall|q|q"
}


# Install the dotfiles in the user's home directory, but remove .git dir and
# other unnecessary files.
putgitrepo "$dotfilesrepo" "/home/$name" "$repobranch"
rm -rf "/home/$name/.git/" "/home/$name/README.md" "/home/$name/LICENSE" "/home/$name/FUNDING.yml"

# Install vim plugins if not alread present.
[ ! -f "/home/$name/.config/nvim/autoload/plug.vim" ] && vimplugininstall

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
