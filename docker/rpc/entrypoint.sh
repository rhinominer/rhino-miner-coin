#!/usr/bin/env bash
set -euo pipefail

DATA_DIR=${DATA_DIR:-/data}
RPC_USER=${RPC_USER:-rhino}
RPC_PASSWORD=${RPC_PASSWORD:-rhino}
RPC_PORT=${RPC_PORT:-9982}
P2P_PORT=${P2P_PORT:-9981}
RPC_ALLOWIP=${RPC_ALLOWIP:-0.0.0.0/0}
NETWORK=${NETWORK:-main}
REWRITE_CONFIG=${REWRITE_CONFIG:-0}

mkdir -p "$DATA_DIR"

if [ ! -f "$DATA_DIR/rhino.conf" ] || [ "$REWRITE_CONFIG" = "1" ]; then
  cat > "$DATA_DIR/rhino.conf" <<EOF
server=1
daemon=0
txindex=1
EOF

  if [ "$NETWORK" = "main" ]; then
    cat >> "$DATA_DIR/rhino.conf" <<EOF
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcbind=0.0.0.0
rpcallowip=${RPC_ALLOWIP}
rpcport=${RPC_PORT}
port=${P2P_PORT}
EOF
  else
    NET_SECTION="test"
    if [ "$NETWORK" = "regtest" ]; then
      NET_SECTION="regtest"
    fi
    cat >> "$DATA_DIR/rhino.conf" <<EOF
[${NET_SECTION}]
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcbind=0.0.0.0
rpcallowip=${RPC_ALLOWIP}
rpcport=${RPC_PORT}
port=${P2P_PORT}
EOF
  fi
fi

ARGS=()
if [ "$NETWORK" = "testnet" ]; then
  ARGS+=("-testnet")
elif [ "$NETWORK" = "regtest" ]; then
  ARGS+=("-regtest")
fi

exec /usr/local/bin/rhinod -datadir="$DATA_DIR" -conf="$DATA_DIR/rhino.conf" -printtoconsole "${ARGS[@]}" "$@"
