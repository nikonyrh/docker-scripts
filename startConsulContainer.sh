#!/bin/bash
# Usage:
# Client, --net=host:             ./startConsulContainer.sh --join 192.168.1.2
# Client, port forwarding:        ./startConsulContainer.sh --join 192.168.1.2 --host dev-machine-1
# Server, port forwarding:        ./startConsulContainer.sh --join 192.168.1.2 --host dev-machine-1 -server
# Server, bootstrap new cluster:  ./startConsulContainer.sh -server --bootstrap 3 -ui
# Registrator, --net=host:        ./startConsulContainer.sh -registrator

if [ "$1" == "" ]; then
    >&2 echo "Usage: $0 --join 192.168.1.2 --host dev-machine-1" && \
        >&2 echo "Usage: $0 -registrator"  && exit 1
fi

if [ "$1" == "-registrator" ]; then
    docker run -d --net=host -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator consul://localhost:8500
    exit $?
fi

# Expecting ip.sh to exist in the same folder
cd "$(dirname "$(readlink -f -- "$0")")"

MODE=
PARAMS=
NET="--net=host"

while (( "$#" )); do
    case $1 in
        -server)
            MODE="-server"
            shift
            ;;
        
        --bootstrap)
            PARAMS="$PARAMS -bootstrap-expect $2"
            shift && shift
            ;;
        
        --join)
            # Removing the possible port specification, assuming that everything is running in default ports
            SERVER=`echo $2 | sed -r 's/:.+//'`
            PARAMS="$PARAMS -join $SERVER"
            shift && shift
            ;;
        
        -ui)
            PARAMS="/ui"
            shift
            ;;
        
        --host)
            # This long list of port-forwards makes `docker ps` output very wide :(
            NET="-h $2 -p 8300-8302:8300-8302/tcp -p 8300-8302:8300-8302/udp -p 8400:8400 -p 8500:8500"
            shift && shift
            ;;
        
        *)
            echo "Unknown '$1'!" && exit 1
            ;;
    esac
done

# SERVICE_IGNORE=1 is for Registrator to ignore this Consul instance
docker run --restart=on-failure -e SERVICE_IGNORE=1 -d $NET \
    consul:0.8.5 agent $MODE -client 0.0.0.0 -advertise `./ip.sh` $PARAMS
