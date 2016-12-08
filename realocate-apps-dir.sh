#!/usr/bin/env bash
set -x -e -u -o pipefail

ocpath='/media/ext1000/owncloud'
htuser='www-data'
htgroup='www-data'
rootuser='root'
containername='owncloud'

printf "Creating possible missing Directories\n"
mkdir -p $ocpath/apps


printf "Copying files from running owncloud container to host dir"
docker cp  ${containername}:/usr/share/webapps/owncloud/apps ${ocpath}/apps


printf "Setting permissions"
chown -R ${htuser}:${htgroup} ${ocpath}/apps/
chmod -R 0770 ${ocpath}/apps

