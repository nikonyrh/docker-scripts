FROM nginx:1.9
MAINTAINER Niko Nyrh "https://github.com/nikonyrh"

# To build: docker build -t nikonyrh/nginx_bridge nginx_bridge
# To run:   docker run -p 1234:80 -v "$PWD:/volume:ro" -d nikonyrh/nginx_bridge
#           docker run -p 443:443 -d nikonyrh/nginx_bridge -tls --proxy_pass 10.0.0.1:80
#           docker run -p 443:443 -v "$PWD:/cert-volume:ro" -d nikonyrh/nginx_bridge

# Optional parameters:
#     -no-logs                           Disable access logs at /conf/logs.txt
#     --auth user:password               Require basic HTTP authentication (protects against "naive" attackers with just port scanners)
#     -(ssl|tls)                         Enable self-signed cert generation


# apache2-utils:    for htpasswd
# dos2unix:         argh, always issues with \r\n linefeeds on bash files :(
RUN apt-get update && apt-get install -y apache2-utils dos2unix && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rm /etc/nginx/conf.d/default.conf && \
    mkdir -p /data/conf /volume && \
    touch /data/conf/backend.conf

ADD autoindex.conf         /data/conf/
ADD proxy_pass.conf        /data/conf/
ADD default_server.conf    /data/conf/

ADD favicon.ico  /data/
ADD main.sh      /data/
ADD nginx.conf   /etc/nginx/

WORKDIR /data
ENV USER docker

RUN chmod +x /data/*.sh && dos2unix /data/*.sh
ENTRYPOINT ["/data/main.sh"]
