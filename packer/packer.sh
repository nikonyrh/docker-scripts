#!/bin/bash
cd "$(dirname "$(readlink -f -- "$0")")"

function readkey {
    grep -v '#' $HOME/.aws/credentials | grep "$1" | sed -r 's/.+[ \t]*=[ \t]*//'
}

if [ "$AWS_ACCESS_KEY_ID" = "" ]; then
    AWS_ACCESS_KEY_ID=`readkey aws_access_key_id`
fi

if [ "$AWS_SECRET_ACCESS_KEY" = "" ]; then
    AWS_SECRET_ACCESS_KEY=`readkey aws_secret_access_key`
fi

if [ `uname -s` != 'Linux' ]; then
    # Assuming MINGW, sorry OSX!
    OS=windows
    PACKER=packer.exe
else
    OS=linux
    PACKER=./packer
fi

if [ ! -f $PACKER ]; then
    VER=1.0.2
    >&2 echo "Note: Downloading $PACKER version $VER from releases.hashicorp.com for $OS"
    
    curl "https://releases.hashicorp.com/packer/$VER/packer_${VER}_${OS}_amd64.zip" > packer.zip && \
        unzip packer.zip && rm packer.zip
fi


while (( "$#" )); do
    REGION=$1
    shift

    AWS_CFG=`cat aws_regions.json | jq -r ".Regions[\"$REGION\"]"`
    if [ "$AWS_CFG" = null ]; then
        >&2 echo "Failed to get AWS_CFG for region $REGION!" && exit 1
    fi
    
    BASE_AMI=`echo "$AWS_CFG" | jq -r .UbuntuAmi`
    
    $PACKER build \
        -var "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
        -var "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
        -var "BASE_AMI=$BASE_AMI" \
        -var "REGION=$REGION" \
        ubuntu_and_docker.packer.json
done
