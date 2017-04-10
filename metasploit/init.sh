#!/bin/bash
set -e
/etc/init.d/postgresql start && sleep 2 && su postgres -c "psql -f /msf/db.sql"

source /usr/local/rvm/scripts/rvm
rvm use 2.3.1 --default
msfupdate --git-branch master
msfconsole

