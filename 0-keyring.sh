#!/usr/bin/env bash

# https://bbs.archlinux.org/viewtopic.php?id=273781

killall gpg-agent
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring
