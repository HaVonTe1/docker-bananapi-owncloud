#!/usr/bin/env bash
set -eu -o pipefail

# enable/disable webdav
if [ "$ENABLE_DAV" = true ] ; then
  sed -i '$a Include conf/extra/httpd-dav.conf' /etc/httpd/conf/httpd.conf
else
  sed -i '/Include conf\/extra\/httpd-dav.conf/d' /etc/httpd/conf/httpd.conf
fi

# enable/disable non-https (unencrypted over port 80) apache access
if [ "$ALLOW_INSECURE" = true ] ; then
  sed -i 's,#Listen 80,Listen 80,g' /etc/httpd/conf/httpd.conf
else
  sed -i 's,Listen 80,#Listen 80,g' /etc/httpd/conf/httpd.conf
fi

# the systemd services generally create these folders, make them now manually
mkdir -p /run/httpd

# make sure apache knows the proper server name
sed -i "s/^ServerName .*/ServerName $(hostname --fqdn)/g" /etc/httpd/conf/httpd.conf

[ "$DO_SSL_SELF_GENERATION" = true ] && setup-apache-ssl-key
[ "$START_APACHE" = true ] && apachectl start
[ "$DO_SSL_LETS_ENCRYPT_FETCH" = true ] && setup-apache-ssl-key
[ "$ENABLE_CRON" = true ] && crond
