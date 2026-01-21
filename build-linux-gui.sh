#!/bin/bash
# Build Linux GUI Wallet using Docker
# This will create binaries in build-output/linux-gui/

set -e

echo "======================================"
echo "Rhino Miner Coin - Linux GUI Builder"
echo "======================================"
echo ""
echo "This will build the GUI wallet for Linux (rhino-qt)"
echo ""
echo "Building... (this may take 15-30 minutes)"
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Build using Docker
docker build -f docker/build-linux-gui.Dockerfile -t rhino-miner-coin-gui-builder .

# Create output directory
mkdir -p build-output/linux-gui

# Run container to extract binaries
docker run --rm -v "$(pwd)/build-output:/out" rhino-miner-coin-gui-builder

echo ""
echo "======================================"
echo "BUILD COMPLETE!"
echo "======================================"
echo ""
echo "Binaries are in: build-output/linux-gui/"
echo ""
ls -lh build-output/linux-gui/
echo ""
echo "To run the GUI wallet on Linux:"
echo "  ./build-output/linux-gui/rhino-qt"
echo ""
echo "To run the daemon:"
echo "  ./build-output/linux-gui/rhinod"
echo ""
