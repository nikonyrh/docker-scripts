#!/bin/bash

# Exit if any failure occurs
set -e

MODE=autoindex
SERVER_NAME=

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
        shift 2
        ;;
    
    "-ssl"|"-tls")
        >&2 echo 'Generating a self-signed certificate'
        openssl req -subj '/CN=nginx_image.nikonyrh.org/O=Nginx Image/C=FI' \
            -sha256 -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /data/server.key -out /data/conf/server.crt
        
        shift
        ;;
    
    "--proxy_pass")
        >&2 echo "Enabling proxy pass to $2"
        MODE=proxy_pass
        
        sed -i "s|http://backend;|http://$2;|" /data/conf/proxy_pass.conf
        
        cat > /data/conf/backend.conf << EOF
upstream $2 {
    server $2;
}
EOF
        shift 2
        ;;
    
    "--server_name")
        SERVER_NAME="$2"
        >&2 echo "Setting server_name to $SERVER_NAME"
        sed -i "s/#server_name SERVER_NAME;/server_name $SERVER_NAME;/" /etc/nginx/nginx.conf
        shift 2
        ;;
    
    *)
        >&2 echo "Unrecognized command '$1'!" && exit 1
        ;;
    
    esac
done

if [ -f /cert-volume/server.crt ]; then
    >&2 echo 'Symlinking certs from /cert-volume'
    ln -s /cert-volume/server.crt /data/conf/server.crt
    ln -s /cert-volume/server.key /data/server.key
fi

if [ -f /data/conf/server.crt ]; then
    >&2 echo '/data/conf/server.crt detected, enabling SSL'
    sed -r -i 's/#listen 443/listen 443/' /etc/nginx/nginx.conf
    sed -r -i 's/#ssl_/ssl_/'             /etc/nginx/nginx.conf
    
    sed -r -i 's/#listen 443/listen 443/' /data/conf/default_server.conf
    sed -r -i 's/#ssl_/ssl_/'             /data/conf/default_server.conf
fi

sed -i "s|include /data/conf/MODE.conf;|include /data/conf/$MODE.conf;|" /etc/nginx/nginx.conf

if [ "$SERVER_NAME" = "" ]; then
    >&2 echo 'No --server_name set, disabling the default_server.conf'
    sed -i 's|include /data/conf/default_server.conf;|#include /data/conf/default_server.conf;|' /etc/nginx/nginx.conf
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

ln -s /etc/nginx/nginx.conf    /data/conf
ln -s /etc/nginx/nginx.conf    /data/logs
ln -s /var/log/nginx/error.log /data/logs

>&2 echo 'Validating config'
nginx -t

>&2 echo 'Starting Nginx'
nginx -g 'daemon off;' 2>&1 | tee /data/conf/logs.txt &

pid=$!
wait "$pid"
