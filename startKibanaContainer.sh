#!/bin/bash

IP=`./ip.sh`
docker run -p 5601:5601 \
    -e ELASTICSEARCH_URL="http://$IP:9200" \
    -d kibana
