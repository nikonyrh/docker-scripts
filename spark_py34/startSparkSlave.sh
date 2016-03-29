#!/bin/bash
ip=`./ip.sh`

if [[ -z "$ip" ]] ; then
    echo "Host IP not found, wrong default prefix at ip.sh?"
    exit 1
fi

MASTER_IP="$1"

if [[ -z "$MASTER_IP" ]] ; then
    MASTER_IP=10.0.2.185
fi

if [[ -z "$SLAVES_PER_CORE" ]] ; then
    SLAVES_PER_CORE=2
fi

docker run -e "SPARK_PUBLIC_DNS=$ip" \
    --net host \
    -v /media/analyticsdev:/media/analyticsdev \
    -e "MASTER_IP=$MASTER_IP" \
    -e "SLAVES_PER_CORE=$SLAVES_PER_CORE" \
    -d nikonyrh/spark
