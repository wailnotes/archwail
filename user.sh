#!/usr/bin/env bash

AUR_HELPER="yay"

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

# Install Yay 
cd ~
git clone "https://aur.archlinux.org/$AUR_HELPER.git"
cd ~/$AUR_HELPER
makepkg -si --noconfirm
####################### $AUR_HELPER -S --noconfirm --needed ${line}


# Graphics Drivers find and install
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed nvidia
	nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa


# xorg
pacman -S --needed --noconfirm xorg xorg-xinit



# vim Plug

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'





# enable services

systemctl --user enable mpd.service
sudo systemctl enable bluetooth.service


# Get fonts

git clone https://gitlab.com/waildots/linux-fonts.git
sudo fc-cache -fv






