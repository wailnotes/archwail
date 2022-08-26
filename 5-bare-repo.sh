#!/usr/bin/env bash

#----------------#

AUR_HELPER="yay"
USERNAME="wn"

#----------------#


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# setup the bare git repo
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#cd /home/$USERNAME
#mkdir dots
#config config --local status.showUntrackedFiles no
#
#git clone the dots repo
#list all the file paths in it
#put them in a file
#config add /path/to/file ## See (X)
#config commit -m "A short message"
#config push

# (X) Is it possible to `git add` a list of files from a file? [duplicate]
#https://stackoverflow.com/questions/22569497/is-it-possible-to-git-add-a-list-of-files-from-a-file

xargs -a file -d '\n' git add
