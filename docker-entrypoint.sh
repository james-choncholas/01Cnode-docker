#!/bin/bash
set -ex

sed -i "s/localhost/${RPCHOSTNAME}/g" /cnode/01Cnode/config/default.yaml
sed -i "s/<some username>/${RPCUSER}/g" /cnode/01Cnode/config/default.yaml
sed -i "s/<a very secret password>/${RPCPASSWORD}/g" /cnode/01Cnode/config/default.yaml
sed -i "s/my bitcoin fullnode/BTC Node/g" /cnode/01Cnode/config/default.yaml

echo -e "\n\n\ndefault.yml:"
cat /cnode/01Cnode/config/default.yaml

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    echo "exec'ing $@"
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 13
else
    echo "node server.js"
    exec gosu cnode node server.js
fi
