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
    -e "MASTER_IP=%master%" ^
    -d nikonyrh/spark

:end
