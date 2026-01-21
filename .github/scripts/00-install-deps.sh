#!/usr/bin/env bash

PLATFORM=${1}

if [[ ! ${PLATFORM} ]]; then
    echo "Error: Invalid options"
    echo "Usage: ${0} <platform>"
    exit 1
fi

echo "========================================"
echo "Installing Dependencies for ${PLATFORM}"
echo "========================================"

set -e
set -x

if [[ ${PLATFORM} == "windows" ]]; then
    sudo apt-get install -y \
        build-essential \
        libtool \
        autotools-dev \
        automake \
        pkg-config \
        bsdmainutils \
        ca-certificates \
        curl \
        git \
        g++-mingw-w64-x86-64 \
        bison \
        flex \
        gperf \
        python3 \
        nsis \
        osslsigncode \
        zip

    sudo update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix
    sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

elif [[ ${PLATFORM} == "linux-gui" ]]; then
    sudo apt-get install -y \
        build-essential \
        libtool \
        autotools-dev \
        automake \
        pkg-config \
        bsdmainutils \
        ca-certificates \
        curl \
        git \
        python3 \
        libqt5gui5 \
        libqt5core5a \
        libqt5dbus5 \
        qttools5-dev \
        qttools5-dev-tools \
        libprotobuf-dev \
        protobuf-compiler \
        libqrencode-dev \
        libminiupnpc-dev \
        libzmq3-dev \
        libssl-dev \
        libevent-dev \
        libboost-all-dev \
        libdb5.3++-dev \
        libdb5.3-dev

elif [[ ${PLATFORM} == "linux" ]]; then
    sudo apt-get install -y \
        build-essential \
        libtool \
        autotools-dev \
        automake \
        pkg-config \
        bsdmainutils \
        ca-certificates \
        curl \
        git \
        python3

else
    echo "Unknown platform: ${PLATFORM}"
    exit 1
fi

echo "========================================"
echo "Dependencies installed successfully"
echo "========================================"
