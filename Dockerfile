FROM havonte/archlinux

ADD install-httpd.sh /usr/sbin/install-httpd
RUN install-httpd

# generate our ssl key
ADD setupApacheSSLKey.sh /usr/sbin/setup-apache-ssl-key
ENV DO_SSL_SELF_GENERATION true
ENV SUBJECT /C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost
ENV DO_SSL_LETS_ENCRYPT_FETCH false
ENV EMAIL fail
RUN setup-apache-ssl-key
ENV DO_SSL_SELF_GENERATION true

# for https (apache)
EXPOSE 443

# start servers
ADD startServers.sh /usr/sbin/start-servers
ENV START_APACHE true
ENV ALLOW_INSECURE false
ENV ENABLE_DAV true
ENV ENABLE_CRON true
CMD start-servers; sleep infinity

ADD install-pacaur.sh /usr/sbin/install-pacaur
RUN install-pacaur

# set environmnt variable defaults
ENV TARGET_SUBDIR owncloud
ENV OC_VERSION '9.1.2-1'

# do the install things
ADD install-owncloud.sh /usr/sbin/install-owncloud
RUN install-owncloud

# add our config.php stub
ADD configs/config.php /usr/share/webapps/owncloud/config/config.php
RUN chown http:http /usr/share/webapps/owncloud/config/config.php; \
    chmod 0640 /usr/share/webapps/owncloud/config/config.php

# add our cron stub
ADD configs/cron.conf /etc/cron.d/owncloud

# add our apache config stub
ADD configs/apache.conf /etc/httpd/conf/extra/owncloud.conf

