#!/bin/bash
set -e

if [[ "$1" == "feathercoin-wallet" || "$1" == "feathercoin-cli" || "$1" == "feathercoin-tx" || "$1" == "feathercoind" || "$1" == "test_feathercoin" ]]; then
	mkdir -p "$FEATHERCOIN_DATA"

cat <<-EOF > "$FEATHERCOIN_DATA/feathercoin.conf"
printtoconsole=1
txindex=1
rpcallowip=::/0
rpcpassword=${FEATHERCOIN_RPC_PASSWORD:-password}
rpcuser=${FEATHERCOIN_RPC_USER:-feathercoin}
${FEATHERCOIN_EXTRA_ARGS}
EOF

chown -h feathercoin:feathercoin "$FEATHERCOIN_DATA/feathercoin.conf"

# ensure correct ownership and linking of data directory
# we do not update group ownership here, in case users want to mount
# a host directory and still retain access to it
chown -R feathercoin "$FEATHERCOIN_DATA"
ln -sfn "$FEATHERCOIN_DATA" /home/feathercoin/.feathercoin
chown -h feathercoin:feathercoin  /home/feathercoin/.feathercoin


	exec gosu feathercoin "$@"
else
	exec "$@"
fi
