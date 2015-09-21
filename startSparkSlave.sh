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

docker run -e "SPARK_PUBLIC_DNS=$ip" \
    -e "MASTER_IP=$MASTER_IP" \
    -e MASTER_PORT=7077 \
    -p 4040:4040 -p 7001-7006:7001-7006 \
    -p 8081:8081 -p 8888:8888 \
    -d nikonyrh/spark
