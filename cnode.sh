#!/bin/bash

set -e

# port 5000 is local access to webpage
# port 8332 is for local RPC

sudo docker system prune
if [ "$(sudo docker ps -q -f name=cnode)" ]; then
    sudo docker stop cnode
    sudo docker rm cnode
fi

echo "starting 01CNode container"

# If running 01Cnode to connect to
# a local RPC interface inside the
# btc-net docker network...
sudo docker run -it \
    --name=cnode \
    --network=btc-net \
    -p 5000:5000 \
    -e RPCHOSTNAME=bitcoind \
    -e RPCUSER=btcrpc \
    -e RPCPASSWORD=lol \
    -e TZ=CST6CDT \
    cnode $@

# If running 01Cnode to connect to
# a remote RPC interface...
#echo "starting 01CNode container"
#sudo docker run -it \
#    --name=cnode \
#    -p 5000:5000 \
#    -p 127.0.0.1:8332:8332 \
#    -e RPCHOSTNAME=localhost \
#    -e RPCUSER=btcrpc \
#    -e RPCPASSWORD=lol \
#    cnode

echo "opening page"
firefox http://localhost:5000
