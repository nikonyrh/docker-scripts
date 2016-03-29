#!/bin/bash
docker save nikonyrh/spark | gzip > tmp.tar.gz && mv tmp.tar.gz nginx/spark_latest.tar.gz
