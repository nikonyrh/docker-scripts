#!/bin/bash
# apt-get update && apt-get install -y libevent-dev build-essential
git clone --depth 1 --branch 0.1.1 git://github.com/nicolasff/webdis.git
make
