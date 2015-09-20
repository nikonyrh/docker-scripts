#!/bin/bash
ip=`./ip.sh`

docker run -e "SPARK_PUBLIC_DNS=$ip" \
    -e MASTER_IP=192.168.0.104 \
    -e MASTER_PORT=7077 \
    -p 4040:4040 -p 7001-7006:7001-7006 \
    -p 8081:8081 -p 8888:8888 \
    -d nikonyrh/spark

