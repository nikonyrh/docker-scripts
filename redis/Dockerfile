FROM redis:4

# To build: docker build -t redis redis
# To run:   docker run --restart=on-failure:3 -p 6379:6379 -d redis 1024mb volatile-ttl

COPY main.sh /main.sh
RUN chmod +x /main.sh

ENTRYPOINT ["/main.sh"]

