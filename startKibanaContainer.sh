#!/bin/bash
if [ "$1" == "" ]; then
    >&2 echo "Usage: $0 [elasticsearch-ip]" && exit 1
fi

if [ "$ELASTICSEARCH_URL" = "" ]; then
    IP=`./ip.sh`
    ELASTICSEARCH_URL="http://$IP:9200"
fi

docker run -p 5601:5601 \
    -e ELASTICSEARCH_URL=$ELASTICSEARCH_URL \
    -d "kibana$1"

# Let's give Kibana some time to create the index...
sleep 10

curl -XPUT "$ELASTICSEARCH_URL/.kibana/_settings" -d '{"index": {"number_of_replicas": 0}}'

