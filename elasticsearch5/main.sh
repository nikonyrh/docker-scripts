#!/bin/bash
if [ "$LOCAL_IP" == "" ]; then
    >&2 echo "Error: LOCAL_IP env variable not set!" && exit 1
fi

CORS=`echo $LOCAL_IP | sed -r "s/\./\\\\./"`
CORS="/https?:\/\/$CORS(:[0-9]+)?/"

echo "Generated CORS for $LOCAL_IP: $CORS"

echo 'http.cors.enabled:      true'  >> config/elasticsearch.yml
echo "http.cors.allow-origin: $CORS" >> config/elasticsearch.yml

sed -r -i "s/0.0.0.0/$LOCAL_IP/" config/elasticsearch.yml

cd /elasticsearch-head-master && grunt server &
/docker-entrypoint.sh elasticsearch

