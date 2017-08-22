#!/bin/bash

# An one-liner:
# curl -s https://raw.githubusercontent.com/nikonyrh/docker-scripts/master/packer/installDockerUbuntu.sh > tmp.sh && sudo bash tmp.sh

DOCKER=`which docker`
if [ "$DOCKER" != "" ]; then
   >&2 echo -e "\n\nDokcer already installed!\n\n" && exit 0
fi

if [[ $EUID -ne 0 ]]; then
   >&2 echo -e "This script must be run as root! Elevating..."
   sudo bash $0
   exit $?
fi

# Ref. https://askubuntu.com/a/190332/430574
export DEBIAN_FRONTEND=noninteractive

# ref. https://github.com/docker/docker.github.io/issues/2694
if [ `grep aufsz /proc/filesystems` = "" ]; then
    # linux-image-extra is needed for AUFS support on older kernels.
    UNAME=`uname -r`
    KERNEL_IMAGE_EXTRA="apt-get install -yq 'linux-image-extra-$UNAME'"
else
    # AUFS seems to be already supported
    KERNEL_IMAGE_EXTRA='echo "Skipping installing linux-image-extra, should not be needed as aufsz is already supported"'
fi

# $UBUNTU has values like ubuntu-trhusty and ubuntu-xenial
UBUNTU=`lsb_release -c | sed -r 's/.+[ \t]/ubuntu-/'`

# Based on https://docs.docker.com/engine/installation/ubuntulinux/
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
	echo "deb https://apt.dockerproject.org/repo $UBUNTU main" > /etc/apt/sources.list.d/docker.list && \
	apt-get update -q && \
	$KERNEL_IMAGE_EXTRA && \
	apt-get install -yq docker-engine && \
	sleep 5 && \
	service docker start 2>/dev/null

DOCKER=`which docker`
if [ "$DOCKER" = "" ]; then
   >&2 echo -e "\n\nDokcer installation failed!\n\n" && exit 1
fi

# TODO: Auto-detect the correct user name
getent passwd ubuntu >/dev/null 2>&1

if [[ $? -eq 0 ]]; then
    echo "Install ok, adding ubuntu to docker group"
    usermod -aG docker ubuntu
else
    echo "Install ok but user 'ubuntu' does not exist, not adding to docker group"
fi
