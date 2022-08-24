#!/usr/bin/env bash

killall gpg-agent
gpg --refresh-keys
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring
