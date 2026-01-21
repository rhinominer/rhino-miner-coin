FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY rhino-miner-coin /work/rhino-miner-coin

RUN gcc -O2 -std=gnu11 -I/work/rhino-miner-coin/src/crypto/yespower \
    -c /work/rhino-miner-coin/src/crypto/yespower/yespower.c -o /tmp/yespower.o \
    && gcc -O2 -std=gnu11 -I/work/rhino-miner-coin/src/crypto/yespower \
    -c /work/rhino-miner-coin/src/crypto/yespower/yespower-opt.c -o /tmp/yespower-opt.o \
    && gcc -O2 -std=gnu11 -I/work/rhino-miner-coin/src/crypto/yespower \
    -c /work/rhino-miner-coin/src/crypto/yespower/sha256.c -o /tmp/sha256.o \
    && g++ -O2 -std=c++17 -I/work/rhino-miner-coin/src/crypto/yespower \
    /work/rhino-miner-coin/contrib/devtools/genesis_miner.cpp \
    /tmp/yespower.o /tmp/yespower-opt.o /tmp/sha256.o \
    -o /usr/local/bin/genesis_miner -pthread

ENTRYPOINT ["/usr/local/bin/genesis_miner"]
