#!/bin/bash
set -ex

sed -i "s/localhost/${RPCHOSTNAME}/g" /cnode/01Cnode/config/default.yaml
sed -i "s/<some username>/${RPCUSER}/g" /cnode/01Cnode/config/default.yaml
sed -i "s/<a very secret password>/${RPCPASSWORD}/g" /cnode/01Cnode/config/default.yaml
sed -i "s/my bitcoin fullnode/BTC Node/g" /cnode/01Cnode/config/default.yaml

echo -e "\n\n\ndefault.yml:"
cat /cnode/01Cnode/config/default.yaml

exec gosu cnode node server.js
