#!/usr/bin/env bash

#----------------#

AUR_HELPER="yay"
USERNAME="wn"

#----------------#


clear
echo -ne "
-------------------------------------------------------------------------
                         Restoring Fonts
-------------------------------------------------------------------------
"

# Get fonts
cd /home/$USERNAME
git clone https://gitlab.com/waildots/linux-fonts.git
rm -fr linux-fonts/.git
sudo cp -fr linux-fonts/* /usr/share/fonts/
fc-cache -fv
rm -rf linux-fonts


