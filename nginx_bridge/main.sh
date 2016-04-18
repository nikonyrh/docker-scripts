#!/bin/bash

while [ $# -gt 0 ]; do
    case "$1" in
    "-no-logs")
        >&2 echo 'Disabling access log'
        sed -r -i 's/#access_log/access_log/' /etc/nginx/nginx.conf
        shift
        ;;
    
    "--auth")
        >&2 echo "Setting '--auth $2'"
        AUTH=`echo $2 | sed -r 's/:/ /'`
        htpasswd -b -c /data/conf/htpasswd $AUTH 2>/dev/null
        
        if [ ! -f /data/conf/htpasswd ]; then
            >&2 echo "Invalid syntax, expecting '--auth username:password'!" && exit 1
        fi
        
        sed -r -i 's/#auth_/auth_/' /etc/nginx/nginx.conf
        shift && shift
        ;;
    
    *)
        >&2 echo "Unrecognized command '$1'!" && exit 1
        ;;
    
    esac
done

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
ln -s /etc/nginx/nginx.conf /data/conf

>&2 echo 'Starting nginx'
nginx -t && nginx -g 'daemon off;' 2>&1 | tee /data/conf/logs.txt &

pid=$!
wait "$pid"
