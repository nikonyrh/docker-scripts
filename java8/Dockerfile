FROM anapsix/alpine-java:8_server-jre
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

COPY main.sh /main.sh
RUN chmod +x /main.sh

ENTRYPOINT ["/main.sh"]

