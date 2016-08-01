FROM debian:jessie
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# To build:  docker build -t webdis webdis

# To to run: export WEBDIS_PORT=90
#     docker run --restart=on-failure:3 -p "$WEBDIS_PORT:7379" -e "WEBDIS_PORT=$WEBDIS_PORT" -e REDIS_PORT=6001 -e "REDIS_HOST=`./ip.sh`" -d webdis
#     docker run --restart=on-failure:3 -p "$WEBDIS_PORT:7379" -e "WEBDIS_PORT=$WEBDIS_PORT" -e "REDIS_PORT=$REDIS_PORT" -e "REDIS_HOST=$REDIS_HOST" -d webdis

# Tests:
#     http://10.0.2.162:81/GET/index.html (if main.sh was run and Redis haven't been restarted)
#     curl http://10.0.2.162:81/SET/hello/world
#     curl http://10.0.2.162:81/GET/hello
#     curl http://10.0.2.162:81/KEYS/*

# Not building it here as it requires quite large build-essential package
RUN apt-get update && apt-get install -y curl libevent-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD mkdir /webdis
WORKDIR /webdis

ADD webdis.json   webdis.json
ADD webdis/webdis webdis
ADD main.sh       main.sh
ADD index.html    index.html

RUN chmod +x main.sh webdis

CMD /bin/bash -c "./main.sh && tail -f /dev/null"
