FROM continuumio/miniconda3
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# Science stuff from conda
RUN pip install --upgrade pip && \
    conda update -y conda && \
    conda install -y numpy scipy scikit-learn

ADD java-8-debian.list /etc/apt/sources.list.d/java-8-debian.list

# Utility stuff + Java 8, not installing GCC so some pip installs won't succeed
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    apt-get -qq update && \
    apt-get -q -y install jq curl dos2unix && \
    apt-get -q -y install oracle-java8-installer && \
    apt-get -q -y install oracle-java8-set-default && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV SPARK_VERSION 2.1.1
ENV HADOOP_VERSION 2.7

ENV SPARK_PACKAGE $SPARK_VERSION-bin-hadoop$HADOOP_VERSION
ENV SPARK_HOME /usr/spark-$SPARK_PACKAGE
ENV PATH $PATH:$SPARK_HOME/bin

# Download original versions from https://spark.apache.org/downloads.html,
# for better performance you should host it within LAN. Checkout https://hub.docker.com/r/nikonyrh/nginx_bridge/ ;)
RUN curl -sL "https://s3-eu-west-1.amazonaws.com/nikonyrh-public/projects/spark-$SPARK_PACKAGE.tgz" | \
        gunzip | tar x -C /usr/

# Some libraries which might come in handy, installing later
# at Dockerfile not to unnecessarily trash cached layers.
RUN pip install --no-cache-dir pytest elasticsearch redis

ADD main.sh /
RUN chmod +x /*.sh && dos2unix /*.sh

ENTRYPOINT ["/main.sh"]

