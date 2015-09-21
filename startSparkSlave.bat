@echo off

IF "%1%"=="" (
    @echo on
    echo "Usage: startSparkSalve.bat [machine]"
    GOTO :end
)

call ip.bat %1 > ip.txt && set /p ip=<ip.txt && del ip.txt

SET master="%2"
IF "%master%"=="" (
    SET master=10.0.2.185
)

docker run -e SPARK_PUBLIC_DNS=%ip% ^
    -v /media/analyticsdev:/media/analyticsdev ^
    -e "MASTER_IP=%master%" ^
    -e MASTER_PORT=7077 ^
    -p 4040:4040 -p 7001-7006:7001-7006 ^
    -p 8081:8081 -p 8888:8888 ^
    -d nikonyrh/spark

:end
