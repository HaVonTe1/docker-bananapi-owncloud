# docker-armh7-owncloud
An docker image to run an instance of owncloud on a [Banana Pi](https://en.wikipedia.org/wiki/Banana_Pi)

This project is a fork of [docker-owncloud](https://github.com/greyltc/docker-owncloud) from greyltc.


| Docker        | Banana Pi           | Owncloud  |
| ------------- |:-------------:| -----:|
|<a title="von dotCloud, Inc. [Apache License 2.0 (http://www.apache.org/licenses/LICENSE-2.0)], via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File%3ADocker_(container_engine)_logo.png"><img width="512" alt="Docker (container engine) logo" src="https://upload.wikimedia.org/wikipedia/commons/7/79/Docker_%28container_engine%29_logo.png"/></a>|<a title="By Fxstation (Own work) [CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0)], via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File%3AFront_of_Banana_Pi.JPG"><img width="256" alt="Front of Banana Pi" src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Front_of_Banana_Pi.JPG/256px-Front_of_Banana_Pi.JPG"/></a>|<a title="von www.owncloud.org (www.owncloud.org) [LGPL (http://www.gnu.org/licenses/lgpl.html)], via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File%3AOwncloud-logo.png"><img width="512" alt="Owncloud-logo" src="https://upload.wikimedia.org/wikipedia/commons/4/48/Owncloud-logo.png"/></a>|


# Features
+ Based on [Archlinux for ARMv7](https://archlinuxarm.org/platforms/armv7/allwinner/a20-olinuxino-lime2)
The Dockerfile and scripts to build the base image is part of a [separated repository](https://github.com/HaVonTe1/docker-bananapi-archlinux-base).
+ Running on Apache2 with PHP7 and a lot of performance tweaks
+ 100% TLS secured
+ ready for letsencrypt

# How to build the docker image
## Preparations (mostly optional)
+ install the mainline Kernel for Bananian to be able to run Docker at all
```
apt install linux-image-4.4-bananian
```
After restarting the Banana Pi your system should be ready.
+ install Docker
Follow the instructions on the docker manuals.  
It´s the same like on plain [Debian](https://docs.docker.com/engine/installation/linux/debian/#/debian-jessie-80-64-bit)

No you should be ready to go:
 
```
docker build -t mygroupname/myimagename .
```

# usage
## most simply
```
docker run --hostname=$yourTLD --name owncloud -v $yourLocalDataDirWithLotOfSpace:/home/owncloud/data -p 443:443  -d havonte/owncloud-single
```
+ the hostname is mostly important if you want to use letsencrypt
+ you should $yourLocalDataDirWithLotOfSpace replace with a directory on your BananaPi with enough disk space. 
Remember: owncloud is designed for mass storage. The BananaPi runs on a SD with 64GB max. So it might be wisely to connect an external HDD.

In order to give the necessary permissions execute the following commands for your data path:

```
mkdir $yourLocalDataDirWithLotOfSpace
sudo chgrp 33 $yourLocalDataDirWithLotOfSpace
chmod 0770 $yourLocalDataDirWithLotOfSpace
```
Explanation: the owncloud inside the container runs with the `httpd` user which has the gid 33.

+ /home/owncloud/data replace this with any path you want. It will be created inside the container. But remember to set this path as data directory when you setup the owncloud.
+ Replace the name of the docker image at the end of the command with the image name you chosed when you built the image.

## composed with docker mariadb / postgres

```
docker-compose -f docker-compose-maria.yml up -d
```
This will bring up a new internal docker network, an instance of mariadb and the owncloud itself.
The same is available for postgres.

## as single instance with remote database
I prefer this because I dont like running databases in docker.
+ bring up your db (postgres prefered)
+ create a bridge network to be able to access the docker host if your database is running on that host
```
docker network create -d bridge --subnet 192.168.0.0/24 --gateway 192.168.0.1 dockernet
```
+ run owncloud with docker or docker-compose-single.yml
```
docker-compose -f docker-compose-single.yml -d
```
When you init your owncloud: the hostname of the dockerhost is 192.168.0.1

# FAQ

## Why running Owncloud in a docker constainer
Well, why use docker at all?
+ easy upgrades
+ easy parallel instances
+ easy port realocation of different services
+ ...
+ its fun

## Why archlinux?
This distribution comes with the latest versions of all libs. 
