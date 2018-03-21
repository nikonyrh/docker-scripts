FROM openjdk:9
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https \
    && rm -rf /var/lib/apt/lists/* \
    && wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - \
    && echo 'deb https://artifacts.elastic.co/packages/6.x/apt stable main' >> /etc/apt/sources.list.d/elastic-6.x.list

ENV ELASTICSEARCH_VERSION 6.2.3

# https://github.com/elastic/elasticsearch/issues/21877#issuecomment-270732840
#ENV ES_SKIP_SET_KERNEL_PARAMETERS true

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends "elasticsearch=$ELASTICSEARCH_VERSION" \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH
WORKDIR  /usr/share/elasticsearch

RUN set -ex \
    && for path in \
        ./data \
        ./logs \
        ./config \
        ./config/scripts \
    ; do \
        mkdir -p "$path"; \
        chown -R elasticsearch:elasticsearch "$path"; \
    done


# Grab gosu for easy step-down from root. Running this later than in the original script,
# as github.com's cert was not trusted but this was fixed by installing ca-certificates.
ENV GOSU_VERSION 1.10
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc"

# https://github.com/tianon/gosu/issues/35
# FUU, let's hope we are safe :(

#RUN set -x \
#    && export GNUPGHOME="$(mktemp -d)" \
#    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
#    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
#    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc

RUN sleep 1 && chmod +x /usr/local/bin/gosu && gosu nobody true


# Head plugin cannot be installed to ES 6.x, running the standalone server along with it
# https://github.com/mobz/elasticsearch-head#running-with-built-in-server
# https://github.com/Medium/phantomjs/issues/659#issuecomment-268119362
RUN apt-get update && \
    apt-get install -y npm nodejs zip unzip bzip2 && \
    npm install -g grunt-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN cd / && \
    wget -q https://github.com/mobz/elasticsearch-head/archive/master.zip -O head.zip && \
    unzip -q head.zip && \
    rm head.zip && \
    cd /elasticsearch-head-master && \
    npm install

COPY config ./config
COPY docker-entrypoint.sh /

COPY main.sh /main.sh
RUN chmod +x /*.sh

COPY jmx.conf /jmx.conf

ENTRYPOINT ["/main.sh"]

