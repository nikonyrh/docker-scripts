FROM ubuntu:16.04
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# Based on:
#   - https://www.darkoperator.com/installing-metasploit-in-ubunt/
#   - https://hub.docker.com/r/remnux/metasploit/~/dockerfile/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y install default-jre build-essential libreadline-dev libssl-dev libpq5   \
	libpq-dev libreadline5 libsqlite3-dev libpcap-dev git-core autoconf postgresql \
	pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev curl   \
	zlib1g-dev nmap && \
    rm -rf /var/lib/apt/lists/*

RUN git clone -v https://github.com/rapid7/metasploit-framework.git /msf
WORKDIR /msf

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import   && \
    curl -L   https://get.rvm.io        | bash -s stable && \
    /bin/bash -l -c "                              \
	   rvm requirements                        \
	&& rvm install 2.3.1                       \
	&& rvm use 2.3.1 --default                 \
	&& source /usr/local/rvm/scripts/rvm       \
	&& gem install bundler --no-ri --no-rdoc   \
	&& source /usr/local/rvm/scripts/rvm       \
	&& bundle config --global jobs 2           \
	&& bundle install"

RUN bash -c 'for MSF in $(ls msf*); do ln -s $PWD/$MSF /usr/local/bin/$MSF; done'

ADD init.sh        /init.sh
ADD db.sql         /msf/db.sql
ADD database.yml   /msf/config/database.yml

ENTRYPOINT /init.sh

