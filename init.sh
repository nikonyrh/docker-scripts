#!/bin/bash
mkdir -p ~/docker-scripts
cd ~/docker-scripts

rm -f ip.sh startSparkSlave.sh

wget http://10.0.2.185/ip.sh
wget http://10.0.2.185/startSparkSlave.sh
chmod +x *.sh

curl http://10.0.2.185/spark_latest.tar.gz | gunzip | docker load && ./startSparkSlave.sh && docker ps
