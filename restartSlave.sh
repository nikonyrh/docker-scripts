#!/bin/bash
docker ps --format "{{.ID}}" | xargs docker stop && ./startSparkSlave.sh
