#!/bin/bash
set -e

# Starts a bitcoind docker container inside a closed docker network.
# The port bitcoind uses to communicate with other peers is opened
# but the RPC port is only accessible from inside the network.
#
# Then a 01Cnode container (webserver serving statistics about the
# bitcoind) is started inside the closed docker network so it may
# access the bitcoind RPC port. It opens port 5000 to serve the
# statistics. Both containers must be run on the same server.

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Create a random password that does not include crazy characters
random_pw=$(dd if=/dev/urandom bs=33 count=1 2>/dev/null | base64)
# now, clean out anything that's not alphanumeric or an underscore
random_pw=${random_pw//[^a-zA-Z0-9]/}


if [ ! "$(sudo docker network ls | grep btc-net)" ]; then
    echo "Creating btc-net network ..."
    sudo docker network create btc-net
else
    echo "btc-net network exists."
fi


if [ "$(sudo docker ps -q -f name=bitcoind)" ]; then
    echo "cleaning up bitcoind container"
    sudo docker stop bitcoind -t0
    sudo docker rm $(sudo docker ps --filter=status=exited --filter=status=created -q)
fi
echo "starting bitcoind container"
sudo docker run -d \
    --name=bitcoind \
    --network btc-net \
    -p 8333:8333 \
    -e DISABLEWALLET=1 \
    -e PRINTTOCONSOLE=1 \
    -e REST=1 \
    -e SERVER=1 \
    -e TXINDEX=1 \
    -e RPCUSER=btcrpc \
    -e RPCPASSWORD=$random_pw \
    -e MAXCONNECTIONS=25 \
    -e MAXUPLOADTARGET=0 \
    -v /mnt/harddrive/bitcoin:/bitcoin \
    bitcoind
    #--cpus=1 \


if [ "$(sudo docker ps -q -f name=cnode)" ]; then
    echo "cleaning up 01CNode container"
    sudo docker stop cnode -t0
    sudo docker rm $(sudo docker ps --filter=status=exited --filter=status=created -q)
fi
echo "starting 01CNode container"
sudo docker run -d \
    --name=cnode \
    --network btc-net \
    -p 5000:5000 \
    -e RPCHOSTNAME=bitcoind \
    -e RPCUSER=btcrpc \
    -e RPCPASSWORD=$random_pw \
    cnode


echo "opening cnode page"
firefox http://localhost:5000 &
