#!/usr/bin/env bash

echo

# NeoGo host + port
NEOGO_HOST="${NEOGO_HOST:-http://localhost:30333}"

# Morph container name
MORPH_CONTAINER_NAME="${MORPH_CONTAINER_NAME:-morph}"

# NeoGo binary path.
NEOGO="${NEOGO:-docker exec -it ${MORPH_CONTAINER_NAME} neo-go}"

# Wallet files to change config value
WALLET="${WALLET:-./morph/node-wallet.json}"
WALLET_IMG="${WALLET_IMG:-config/node-wallet.json}"

# Netmap contract address resolved by NNS
NETMAP_ADDR=`./bin/resolve.sh netmap.neofs`

# Wallet password that would be entered automatically; '-' means no password
PASSWD="one"

# NeoFS configuration record: key is a string and value is an int
KEY=${1}
VALUE="${2}"

[ -z "$KEY" ] && echo "Empty config key" && exit 1
[ -z "$VALUE" ] && echo "Empty config value" && exit 1

# Internal variables
ADDR=`cat ${WALLET} | jq -r .accounts[2].address`

# Change config value in side chain
echo "Changing ${KEY} configration value to ${VALUE}"

echo -------
echo config.sh
echo neogo_host:  "$NEOGO_HOST"
echo morph_container_name: "$MORPH_CONTAINER_NAME"
echo neogo:       "$NEOGO"
echo passwd:      "$PASSWD"
echo wallet_img:  "$WALLET_IMG"
echo addr:        "$ADDR"
echo netmap_addr: "$NETMAP_ADDR"
echo key:         "$KEY"
echo value:       "$VALUE"


./bin/passwd.exp ${PASSWD} ${NEOGO} contract invokefunction \
-w ${WALLET_IMG} \
-a ${ADDR} \
-r ${NEOGO_HOST} \
${NETMAP_ADDR} \
setConfig bytes:beefcafe \
string:${KEY} \
int:${VALUE} -- ${ADDR} || exit 1

# Update epoch to apply new configuration value
./bin/tick.sh
