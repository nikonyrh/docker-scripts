#!/bin/bash

if [ "$REDIS_PORT" = "" ]; then
    echo "No REDIS_PORT defined!"
    exit 1
fi

if [ "$REDIS_HOST" = "" ]; then
    echo "No REDIS_HOST defined!"
    exit 1
fi

sed -ir "s/6379/$REDIS_PORT/" webdis.json
sed -ir "s/127.0.0.1/$REDIS_HOST/" webdis.json

./webdis &

sleep 1

# Expected: {"SET":[true,"OK"]}
response=`curl --upload-file index.html http://127.0.0.1:7379/SET/index 2>/dev/null`

if [ "$response" = "" ]; then
    echo "No response from Webdis, incorrect Redis port and/or ip!"
    exit 1
fi

if [ "$WEBDIS_PORT" != "" ]; then
    # Register the exposed port
    curl "http://127.0.0.1:7379/SET/webdis_port/$WEBDIS_PORT" 2>/dev/null
fi
