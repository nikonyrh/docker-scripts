#!/bin/bash
# Expecting ip.sh to exist in the same folder
cd "$(dirname "$(readlink -f -- "$0")")"

# To fix max map count: sysctl -w vm.max_map_count=262144

if [ "$2" == "" ]; then
    >&2 echo "Usage: $0 version memory-gb [flags..]" && exit 1
fi


VER=$1
MEM="${2}g"
shift 2

VOLUMES=
MODE=d
ES_JAVA_OPTS="-Xms$MEM -Xmx$MEM"
RESTART=

while (( "$#" )); do
    case $1 in
        --data)
            if [ "$2" == "" ]; then
                >&2 echo "Missing option for $1!" && exit 1
            fi

            sudo mkdir -p $2 && sudo chown "$USER:$USER" $2
            VOLUMES="$VOLUMES -v $2:/usr/share/elasticsearch/data"
            shift 2
            ;;
        
        -it)
            MODE=it
            shift
            ;;
        
        -restart)
            RESTART="--restart unless-stopped"
            shift
            ;;
        
        -jmx)
            # http://stackoverflow.com/a/35108974
            ES_JVM_OPTIONS=/jmx.conf
            shift
            ;;
        
        *)
            >&2 echo "Unknown option $1!" && exit 1
            ;;
    esac
done

docker run --net host \
    $RESTART \
    -e ES_JAVA_OPTS="$ES_JAVA_OPTS" \
    -e ES_JVM_OPTIONS="$ES_JVM_OPTIONS" \
    -e LOCAL_IP=`./ip.sh` \
    -$MODE $VOLUMES \
    "elasticsearch$VER"

