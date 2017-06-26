#!/bin/bash
cd "$(dirname "$(readlink -f -- "$0")")"

# Examples (Spark master/slave):
#   ./startSparkContainer.sh master
#   ./startSparkContainer.sh slave 10.0.2.4

if [ "$IP" = "" ]; then
    IP=`./ip.sh`
    
    if [ "$IP" = "" ]; then
        >&2 echo "Host IP not found, wrong default prefix at ip.sh?" && exit 1
    fi
fi

MODE="$1"
shift

if [ "$SPARK_IMG" = "" ]; then
    SPARK_IMG=spark211_py36
fi

case "$MODE" in
    master)
        docker run --restart=unless-stopped \
            --net host                      \
            -e "MODE=$MODE"                 \
            -e "SPARK_LOCAL_IP=$IP"         \
            -d $SPARK_IMG
        ;;
    
    slave)
        SPARK_MASTER_HOST="$1"
        
        if [ "$SPARK_MASTER_HOST" = "" ]; then
            >&2 echo "SPARK_MASTER_HOST not set!" && exit 1
        fi
        
        docker run --restart=unless-stopped \
            --net host                      \
            -e "N_CORES=$N_CORES"           \
            -e "MODE=$MODE"                 \
            -e "SPARK_LOCAL_IP=$IP"         \
            -e "SPARK_MASTER_HOST=$SPARK_MASTER_HOST" \
            -d $SPARK_IMG
        ;;
    
    *)
        echo "Usage: $0 (master|slave)" && exit 1
esac

