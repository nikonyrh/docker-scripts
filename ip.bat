@echo off

SET machine=%1
SET prefix=%2
SET n=%3

REM Extract the IP or IPv6 address
SET "REGEX=[^:]+:[ \t]*([0-9\.:a-f\/]+).+"

IF "%machine%"=="" (
    @echo on
    echo "Usage: ip.bat [machine]"
    GOTO :end
)

IF "%prefix%"=="" (
    SET prefix=10.0
)

IF "%prefix%"=="--all" (
    docker-machine ssh %machine% "ifconfig | grep 'addr:' | grep -v 'Scope:Link' | sed -r 's/%REGEX%/\1/'"
    GOTO :end
)

IF "%n%"=="" (
    SET n=1
)

docker-machine ssh %machine% "ifconfig | grep 'addr:%prefix%' | head -n%n% | sed -r 's/%REGEX%/\1/'"

:end

