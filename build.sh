#!/bin/bash
if [ "$1" = "" ]; then
	>&2 echo "Usage: $0 image-name" && exit 1
fi

docker build -t "$1" "$1"
