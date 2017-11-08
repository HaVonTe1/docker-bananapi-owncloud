#!/usr/bin/env bash
set -x -e -u -v -o pipefail

# owncloud itself
#gpg --recv-key 2D5D5E97F6978A26
su owncloud -c 'gpg --recv-key 2D5D5E97F6978A26'

mkdir /tmp/owncloud_install
chown owncloud:owncloud -R /tmp/owncloud_install
cd /tmp/owncloud_install
cp /home/owncloud/PKGBUILD_OWNCLOUD PKGBUILD 
cp /home/owncloud/owncloud-archive.install .

export PATH=$PATH:/usr/bin/core_perl
su owncloud -c 'makepkg -L PKGBUILD'
#  install -D -m755 "${srcdir}/../set-oc-perms.sh" "${pkgdir}/usr/bin/set-oc-perms"
#  install -m644 -D "${srcdir}/../apache.example.conf" -t "${pkgdir}/etc/webapps/owncloud"
cp /home/owncloud/set-oc-perms.sh /usr/bin/set-oc-perms
mkdir /etc/webapps/owncloud
cp /home/owncloud/apache.example.conf /etc/webapps/owncloud/apache.example.conf

chmod 755 /usr/bin/set-oc-perms
chmod 644 /etc/webapps/owncloud/apache.example.conf

# Install "owncloud" from AUR using local build file
su owncloud -c 'pacman -U owncloud-archive*.tar.xz --noconfirm --needed --noedit -m --noprogressbar'

#su owncloud -c 'pacaur -m --noprogressbar --noedit --noconfirm owncloud-archive'
#pacman -U --noconfirm --needed /home/owncloud/.cache/pacaur/owncloud-archive/owncloud-archive-${OC_VERSION}-any.pkg.tar.xz

# install some apps
pacman -S --noconfirm --noprogress --needed owncloud-app-bookmarks owncloud-app-calendar owncloud-app-contacts owncloud-app-documents

# setup Apache for owncloud
cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
sed -i 's,Alias /owncloud "/usr/share/webapps/owncloud",Alias /${TARGET_SUBDIR} "/usr/share/webapps/owncloud",g' /etc/httpd/conf/extra/owncloud.conf
sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf

# reduce docker layer size
# remove all cached package archives
paccache -r -k0

# remove all the manual files
rm -rf /usr/share/man/*

# clean tmp folders
rm -rf /tmp/*
rm -rf /var/tmp/*

