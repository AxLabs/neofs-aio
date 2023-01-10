#!/usr/bin/env bash

# NeoGo host + port
NEOGO_HOST="${NEOGO_HOST:-http://localhost:30333}"

# Morph container name
MORPH_CONTAINER_NAME="${MORPH_CONTAINER_NAME:-morph}"

# NeoGo binary path.
NEOGO="${NEOGO:-docker exec -it ${MORPH_CONTAINER_NAME} neo-go}"
# NNS contract script hash
NNS_ADDR=`curl -s --data '{ "id": 1, "jsonrpc": "2.0", "method": "getcontractstate", "params": [1] }' ${NEOGO_HOST} | jq -r '.result.hash'`

${NEOGO} contract testinvokefunction \
-r ${NEOGO_HOST} \
${NNS_ADDR} resolve string:${1} int:16 | jq -r '.stack[0].value | if type=="array" then .[0].value else . end' | base64 -d
