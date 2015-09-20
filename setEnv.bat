@echo off
docker-machine env --shell cmd %1 | findstr /v # > set.cmd ^
    && set.cmd && del set.cmd
