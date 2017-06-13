#!/bin/bash
if [ "$SPARK_LOCAL_IP" = "" ]; then
    >&2 echo "No SPARK_LOCAL_IP defined!" && exit 1
fi

if [ "$MASTER_PORT" = "" ]; then
    MASTER_PORT=7077
fi

cd $SPARK_HOME/sbin


case "$MODE" in
    master)
        ./start-master.sh --host $SPARK_LOCAL_IP --port $MASTER_PORT
        ;;
    
    slave)
        if [ "$SPARK_MASTER_HOST" = "" ]; then
            >&2 echo "No SPARK_MASTER_HOST defined!" && exit 1
        fi

        if [ "$SPARK_WORKER_PORT" = "" ]; then
            export SPARK_WORKER_PORT=8888
        fi

        if [ "$SPARK_WORKER_WEBUI_PORT" = "" ]; then
            export SPARK_WORKER_WEBUI_PORT=8081
        fi

        if [ "$N_CORES" = "" ]; then
            N_CORES=`nproc`
        fi

        ./start-slave.sh \
            --cores "$N_CORES" \
            "spark://$SPARK_MASTER_HOST:$MASTER_PORT"
        ;;
    
    *)
        echo "Usage: $0 (master|slave)" && exit 1
esac

# Leaving this script running...
tail -f /dev/null

