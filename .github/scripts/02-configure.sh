#!/usr/bin/env bash

PLATFORM=${1}

if [[ ! ${PLATFORM} ]]; then
    echo "Error: Missing platform argument"
    echo "Usage: ${0} <platform>"
    exit 1
fi

echo "========================================"
echo "Configuring Build for ${PLATFORM}"
echo "========================================"

set -e
set -x

# Fix line endings
find . -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} +

# Make all shell scripts executable
find . -type f -name '*.sh' -exec chmod +x {} +
chmod +x share/genbuild.sh 2>/dev/null || true
chmod +x autogen.sh 2>/dev/null || true

# Run autogen
bash ./autogen.sh

if [[ ${PLATFORM} == "windows" ]]; then
    CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site \
        ./configure --prefix=/ --disable-tests --with-gui=qt5

elif [[ ${PLATFORM} == "linux-gui" ]]; then
    CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site \
        ./configure --enable-upnp-default --with-gui=qt5 --disable-tests

elif [[ ${PLATFORM} == "linux" ]]; then
    CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site \
        ./configure --enable-upnp-default --without-gui --disable-tests

else
    echo "Unknown platform: ${PLATFORM}"
    exit 1
fi

echo "========================================"
echo "Configuration complete"
echo "========================================"
