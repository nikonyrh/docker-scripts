FROM elasticsearch:5
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# docker build -t elasticsearch elasticsearch

# Head plugin cannot be installed to ES 5.x, running the standalone server along with it
# https://github.com/mobz/elasticsearch-head#running-with-built-in-server

RUN apt-get update && \
    apt-get install -y npm nodejs-legacy && \
    npm install -g grunt-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd / && \
    wget -q https://github.com/mobz/elasticsearch-head/archive/master.zip -O head.zip && \
    unzip -q head.zip && \
    rm head.zip && \
    cd /elasticsearch-head-master && \
    npm install

COPY main.sh /main.sh

ENTRYPOINT ["/main.sh"]

