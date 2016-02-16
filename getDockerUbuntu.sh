#!/bin/bash

# An one-liner:
# curl -s https://raw.githubusercontent.com/nikonyrh/docker-scripts/master/getDockerUbuntu.sh > tmp.sh && chmod +x tmp.sh && sudo ./tmp.sh && rm tmp.sh

if [[ $EUID -ne 0 ]]; then
   >&2 echo -e "\n\nThis script must be run as root!\n\n" && exit 1
fi

DOCKER=`which docker`
if [ "$DOCKER" != "" ]; then
   >&2 echo -e "\n\nDokcer already installed!\n\n" && exit 0
fi

UNAME=`uname -r`

# Based on https://docs.docker.com/engine/installation/ubuntulinux/
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
	echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list && \
	apt-get update && \
	apt-get install -y "linux-image-extra-$UNAME" && \
	apt-get install -y docker-engine && \
	echo "Install ok, setting user group" && \
	service docker start 2>/dev/null

DOCKER=`which docker`
if [ "$DOCKER" = "" ]; then
   >&2 echo -e "\n\nDokcer installation failed!\n\n" && exit 1
fi

usermod -aG docker ubuntu
