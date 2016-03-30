#!/bin/bash

if [ "$1" == "-no-log" ]; then
    >&2 echo 'Disabling access log'
    sed -r -i 's/#access_log off;/access_log off;/' \
        /etc/nginx/nginx.conf
    shift
fi

pid=0

term_handler() {
  if [ $pid -ne 0 ]; then
    kill -s TERM "$pid"
    wait "$pid"
  fi
  
  exit 0
}

# This is issued by "docker stop"
trap term_handler SIGTERM

mkdir -p /data/logs
ln -s /etc/nginx/nginx.conf /data/logs

>&2 echo 'Starting nginx'
nginx -t && nginx -g 'daemon off;' 2>&1 | tee /data/logs/logs.txt &

pid=$!
wait "$pid"
