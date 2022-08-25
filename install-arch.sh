#!/usr/bin/env bash

## ADD an option as to whether you just want the base system, ie no xorg ... OR your full fledged install

###############################################################################################
########################################  Settings  ###########################################
###############################################################################################

HOSTNAME="thinkpad"
USERNAME="wn"
TIMEZONE="Africa/Casablanca"
LOCALE="en_US.UTF-8"
BASE_SYSTEM=( base linux-lts linux-lts-headers linux-firmware neovim intel-ucode archlinux-keyring sudo )

user_password() {
    clear
    read -rs -p "Type the user & root password: " USERPW1
    echo -ne "\n"
    read -rs -p "Re-type the user & root password: " USERPW2
    echo -ne "\n"
    if [[ "$USERPW1" == "$USERPW2" ]]; then
        echo -e "\n Passwords match"
        sleep 2
    else
        echo -ne "ERROR! Passwords do not match. \n"
        user_password
    fi
}

user_password


###############################
###  Disk Partitioning TO BE COMPLETED
###############################

# To be changed, copy from Archtitus, it should be dynamic
IN_DEVICE=/dev/sda


umount -A --recursive /mnt # make sure everything is unmounted before we start
#parted ${device} mklabel msdos
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt





###############################
###  START SCRIPT HERE
###############################


# Setting up mirrors for optimal download
timedatectl set-ntp true
pacman -S --noconfirm archlinux-keyring 
pacman -S --noconfirm --needed pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --latest 50 --sort rate --save /etc/pacman.d/mirrorlist


###  Install base system
clear
pacstrap /mnt "${BASE_SYSTEM[@]}" --noconfirm --needed
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf


# GENERATE FSTAB
clear
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 2

## SET UP TIMEZONE AND LOCALE
clear
echo && echo "setting timezone to $TIMEZONE..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
arch-chroot /mnt hwclock --systohc --utc
arch-chroot /mnt date

## SET UP LOCALE
clear
echo && echo "setting locale to $LOCALE ..."
arch-chroot /mnt sed -i "s/#$LOCALE/$LOCALE/g" /etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
export LANG="$LOCALE"
cat /mnt/etc/locale.conf

## HOSTNAME
clear
echo && echo "Setting hostname..."; sleep 3
echo "$HOSTNAME" > /mnt/etc/hostname

cat > /mnt/etc/hosts <<HOSTS
127.0.0.1      localhost
::1            localhost
127.0.1.1      $HOSTNAME.localdomain     $HOSTNAME
HOSTS

echo && echo "/etc/hostname and /etc/hosts files configured..."
echo "/etc/hostname . . . "
cat /mnt/etc/hostname 
echo "/etc/hosts . . ."
cat /mnt/etc/hosts

## SET ROOT PASSWD
clear
arch-chroot /mnt useradd -mU -s /bin/bash -G wheel "${USERNAME}"
arch-chroot /mnt chpasswd <<< ""${USERNAME}":"${USERPW2}""
arch-chroot /mnt chpasswd <<< "root:"${USERPW2}""
arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers
arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers


echo -ne "
-------------------------------------------------------------------------
                    Setting up mirrors for optimal download 
-------------------------------------------------------------------------
"
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
arch-chroot /mnt pacman -S --noconfirm --needed pacman-contrib curl
arch-chroot /mnt pacman -S --noconfirm --needed reflector rsync grub arch-install-scripts git
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak


## INSTALLING MORE ESSENTIALS
clear
echo && echo "Enabling dhcpcd, pambase, sshd and NetworkManager services..." && echo
arch-chroot /mnt pacman -S --noconfirm --needed grub networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel linux-headers xdg-utils xdg-user-dirs openssh terminus-font
arch-chroot /mnt systemctl enable sshd.service
arch-chroot /mnt systemctl enable NetworkManager.service
echo "FONT=ter-128n.psf.gz" >> /mnt/etc/vconsole.conf 


## INSTALL GRUB
clear
echo "Installing grub..." && sleep 4
arch-chroot /mnt grub-install --target=i386-pc /dev/sda

echo "configuring /boot/grub/grub.cfg..."
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

[[ "$?" -eq 0 ]] && echo "mbr bootloader installed..."


# Get rid of the beep!
arch-chroot /mnt rmmod pcspkr
echo "blacklist pcspkr" >> /mnt/etc/modprobe.d/nobeep.conf


# Remove GRUB Delay & Add the hold shift option to show grub menu
clear
echo "Removing GRUB Delay"
echo "# achieve the fastest possible boot:" >> /mnt/etc/default/grub
echo 'GRUB_FORCE_HIDDEN_MENU="true"' >> /mnt/etc/default/grub
cp 31_hold_shift /mnt/etc/grub.d/
arch-chroot /mnt chmod a+x /mnt/etc/grub.d/31_hold_shift
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg


echo "Your system is installed.  Type shutdown -h now to shutdown system and remove bootable media, then restart"
read empty

