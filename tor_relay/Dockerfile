# build: docker build -t tor-relay .
# run:   docker run -d --restart on-failure:3 -v /etc/localtime:/etc/localtime:ro -p 9001:9001 tor-relay
FROM debian:jessie
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

RUN apt-get update && apt-get install -y tor
COPY torrc.conf /etc/tor/torrc

USER debian-tor
ENTRYPOINT tor
