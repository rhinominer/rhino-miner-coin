#!/usr/bin/env bash

echo "========================================"
echo "Building Rhino Miner Coin"
echo "========================================"

set -e
set -x

make -j$(nproc)

echo "========================================"
echo "Build complete"
echo "========================================"
