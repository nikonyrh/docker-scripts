#!/bin/bash
if [ "$1" == "" ]; then
    >&2 echo "Usage: $0 [elasticsearch-ip]" && exit 1
fi

if [ "$ELASTICSEARCH_URL" = "" ]; then
    IP=`./ip.sh`
    ELASTICSEARCH_URL="http://$IP:9200"
fi

IMAGE="kibana$1"
shift

RESTART=

while (( "$#" )); do
    case $1 in
        -restart)
            RESTART="--restart unless-stopped"
            shift
            ;;
        
        *)
            >&2 echo "Unknown option $1!" && exit 1
            ;;
    esac
done

docker run -p 5601:5601 \
    $RESTART \
    -e ELASTICSEARCH_URL=$ELASTICSEARCH_URL \
    -d "$IMAGE"

# Let's give Kibana some time to create the index...
sleep 10

curl -XPUT "$ELASTICSEARCH_URL/.kibana/_settings" -d '{"index": {"number_of_replicas": 0}}'

