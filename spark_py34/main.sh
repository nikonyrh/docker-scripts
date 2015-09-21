#!/bin/bash

if [[ -z "$MASTER_IP" ]] ; then
    echo "No MASTER_IP defined!"
    exit 1
fi

if [[ -z "$MASTER_PORT" ]] ; then
    MASTER_PORT=7077
fi

/usr/spark/sbin/start-slave.sh "spark://$MASTER_IP:$MASTER_PORT" 
