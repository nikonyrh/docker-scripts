#!/bin/bash
if [ "$1" == "" ]; then
    >&2 echo "Usage: $0 memory-gb" && exit 1
fi

# To fix max map count: sysctl -w vm.max_map_count=262144

MEM="${1}g"

docker run --net host \
    -e ES_JAVA_OPTS="-Xms$MEM -Xmx$MEM" \
    -e LOCAL_IP=`./ip.sh` \
    -d elasticsearch

