FROM nginx:1.9
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# To build: docker build -t nginx_bridge nginx_bridge
# To run:   docker run -p 81:80 -v "$PWD:/volume" -d nginx_bridge

RUN rm /etc/nginx/conf.d/default.conf
RUN mkdir -p /data/conf /volume

ADD main.sh      /data/main.sh
ADD nginx.conf   /etc/nginx/nginx.conf

WORKDIR /data
ENV USER docker

RUN chmod +x /data/*.sh
ENTRYPOINT ["/data/main.sh"]

