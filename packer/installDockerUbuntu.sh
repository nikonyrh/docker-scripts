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

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" && \
	apt-get update -q && \
	$KERNEL_IMAGE_EXTRA && \
	apt-get install -y docker-ce && \
	echo "Install ok, setting user group" && \
	service docker start 2>/dev/null

DOCKER=`which docker`
if [ "$DOCKER" = "" ]; then
   >&2 echo -e "\n\nDokcer installation failed!\n\n" && exit 1
fi

USER=`ls /home | head -n1`

if usermod -aG docker $USER; then
	echo "Done! Pleas sign in and out for usermod to take effect."
else
	>&2 echo "Failure with 'usermod -aG docker $USER' :("
	exit 1
fi
