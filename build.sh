#!/bin/bash
if [ "$1" = "" ]; then
	>&2 echo "Usage: $0 image-name" && exit 1
fi

IMG=`echo $1 | sed -r 's_[/ ]__'`
docker build -t $IMG $IMG
