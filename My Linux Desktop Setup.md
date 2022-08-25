---
aliases:
---

---

[type:: #setup]
[tags::  ]
[links::]

---

# Install arch 

## Refrech pacman 

```
Pacman -Syyy
```

Have the fastest mirrors

```
Pacman -S reflector
```

## Partition the disk 

```
fdisk /dev/DEVICE NAME
```

- d : delete a partition
- n : create a new partition 
- w : write changes

## Format partitions 

```
mkfs.ext4 /dev/PARTITION
```


## mount the root partition 

```
mount /dev/PARTITION /mnt
```


## Pacstrap 

NEW : pacman keyring ...

```
pacstrap /mnt base linux linux-firmware neovim intel-ucode
```

## FSTAB file

```
genfstab -U /mnt >> /mnt/etc/fstab
```

## Chroot 

```
arch-chroot /mnt
```

## Timezone

```
ln -sf /usr/share/zoneinfo/Africa/Casablanca /etc/localtime
```

```
hwclock --systohc
```

```
nvim /etc/locale.gen
```


=> Uncomment the one with en_US.UTF-8

```
locale-gen
```


```
nvim /etc/locale.conf
```

=> LANG=en_US.UTF-8

## Hostname

```
nvim /etc/hostname
```

=> HOST NAME

```
nvim /etc/hosts
```

=> Insert the following 

```
127.0.0.1        localhost
::1              localhost
127.0.1.1        HOST NAME.localdomain           HOST NAME
```


## Root password 

```
passwd
```

=> set root password

## Download grub and other packages 

```
pacman -S grub networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel linux-headers xdg-utils xdg-user-dirs
```

## Install grub 

```
grub-install --target=i386-pc /dev/DISK
```

```
grub-mkconfig -o /boot/grub/grub.cfg
```

## enable services

```
systemctl enable NetworkManager
```

## add a new user

```
useradd -mG wheel USERNAME
```

```
passwd USERNAME
```

```
EDITOR=nvim visudo
```

=> uncomment the line to give yourself permissions (wheel group)

## reboot

```
exit
umount -a
reboot
```

## install video driver

```
sudo pacman -S xf86-video-intel
```

## install xorg
```
sudo pacman -S xorg
```

## install yay 

```
sudo pacman -S git
git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si PKGBUILD
```

## install lts kernel

```
sudo pacman -S linux-lts linux-lts-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg
reboot
uname -r
```


## disable grub delay 

```
nvim /etc/default/grub
```

=> add the following

```
# achieve the fastest possible boot: 
GRUB_FORCE_HIDDEN_MENU="true"
```

```
cd /etc/grub.d/
sudo touch 31_hold_shift
sudo chmod a+x /etc/grub.d/31_hold_shift
sudo grub-mkconfig -o /boot/grub/grub.cfg
```


## # Reinstall packages 

```
sudo pacman -S --needed - < epackages.txt
```

## Install vim plug 

```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

## enable mpd.service
```
systemctl --user enable mpd.service
```


## bluetooth

```
sudo pacman -S bluez bluez-utils blueberry
sudo systemctl enable bluetooth.service
```

## setup virtualbox

```
sudo gpasswd -a $USERS vboxusers
sudo modprobe vboxdrv
```


## Fonts
=> back up fonts in a git repo
=> get google fonts and microsoft fonts
=> move all to /usr/share/fonts

```
sudo fc-cache -fv
```

### console font

```
sudo -e /etc/vconsole.conf
```

=> Add the following line

```
FONT=ter-128n.psf.gz
```

## set up a git repo 

```jsx
git init --bare $HOME/dots
alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME' (add this alias to .bashrc)
config config --local status.showUntrackedFiles no
```

Basic usage example:

```jsx
config add /path/to/file
config commit -m "A short message"
config push
```

## Update mirrors

```
sudo reflector --latest 200 --sort rate --save /etc/pacman.d/mirrorlist
```

## Same theme for Qt/KDE applications and GTK applications, and fix missing indicators

First install `qt5-style-plugins` (debian) | `qt5-styleplugins` (arch) and add this to the bottom of your `/etc/environment`

```
XDG_CURRENT_DESKTOP=Unity
QT_QPA_PLATFORMTHEME=gtk2
```

The first variable fixes most indicators (especially electron based ones!), the second tells Qt and KDE applications to use your gtk2 theme set through lxappearance.



=> qt5ct




## Setup QEMU




 `timedatectl set-ntp true`



## Spring cleaning the home directory 

Put config files ... in their respective folders according the XDG specs



## Optimize boot time 

https://www.youtube.com/watch?v=JSW0ODq-D9M




adb-sync



## Android Mounting
First edit your `/etc/fuse.conf` and uncomment the following line:

```
user_allow_other
```



---

- screen tearing
- bluetooth
	- use a command line / script / rofi menu instead of blueberry gui
	- https://arcolinux.com/how-to-autoconnect-your-bluetooth-headset-to-arcolinux-any-desktop/
- printing
- graphics
- speed up boot time (there is a video about it)
- use the script by the indian dude to watch TV shows just with a script
- power management
	- tlp/powertop ? 
- automount hdd and android phone when plugged (check adrienlinux video)
	- How to change or set permissions on a symbolic link
- configure redshift
- default apps
- try Quickemu for VMs
	- https://frontpagelinux.com/tutorials/how-to-use-linux-kvm-to-optimize-your-windows-10-virtual-machine/
	- https://www.youtube.com/watch?v=ZqBJzrQy7Do
	- https://jochendelabie.com/2020/05/15/hyper-v-enlightenments-with-libvirt/
	- https://www.heiko-sieger.info/running-windows-10-on-linux-using-kvm-with-vga-passthrough/
	- https://unix.stackexchange.com/questions/47082/how-to-improve-windows-perfomance-when-running-inside-kvm
	- https://www.funtoo.org/Windows_10_Virtualization_with_KVM
	- https://blog.jdpfu.com/2012/07/30/improving-kvm-performance
	- https://blog.jdpfu.com/2010/06/22/virtualbox-performance-improved
	- https://github.com/quickemu-project/quickemu
	- https://www.reddit.com/r/kvm/comments/rc1try/is_it_possible_to_start_an_qemukvm_vm_with_startx/
	- https://www.youtube.com/watch?v=IBqIwcD9NjI
	- https://www.reddit.com/r/kvm/comments/qmai9w/overall_what_is_the_current_performance_of/
	- https://www.google.com/search?q=shortcut+to+fullscreen+qemu&oq=shortcut+to+fullscreen+qemu&aqs=chrome..69i57.8029j0j1&sourceid=chrome&ie=UTF-8
	- https://unix.stackexchange.com/questions/207012/how-to-send-upload-a-file-from-host-os-to-guest-os-in-kvmnot-folder-sharing
	- https://stackoverflow.com/questions/44047668/yocto-how-to-copy-folder-to-target-device-qemu
	- https://www.cnx-software.com/2011/09/29/how-to-transfer-files-between-host-and-qemu/
	- https://cialu.net/qemu-kvm-on-ubuntu-and-sharing-files-between-host-and-guests/
	- https://www.reddit.com/r/archlinux/comments/bfppd2/a_recommended_way_to_move_data_between_host_and/
	- https://community.clearlinux.org/t/share-clipboard-and-file-transfer-between-host-and-kvm-qemu-guest/4689/9

there is a package called virtio-win that has Windows drivers for all the virtio devices. Totally worth it:

[https://aur.archlinux.org/packages/virtio-win/](https://aur.archlinux.org/packages/virtio-win/)


- what are pacman keys
- microcode (intel microcode)
- github/gitlab ? 
- ssh
- 




---

- [ ] integrate tsp into tmux
- [ ] what is a polkit agent
- [ ] use tabbed ?
- [ ] auto mount hard drives and phone 

---


- Cloud services
	- use rclone-browser to rule them all

When we want to restore our packages we use the following command
`yay -S --needed - < TXTFILENAME.TXT`

List of packages from the official repos (no AUR packages)
`sudo pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort packages.txt)`

