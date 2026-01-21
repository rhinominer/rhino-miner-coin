#!/usr/bin/env bash

PLATFORM=${1}
VERSION=${2:-dev}

if [[ ! ${PLATFORM} ]]; then
    echo "Error: Missing platform argument"
    echo "Usage: ${0} <platform> [version]"
    exit 1
fi

echo "========================================"
echo "Packaging ${PLATFORM} Release - ${VERSION}"
echo "========================================"

set -e
set -x

# Create release directory
mkdir -p release

if [[ ${PLATFORM} == "windows" ]]; then
    # Package Windows binaries
    mkdir -p release/rhino-miner-coin-${VERSION}-windows
    cp src/rhinod.exe release/rhino-miner-coin-${VERSION}-windows/
    cp src/rhino-cli.exe release/rhino-miner-coin-${VERSION}-windows/
    cp src/rhino-tx.exe release/rhino-miner-coin-${VERSION}-windows/
    cp src/rhino-wallet.exe release/rhino-miner-coin-${VERSION}-windows/
    cp src/qt/rhino-qt.exe release/rhino-miner-coin-${VERSION}-windows/
    cp README.md release/rhino-miner-coin-${VERSION}-windows/
    cp COPYING release/rhino-miner-coin-${VERSION}-windows/
    
    cd release
    zip -r rhino-miner-coin-${VERSION}-windows.zip rhino-miner-coin-${VERSION}-windows
    cd ..

elif [[ ${PLATFORM} == "linux-gui" ]]; then
    # Package Linux GUI binaries
    mkdir -p release/rhino-miner-coin-${VERSION}-linux-gui
    cp src/rhinod release/rhino-miner-coin-${VERSION}-linux-gui/
    cp src/rhino-cli release/rhino-miner-coin-${VERSION}-linux-gui/
    cp src/rhino-tx release/rhino-miner-coin-${VERSION}-linux-gui/
    cp src/rhino-wallet release/rhino-miner-coin-${VERSION}-linux-gui/
    cp src/qt/rhino-qt release/rhino-miner-coin-${VERSION}-linux-gui/
    cp README.md release/rhino-miner-coin-${VERSION}-linux-gui/
    cp COPYING release/rhino-miner-coin-${VERSION}-linux-gui/
    
    cd release
    tar -czf rhino-miner-coin-${VERSION}-linux-gui.tar.gz rhino-miner-coin-${VERSION}-linux-gui
    cd ..

elif [[ ${PLATFORM} == "linux" ]]; then
    # Package Linux CLI binaries
    mkdir -p release/rhino-miner-coin-${VERSION}-linux
    cp src/rhinod release/rhino-miner-coin-${VERSION}-linux/
    cp src/rhino-cli release/rhino-miner-coin-${VERSION}-linux/
    cp src/rhino-tx release/rhino-miner-coin-${VERSION}-linux/
    cp src/rhino-wallet release/rhino-miner-coin-${VERSION}-linux/
    cp README.md release/rhino-miner-coin-${VERSION}-linux/
    cp COPYING release/rhino-miner-coin-${VERSION}-linux/
    
    cd release
    tar -czf rhino-miner-coin-${VERSION}-linux.tar.gz rhino-miner-coin-${VERSION}-linux
    cd ..

else
    echo "Unknown platform: ${PLATFORM}"
    exit 1
fi

echo "========================================"
echo "Packaging complete"
echo "========================================"
ls -lh release/
