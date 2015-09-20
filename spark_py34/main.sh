#!/bin/sh

if [[ -z "$MASTER_IP" ]] ; then
    exit 1
fi

if [[ -z "$MASTER_PORT" ]] ; then
    MASTER_PORT=7077
fi

source /py3/bin/activate
/usr/spark/sbin/start-slave.sh "spark://$MASTER_IP:$MASTER_PORT" 

