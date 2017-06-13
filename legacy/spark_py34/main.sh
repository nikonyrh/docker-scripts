#!/bin/bash
source /py3/bin/activate

if [[ ! -z "$2" ]] ; then
    IP="$2"
fi

if [[ -z "$IP" ]] ; then
    >&2 echo "No IP defined!" && exit 1
fi

if [[ -z "$MASTER_PORT" ]] ; then
    MASTER_PORT=7077
fi

if [ "$1" == "submit" ]; then
    shift && shift
    echo "Running $@"
    cd /src && $SPARK_HOME/bin/spark-submit --master "spark://$IP:$MASTER_PORT" $@
    exit 0
fi

if [[ ! -z "$3" ]] ; then
    SPARK_MASTER_IP="$3"
else
    SPARK_MASTER_IP="$IP"
fi

SPARK_LOCAL_IP="$IP"
SPARK_PUBLIC_DNS="$IP"

export SPARK_MASTER_IP
export SPARK_LOCAL_IP
export SPARK_PUBLIC_DNS

if [ "$1" == "master" ]; then
    /usr/spark/sbin/start-master.sh && sleep 2 && tail -f -n200 /spark-logs/*
    exit 0
fi

if [ "$1" != "slave" ]; then
    >&2 echo "Unrecognized mode '$1', expecting 'master', 'slave' or 'submit'!" && exit 1
fi

if [[ -z "$CORES" ]] ; then
    if [[ -z "$SLAVES_PER_CORE" ]] ; then
        SLAVES_PER_CORE=1
    fi
    
    CORES=$((`nproc` * $SLAVES_PER_CORE))
fi

MASTER_URL="spark://$SPARK_MASTER_IP:$MASTER_PORT"

/usr/spark/sbin/start-slave.sh --cores $CORES $MASTER_URL && \
    sleep 2 && tail -f -n200 /spark-logs/*

