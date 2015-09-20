@echo off
call ip.bat %1 > ip.txt && set /p ip=<ip.txt && del ip.txt

docker run -e SPARK_PUBLIC_DNS=%ip% ^
    -e MASTER_IP=10.0.2.185 ^
    -e MASTER_PORT=7077 ^
    -p 4040:4040 -p 7001-7006:7001-7006 ^
    -p 8081:8081 -p 8888:8888 ^
    nikonyrh/spark

