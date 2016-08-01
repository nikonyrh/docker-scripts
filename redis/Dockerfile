FROM redis:3.0.5

# From:
# - https://hub.docker.com/_/redis/
# - https://github.com/docker-library/redis/blob/8929846148513a1e35e4212003965758112f8b55/3.0/Dockerfile

# To build: docker build -t redis redis
# To run:   docker run --restart=on-failure:3 -p 6379:6379 -d redis

COPY redis.conf     /usr/local/etc/redis/redis.conf
COPY main.sh        /main.sh
COPY redisMemory.sh /redisMemory.sh

# We use dos2unix since we are modifying shell scripts in Windows environment
RUN apt-get update > /dev/null 2>&1 && apt-get install dos2unix > /dev/null 2>&1
RUN dos2unix /*.sh && chmod +x /*.sh

# Reduces the image size a bit
RUN apt-get autoremove -y > /dev/null && apt-get clean > /dev/null && \
    apt-get clean > /dev/null && rm -rf /var/lib/apt/lists/*

CMD /main.sh
