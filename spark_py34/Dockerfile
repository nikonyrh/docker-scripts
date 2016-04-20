FROM debian:jessie
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# Based on https://hub.docker.com/r/gettyimages/spark/~/dockerfile/
# See also:
#     - http://blog.james-carr.org/2013/09/04/parameterized-docker-containers/
#     - http://sometechshit.blogspot.ru/2015/04/running-spark-standalone-cluster-in.html

# docker build -t nikonyrh/spark spark_py34
# docker run -d --net=host nikonyrh/spark master `./ip.sh`
# docker run -d --net=host nikonyrh/spark slave  `./ip.sh`
# docker run -d --net=host nikonyrh/spark slave  `./ip.sh` spark.master.ip

RUN apt-get update && apt-get install -y curl net-tools unzip

# SPARK
ENV SPARK_VERSION 1.6.1
ENV HADOOP_VERSION 2.6
ENV SPARK_PACKAGE $SPARK_VERSION-bin-hadoop$HADOOP_VERSION
ENV SPARK_HOME /usr/spark-$SPARK_PACKAGE
ENV PATH $PATH:$SPARK_HOME/bin
RUN curl -sL --retry 3 \
  "http://mirrors.ibiblio.org/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_PACKAGE.tgz" \
  | gunzip | tar x -C /usr/ && ln -s $SPARK_HOME /usr/spark

RUN apt-get install -y python3.4 python3-pip openjdk-7-jdk dos2unix
RUN apt-get install -y libatlas-base-dev gfortran

# Only needed for pymssql
#RUN apt-get install -y freetds-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install virtualenv
RUN virtualenv -p `which python3` /py3
RUN /bin/bash -c "source /py3/bin/activate && pip install numpy scipy"

# Not needed anymore as "--net host" parameter is used for starting the container
# ENV SPARK_WORKER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081
ENV USERNAME docker

RUN ln -s /usr/spark/logs /spark-logs

COPY main.sh /main.sh
RUN chmod +x /*.sh && dos2unix /*.sh

ENTRYPOINT ["/main.sh"]

