#!/usr/bin/env bash
set -x -u -o pipefail


groupadd owncloud
useradd -g owncloud -s /bin/bash -d /home/owncloud owncloud
mkdir -p /home/owncloud
chown -R owncloud:owncloud /home/owncloud

# Make sure our shiny new arch is up-to-date
echo "Checking for system updates..."
pacman -Syu

# Create a tmp-working-dir an navigate into it
mkdir -p /tmp/pacaur_install
chmod a+w /tmp/pacaur_install
cd /tmp/pacaur_install

# If you didn't install the "base-devil" group,
# we'll need those.
pacman -S binutils make gcc fakeroot --noconfirm

# Install pacaur dependencies from arch repos
pacman -S expac yajl git perl-podlators --noconfirm

# Install "cower" from mirrot - needed by pacaur
curl -v -O http://de3.mirror.archlinuxarm.org/armv7h/aur/cower-17-2-armv7h.pkg.tar.xz
pacman -U cower-17-2-armv7h.pkg.tar.xz --noconfirm

# install "sudo" from mirror - needed by pacaur
curl -v -O http://de4.mirror.archlinuxarm.org/armv7h/core/sudo-1.8.21.p2-1-armv7h.pkg.tar.xz
pacman -U  sudo-1.8.21.p2-1-armv7h.pkg.tar.xz --noconfirm

