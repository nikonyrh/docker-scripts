@echo off

IF "%1%"=="" (
    @echo on
    echo "Usage: setEnv.bat [machine]"
    GOTO :end
)

docker-machine env --shell cmd %1 | findstr /v # > set.cmd ^
    && set.cmd && del set.cmd

:end
