#!/bin/bash

# Reading command line arguments makes testing this easier...
NPROC="$1"
RAM_KB="$2"

# ...but by default we auto-detect those values.
if [ "$NPROC" == "" ]; then
    NPROC=`nproc`
fi

if [ "$RAM_KB" == "" ]; then
    RAM_KB=`cat /proc/meminfo | grep MemTotal | sed -r 's/[^0-9]//g'`
    
    # Argh, base-2 and base-10 values mixed up again!
    RAM_KB=$((RAM_KB * 1024 / 1000))
fi

# If more than 2 CPUS and 5 GB of RAM then we allocate double the "default" amount
if (( $NPROC > 2 )) && (( $RAM_KB > 5000000 )); then
    DIV=8192
else
    DIV=16384
fi

REDIS_MEM=$((RAM_KB / DIV))
echo "${REDIS_MEM}mb"
