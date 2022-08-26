#!/usr/bin/env bash

########################################  Settings  ###########################################

HOSTNAME="thinkpad"
USERNAME="wn"
TIMEZONE="Africa/Casablanca"
LOCALE="en_US.UTF-8"
BASE_SYSTEM=( base linux-lts linux-lts-headers linux-firmware neovim intel-ucode archlinux-keyring sudo )

###############################################################################################

# Set User and root password (they're the same)

user_password() {
    read -rs -p "password (user & root) = " USERPW1
    echo -ne "\n"
    read -rs -p "Re-type the password = " USERPW2
    echo -ne "\n"
    if [[ "$USERPW1" == "$USERPW2" ]]; then
        echo -e "\n Passwords match"
    else
        echo -ne "ERROR! Passwords do not match. \n"
        user_password
    fi
}

clear
echo -ne "
-------------------------------------------------------------------------
                            User Settings
-------------------------------------------------------------------------
"
echo "Username = "$USERNAME""
echo "Hostname = "$HOSTNAME""
echo "Timezone = "$TIMEZONE""
echo "Locale = "$LOCALE""

user_password

clear

###############################################################################################

select_option() {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "$2   $1 "; }
    print_selected()   { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    get_cursor_col()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${COL#*[}; }
    key_input()         {
                        local key
                        IFS= read -rsn1 key 2>/dev/null >&2
                        if [[ $key = ""      ]]; then echo enter; fi;
                        if [[ $key = $'\x20' ]]; then echo space; fi;
                        if [[ $key = "k" ]]; then echo up; fi;
                        if [[ $key = "j" ]]; then echo down; fi;
                        if [[ $key = "h" ]]; then echo left; fi;
                        if [[ $key = "l" ]]; then echo right; fi;
                        if [[ $key = "a" ]]; then echo all; fi;
                        if [[ $key = "n" ]]; then echo none; fi;
                        if [[ $key = $'\x1b' ]]; then
                            read -rsn2 key
                            if [[ $key = [A || $key = k ]]; then echo up;    fi;
                            if [[ $key = [B || $key = j ]]; then echo down;  fi;
                            if [[ $key = [C || $key = l ]]; then echo right;  fi;
                            if [[ $key = [D || $key = h ]]; then echo left;  fi;
                        fi 
    }
    print_options_multicol() {
        # print options by overwriting the last lines
        local curr_col=$1
        local curr_row=$2
        local curr_idx=0

        local idx=0
        local row=0
        local col=0
        
        curr_idx=$(( $curr_col + $curr_row * $colmax ))
        
        for option in "${options[@]}"; do

            row=$(( $idx/$colmax ))
            col=$(( $idx - $row * $colmax ))

            cursor_to $(( $startrow + $row + 1)) $(( $offset * $col + 1))
            if [ $idx -eq $curr_idx ]; then
                print_selected "$option"
            else
                print_option "$option"
            fi
            ((idx++))
        done
    }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local return_value=$1
    local lastrow=`get_cursor_row`
    local lastcol=`get_cursor_col`
    local startrow=$(($lastrow - $#))
    local startcol=1
    local lines=$( tput lines )
    local cols=$( tput cols ) 
    local colmax=$2
    local offset=$(( $cols / $colmax ))

    local size=$4
    shift 4

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local active_row=0
    local active_col=0
    while true; do
        print_options_multicol $active_col $active_row 
        # user key control
        case `key_input` in
            enter)  break;;
            up)     ((active_row--));
                    if [ $active_row -lt 0 ]; then active_row=0; fi;;
            down)   ((active_row++));
                    if [ $active_row -ge $(( ${#options[@]} / $colmax ))  ]; then active_row=$(( ${#options[@]} / $colmax )); fi;;
            left)     ((active_col=$active_col - 1));
                    if [ $active_col -lt 0 ]; then active_col=0; fi;;
            right)     ((active_col=$active_col + 1));
                    if [ $active_col -ge $colmax ]; then active_col=$(( $colmax - 1 )) ; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $(( $active_col + $active_row * $colmax ))
}

echo -ne "
-------------------------------------------------------------------------
                            Disk Partionning
-------------------------------------------------------------------------
"

lsblk

echo "Select the disk to install on: "
options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))

select_option $? 1 "${options[@]}"
IN_DEVICE=${options[$?]%|*}

umount -A --recursive /mnt # make sure everything is unmounted before we start
parted ${IN_DEVICE} mklabel msdos
echo -e "n\np\n\n\n\nw" | fdisk ${IN_DEVICE}
mkfs.ext4 "${IN_DEVICE}"\1
mount "${IN_DEVICE}"\1 /mnt

lsblk
sleep 3

clear
echo -ne "
-------------------------------------------------------------------------
                 Setting up mirrors for optimal download
-------------------------------------------------------------------------
"

# Setting up mirrors for optimal download
timedatectl set-ntp true
pacman -S --noconfirm archlinux-keyring 
pacman -S --noconfirm --needed pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --latest 50 --sort rate --save /etc/pacman.d/mirrorlist


clear
echo -ne "
-------------------------------------------------------------------------
                               Pacstrap
-------------------------------------------------------------------------
"

###  Install base system
pacstrap /mnt "${BASE_SYSTEM[@]}" --noconfirm --needed
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf

clear
echo -ne "
-------------------------------------------------------------------------
                               FSTAB
-------------------------------------------------------------------------
"

# GENERATE FSTAB
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 2

clear
echo -ne "
-------------------------------------------------------------------------
                       TIMEZONE, LOCALE, HOST
-------------------------------------------------------------------------
"

## SET UP TIMEZONE AND LOCALE
echo && echo "setting timezone to $TIMEZONE..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
arch-chroot /mnt hwclock --systohc --utc
arch-chroot /mnt date

## SET UP LOCALE
echo && echo "setting locale to $LOCALE ..."
arch-chroot /mnt sed -i "s/#$LOCALE/$LOCALE/g" /etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
export LANG="$LOCALE"
cat /mnt/etc/locale.conf

## HOSTNAME
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



echo -ne "
-------------------------------------------------------------------------
                    Adding User
-------------------------------------------------------------------------
"

## SET ROOT PASSWD
arch-chroot groupadd libvirt
arch-chroot /mnt useradd -mU -s /bin/bash -G wheel,libvirt "${USERNAME}"
arch-chroot /mnt chpasswd <<< ""${USERNAME}":"${USERPW2}""
arch-chroot /mnt chpasswd <<< "root:"${USERPW2}""
arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers
arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
echo "$USERNAME created, home directory created, added to wheel and libvirt group, default shell set to /bin/bash"


clear
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


clear
echo -ne "
-------------------------------------------------------------------------
                       INSTALLING MORE ESSENTIALS
-------------------------------------------------------------------------
"
## INSTALLING MORE ESSENTIALS
arch-chroot /mnt pacman -S --noconfirm --needed networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel xdg-utils xdg-user-dirs openssh terminus-font
arch-chroot /mnt systemctl enable sshd.service
arch-chroot /mnt systemctl enable NetworkManager.service
echo "FONT=ter-128n.psf.gz" >> /mnt/etc/vconsole.conf 


clear
echo -ne "
-------------------------------------------------------------------------
                                 GRUB
-------------------------------------------------------------------------
"
## INSTALL GRUB
echo "Installing grub..." && sleep 4
arch-chroot /mnt grub-install --target=i386-pc ${IN_DEVICE}

echo "configuring /boot/grub/grub.cfg..."
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

[[ "$?" -eq 0 ]] && echo "mbr bootloader installed..."


# Remove GRUB Delay & Add the hold shift option to show grub menu
echo "Removing GRUB Delay"
echo "# achieve the fastest possible boot:" >> /mnt/etc/default/grub
echo 'GRUB_FORCE_HIDDEN_MENU="true"' >> /mnt/etc/default/grub
cp ~/archwail/31_hold_shift /mnt/etc/grub.d/
chmod a+x /mnt/etc/grub.d/31_hold_shift
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Get rid of the beep!
arch-chroot /mnt rmmod pcspkr
echo "blacklist pcspkr" >> /mnt/etc/modprobe.d/nobeep.conf


#-------------------------------------------------------------------------

# Install vbox guest addition
hypervisor=$(systemd-detect-virt)
if [[ !"$hypervisor" == "none" ]]; then
clear
echo -ne "
-------------------------------------------------------------------------
                         Virtualbox Setup
-------------------------------------------------------------------------
"

virt_check () {
    hypervisor=$(systemd-detect-virt)
    case $hypervisor in
        kvm )   info_print "KVM has been detected, setting up guest tools."
                pacstrap /mnt qemu-guest-agent &>/dev/null
                systemctl enable qemu-guest-agent --root=/mnt &>/dev/null
                ;;
        vmware  )   info_print "VMWare Workstation/ESXi has been detected, setting up guest tools."
                    pacstrap /mnt open-vm-tools >/dev/null
                    systemctl enable vmtoolsd --root=/mnt &>/dev/null
                    systemctl enable vmware-vmblock-fuse --root=/mnt &>/dev/null
                    ;;
        oracle )    info_print "VirtualBox has been detected, setting up guest tools."
                    pacstrap /mnt virtualbox-guest-utils &>/dev/null
                    echo "vboxguest" >> /etc/modules-load.d/virtualbox.conf
                    echo "vboxsf" >> /etc/modules-load.d/virtualbox.conf
                    echo "vboxvideo" >> /etc/modules-load.d/virtualbox.conf
                    systemctl enable vboxservice --root=/mnt &>/dev/null
                    ;;
        microsoft ) info_print "Hyper-V has been detected, setting up guest tools."
                    pacstrap /mnt hyperv &>/dev/null
                    systemctl enable hv_fcopy_daemon --root=/mnt &>/dev/null
                    systemctl enable hv_kvp_daemon --root=/mnt &>/dev/null
                    systemctl enable hv_vss_daemon --root=/mnt &>/dev/null
                    ;;
    esac
}


echo "Your system is installed.  Type shutdown -h now to shutdown system and remove bootable media, then restart"
read empty
