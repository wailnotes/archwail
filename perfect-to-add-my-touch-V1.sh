#!/usr/bin/env bash

# https://deepbsd.github.io/linux/arch/2021/02/24/Arch_Linux_Install_Script.html


# Settings
HOSTNAME="thinkpad"
IN_DEVICE=/dev/sda
USERNAME="wn"
LANGUAGE="en_US"
KEYBOARD="us"
TIMEZONE="Africa/Casablanca"
LOCALE="en_US.UTF-8"
AURHELPER="yay"
BASE_SYSTEM=( base linux-lts linux-lts-headers linux-firmware neovim intel-ucode archlinux-keyring )

# ------------------------------------------------------------------------------------------------------------------------------------------------------


umount -A --recursive /mnt # make sure everything is unmounted before we start
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt


###############################
###  START SCRIPT HERE
###############################


# Set time

timedatectl set-ntp true

# Setting up mirrors for optimal download

pacman -S --noconfirm archlinux-keyring 
pacman -S --noconfirm --needed pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --latest 50 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt &>/dev/null # Hiding error message if any


###  Install base system
clear
pacstrap /mnt "${BASE_SYSTEM[@]}"
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

# GENERATE FSTAB
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

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
echo "Setting ROOT password..."
arch-chroot /mnt passwd

## INSTALLING MORE ESSENTIALS
clear
echo && echo "Enabling dhcpcd, pambase, sshd and NetworkManager services..." && echo
arch-chroot /mnt pacman -S git openssh networkmanager dhcpcd man-db man-pages pambase
arch-chroot /mnt systemctl enable dhcpcd.service
arch-chroot /mnt systemctl enable sshd.service
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable systemd-homed

## ADD USER ACCT
clear
echo && echo "Adding sudo + user acct..."
sleep 2
arch-chroot /mnt pacman -S sudo bash-completion sshpass
arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers
arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
echo && echo "Please provide a username: "; read sudo_user
echo && echo "Creating $sudo_user and adding $sudo_user to sudoers..."
arch-chroot /mnt useradd -m -G wheel "$sudo_user"
echo && echo "Password for $sudo_user?"
arch-chroot /mnt passwd "$sudo_user"


## INSTALL GRUB
clear
echo "Installing grub..." && sleep 4
arch-chroot /mnt pacman -S grub os-prober

## We're not checking for EFI; We're assuming MBR
arch-chroot /mnt grub-install --target=i386-pc /dev/sda


echo "configuring /boot/grub/grub.cfg..."
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

[[ "$?" -eq 0 ]] && echo "mbr bootloader installed..."

echo "Your system is installed.  Type shutdown -h now to shutdown system and remove bootable media, then restart"
read empty
