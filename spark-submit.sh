#!/bin/bash
IP="$1"
shift

docker run -it --net=host -v "$PWD:/src" nikonyrh/spark submit "$IP" $@

