#!/bin/bash
cd "$(dirname "$(readlink -f -- "$0")")"

if [ "$1" = "" ]; then
	>&2 echo "Usage: $0 image-name" && exit 1
fi

while (( "$#" )); do
	IMG=`echo $1 | sed -r 's_[/ ]__'`
	docker build -t $IMG $IMG
	shift
done

