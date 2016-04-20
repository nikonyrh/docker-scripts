#!/bin/bash
source /py3/bin/activate

if [[ ! -z "$2" ]] ; then
    HOST_IP="$2"
fi

if [[ -z "$HOST_IP" ]] ; then
    >&2 echo "No HOST_IP defined!" && exit 1
fi

if [[ ! -z "$3" ]] ; then
    SPARK_MASTER_IP="$3"
else
    SPARK_MASTER_IP="$HOST_IP"
fi

SPARK_LOCAL_IP="$HOST_IP"
SPARK_PUBLIC_DNS="$HOST_IP"

export SPARK_MASTER_IP
export SPARK_LOCAL_IP
export SPARK_PUBLIC_DNS

if [ "$1" == "master" ]; then
    /usr/spark/sbin/start-master.sh && sleep 2 && tail -f -n200 /spark-logs/*
    exit 0
fi

if [ "$1" != "slave" ]; then
    >&2 echo "Unrecognized mode '$1', expecting 'master' or 'slave'!" && exit 1
fi

if [[ -z "$MASTER_PORT" ]] ; then
    MASTER_PORT=7077
fi

if [[ -z "$SLAVES_PER_CORE" ]] ; then
    SLAVES_PER_CORE=1
fi

MASTER_URL="spark://$SPARK_MASTER_IP:$MASTER_PORT"

/usr/spark/sbin/start-slave.sh --cores $((`nproc` * $SLAVES_PER_CORE)) $MASTER_URL && \
    sleep 2 && tail -f -n200 /spark-logs/*

