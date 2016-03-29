#!/bin/bash

if [[ -z "$MASTER_IP" ]] ; then
    echo "No MASTER_IP defined!"
    exit 1
fi

if [[ -z "$MASTER_PORT" ]] ; then
    MASTER_PORT=7077
fi

if [[ -z "$SLAVES_PER_CORE" ]] ; then
    SLAVES_PER_CORE=1
fi

export SPARK_LOCAL_IP=$SPARK_PUBLIC_DNS

/usr/spark/sbin/start-slave.sh \
    --cores $((`nproc` * $SLAVES_PER_CORE)) \
    "spark://$MASTER_IP:$MASTER_PORT"

