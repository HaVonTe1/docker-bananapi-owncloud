# docker-armh7-owncloud
An docker image to run an instance of owncloud on a [Banana Pi](https://en.wikipedia.org/wiki/Banana_Pi)

This project is a fork of [docker-owncloud](https://github.com/greyltc/docker-owncloud) from greyltc.

# Features
+ Based on [Archlinux for ARMv7](https://archlinuxarm.org/platforms/armv7/allwinner/a20-olinuxino-lime2)
The Dockerfile and scripts to build the base image will be part of a separated repository.
+ Running on Apache2 with PHP7 and a lot of performance tweaks
+ 100% TLS secured
+ ready for Letsencrypt

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

## composed with docker mariadb / postgres

```
docker-compose -f docker-compose-maria.yml up -d
```
This will bring up a new internal docker network, an instance of mariadb and the owncloud itself.
The same is available for postgres.

## as single instance with remote database
I defently prefer this because I dont like running databases in docker.
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

## hints
# use a separated data directory
In the docker-compose-single.yml is a volume mount from /media/ext1000/owncloud to /home/docker/data
Use any
# FAQ

## Why running Owncloud in a docker constainer
Well, why use docker at all?
+ easy upgrades
+ easy parallel instances
+ easy port realocation of different services
+ ...
+ its fun
