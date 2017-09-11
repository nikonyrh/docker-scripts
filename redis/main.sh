#!/bin/bash

if [ "$2" == "" ]; then
    >&2 echo "Memory policies: noeviction allkeys-lru volatile-lru allkeys-random volatile-random volatile-ttl" && exit 1
fi

mkdir -p /usr/local/etc/redis
F=/usr/local/etc/redis/redis.conf

echo "maxmemory $1" > $F
echo "maxmemory-policy $2" >> $F

redis-server $F

