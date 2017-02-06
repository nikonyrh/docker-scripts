#!/bin/bash
cd "$(dirname "$(readlink -f -- "$0")")"

# Exit if any failure occurs
set -e

IP=`./ip.sh`
CERT_PATH="/etc/docker/certs.d/$IP:82"
CERT_FILE="server_$IP"

mkdir -p volumes/certs volumes/hub
sudo mkdir -p $CERT_PATH

if [ ! -f "volumes/certs/$CERT_FILE.crt" ]; then
    # https://security.stackexchange.com/a/86999/89895
    # https://github.com/elastic/logstash-forwarder/issues/221#issuecomment-48347334
    # https://github.com/docker/distribution/issues/948#issuecomment-137304399
    if ! grep -q "subjectAltName = IP:$IP" /etc/ssl/openssl.cnf; then
        >&2 echo 'Info: subjectAltName not configured at /etc/ssl/openssl.cnf, adding it'
        
        echo '[ v3_ca ]'               | sudo tee -a /etc/ssl/openssl.cnf
        echo "subjectAltName = IP:$IP" | sudo tee -a /etc/ssl/openssl.cnf
        echo ''                        | sudo tee -a /etc/ssl/openssl.cnf
    fi
    
    openssl req \
        -subj "/CN=$IP/O=Nginx Image/C=FI" \
        -sha256 -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -keyout "volumes/certs/$CERT_FILE.key" \
        -out    "volumes/certs/$CERT_FILE.crt"
    
    # Remove the pre-existing file, if it exists
    sudo rm -f "$CERT_PATH/ca.crt"
    sudo ln -s "$PWD/volumes/certs/$CERT_FILE.crt" "$CERT_PATH/ca.crt"
fi

docker run -d -p 82:5000 \
    -v "$PWD/volumes/hub:/var/lib/registry" \
    -v "$PWD/volumes/certs:/certs" \
    -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/$CERT_FILE.crt" \
    -e "REGISTRY_HTTP_TLS_KEY=/certs/$CERT_FILE.key" \
    registry:2
