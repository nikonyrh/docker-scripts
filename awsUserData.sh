#!/bin/bash

# An one-liner:
# curl -s https://raw.githubusercontent.com/nikonyrh/docker-scripts/master/awsUserData.sh | bash /dev/stdin

# Fix "sudo" producing error messages due to hostname missing from /etc/hosts
echo `hostname | sed 's/ip-//' | sed 's/-/./g'` `hostname` >> /etc/hosts

# Install updates
apt-get update && apt-get install

# Install docker
curl -s https://raw.githubusercontent.com/nikonyrh/docker-scripts/master/getDockerUbuntu.sh > tmp.sh && chmod +x tmp.sh && sudo ./tmp.sh && rm tmp.sh

# These could be used for example at a Slack message to notify that the machine is ready
ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
TYPE=`curl -s http://169.254.169.254/latest/meta-data/instance-type`

# Make sure everything works and is up-to date
sleep 1 && shutdown -r now

