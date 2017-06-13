#!/bin/bash

if [ "$1" == "-all" ]; then
	# Removes containers which exited
	GREP='Exited \([0-9]+\)'
else
	# Removes containers which exited more than 5 days ago
	GREP='Exited \([0-9]+\) ([0-9]+ (weeks|months)|([6-9]|[1-9][0-9]) days) ago'
fi

# Delete exited containers
docker ps -a -f status=exited | grep -E "$GREP" | cut -d' ' -f1 | xargs --no-run-if-empty docker rm

# Delete created but not started containers
docker ps -a -f status=created -q | xargs --no-run-if-empty docker rm

# Remove dangling images
docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi 2>/dev/null

