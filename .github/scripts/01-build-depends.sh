#!/usr/bin/env bash

PLATFORM=${1}
ARCH=${2:-x86_64}

if [[ ! ${PLATFORM} ]]; then
    echo "Error: Missing platform argument"
    echo "Usage: ${0} <platform> [arch]"
    exit 1
fi

echo "========================================"
echo "Building Dependencies for ${PLATFORM}"
echo "========================================"

set -e
set -x

# Save current directory
REPO_ROOT=$(pwd)

# Fix line endings in depends directory
find depends -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} + 2>/dev/null || true

# Make config scripts executable
chmod +x depends/config.guess depends/config.sub 2>/dev/null || true

cd depends

# Verify we're in the right directory
echo "Current directory: $(pwd)"
ls -la Makefile || echo "WARNING: Makefile not found!"

if [[ ${PLATFORM} == "windows" ]]; then
    make HOST=x86_64-w64-mingw32 DOWNLOAD_RETRIES=10 DOWNLOAD_CONNECT_TIMEOUT=60 -j$(nproc)

elif [[ ${PLATFORM} == "linux-gui" ]]; then
    make HOST=x86_64-pc-linux-gnu -j$(nproc)

elif [[ ${PLATFORM} == "linux" ]]; then
    make HOST=x86_64-pc-linux-gnu NO_QT=1 -j$(nproc)

else
    echo "Unknown platform: ${PLATFORM}"
    exit 1
fi

cd "${REPO_ROOT}"

echo "========================================"
echo "Dependencies built successfully"
echo "========================================"
