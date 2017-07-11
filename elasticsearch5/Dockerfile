FROM ubuntu:16.04
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# Based on these great projects:
#    https://github.com/StrictlyBusiness/docker-java8/blob/master/Dockerfile
#    https://github.com/docker-library/elasticsearch/blob/master/5/Dockerfile

# docker build -t elasticsearch5 elasticsearch5

# Add Oracle Java repository
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update

# Install Oracle Java 8
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    apt-get install -y oracle-java8-installer oracle-java8-set-default && \
    apt-get clean
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN set -ex; \
# https://artifacts.elastic.co/GPG-KEY-elasticsearch
	key='46095ACC8548582C1A2699A9D27D666CD88E42B4'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/elastic.gpg; \
	rm -r "$GNUPGHOME"; \
	apt-key list

# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html
# https://www.elastic.co/guide/en/elasticsearch/reference/5.0/deb.html
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https && rm -rf /var/lib/apt/lists/* \
	&& echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' > /etc/apt/sources.list.d/elasticsearch.list

ENV ELASTICSEARCH_VERSION 5.2.2
ENV ELASTICSEARCH_DEB_VERSION 5.2.2

# https://github.com/elastic/elasticsearch/issues/21877#issuecomment-270732840
ENV ES_SKIP_SET_KERNEL_PARAMETERS true

RUN set -x \
	\
	&& apt-get update \
	&& apt-get install -y --no-install-recommends "elasticsearch=$ELASTICSEARCH_DEB_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH    /usr/share/elasticsearch/bin:$PATH
WORKDIR /usr/share/elasticsearch

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

COPY config ./config
COPY docker-entrypoint.sh /

# Grab gosu for easy step-down from root. Running this later than in the original script,
# as github.com's cert was not trusted but this was fixed by installing ca-certificates.
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true


# Head plugin cannot be installed to ES 5.x, running the standalone server along with it
# https://github.com/mobz/elasticsearch-head#running-with-built-in-server
# https://github.com/Medium/phantomjs/issues/659#issuecomment-268119362
RUN apt-get update && \
    apt-get install -y npm nodejs zip unzip bzip2 && \
    ln -s `which nodejs` /usr/bin/node && \
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
COPY log4j2.properties /usr/share/elasticsearch/config/log4j2.properties
RUN chmod +x /*.sh

COPY jmx.conf /jmx.conf

ENTRYPOINT ["/main.sh"]

