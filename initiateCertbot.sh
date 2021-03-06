#!/usr/bin/env bash
set -eu -o pipefail

# here we assume that the environment provides $HOSTNAME and possibly $SUBJECT (if self-generating) for example:
# SUBJECT='/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost'

CERT_DIR=/root/sslKeys
APACHE_SSL_CONF=/etc/httpd/conf/extra/httpd-ssl.conf
CRT_FILE_NAME=fullchain.pem
KEY_FILE_NAME=privkey.pem

# let's make a folder to hold our ssl cert files
mkdir -p ${CERT_DIR}

# let's tell apache to look for ssl cert files (called server.crt and server.key) in this folder
sed -i "s,/etc/httpd/conf/server.crt,${CERT_DIR}/${CRT_FILE_NAME},g" ${APACHE_SSL_CONF}
sed -i "s,/etc/httpd/conf/server.key,${CERT_DIR}/${KEY_FILE_NAME},g" ${APACHE_SSL_CONF}
# the intention here is that, prior to starting apache, there will somehow be two files in this folder for it to use
# these files might be self-generated, fetched from letsencrypt.org or
# put there by the user

  : ${HOSTNAME:=$(hostname --fqdn)}
  echo "Fetching ssl certificate files for ${HOSTNAME} from letsencrypt.org."
  echo "This container's Apache server must be reachable from the Internet via http://${HOSTNAME}"
  certbot --debug --agree-tos --non-interactive --email ${EMAIL} --webroot -w /usr/share/webapps/owncloud/ -d ${HOSTNAME} certonly
  # Maybe one day the apache plugin will work for Arch Linux and I could do this...
  #certbot --apache --debug --agree-tos --email ${EMAIL} -d ${HOSTNAME} certonly
  if [ $? -eq 0 ]; then
    rm -rf ${CERT_DIR}/${CRT_FILE_NAME}
    ln -s /etc/letsencrypt/live/${HOSTNAME}/fullchain.pem ${CERT_DIR}/${CRT_FILE_NAME}
    rm -rf ${CERT_DIR}/${KEY_FILE_NAME}
    ln -s /etc/letsencrypt/live/${HOSTNAME}/privkey.pem ${CERT_DIR}/${KEY_FILE_NAME}
    [ -f /var/run/httpd/httpd.pid ] && apachectl graceful
    echo "Success! now copy your cert files out of the image and save them somewhere safe:"
    echo "docker cp CONTAINER:/etc/letsencrypt ~/letsencryptBackup"
    echo "where CONTAINER is the name you used when you stated the container"
    # now we'll schedule renewals via cron twice per day (will only be successful after ~90 days)
    echo '51 6,15 * * * root certbot renew >> /var/log/certbot.log 2>&1' > /etc/cron.d/certbot_renewal
  else
    echo "Failed to fetch ssl cert from let's encrypt"
  fi

# let's make sure the key file is really a secret
chmod 600 ${CERT_DIR}/${KEY_FILE_NAME}
