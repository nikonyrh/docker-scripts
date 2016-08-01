#!/bin/bash
REDIS_MEM=`/redisMemory.sh`
sed -i -r "s/(maxmemory ).+/\1$REDIS_MEM/" /usr/local/etc/redis/redis.conf && \
    redis-server /usr/local/etc/redis/redis.conf
