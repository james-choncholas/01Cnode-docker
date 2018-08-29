#!/bin/bash

set -e

# port 5000 is local access to webpage
# port 8331 is for local RPC

# check if a vpn container using UDP (for torrent) is running
if [ "$(sudo docker ps -q -f name=cnode)" ]; then
    sudo docker stop cnode
    docker_clean_ps
else
    echo "starting 01CNode container"
    sudo docker run -d \
        --name=cnode \
        -p 5000:5000 \
        -p 127.0.0.1:8331:8332 \
        cnode
fi

echo "opening page"
firefox http://localhost:5000
