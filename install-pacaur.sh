#!/usr/bin/env bash
set -x -u -o pipefail

cd /tmp/pacaur_install


export PATH=$PATH:/usr/bin/core_perl
# Install "pacaur" from AUR
curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
su owncloud -c 'makepkg PKGBUILD'
pacman -U pacaur*.tar.xz --noconfirm

# Clean up...
cd ~
rm -r /tmp/pacaur_install
