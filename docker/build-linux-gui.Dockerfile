FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Install build dependencies including Qt5 for GUI
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
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
        libdb5.3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . /src

# Fix line endings and build
RUN find . -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} + \
    && find depends -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} + \
    && cd depends \
    && make HOST=x86_64-pc-linux-gnu \
    && cd .. \
    && bash ./autogen.sh \
    && CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure --enable-upnp-default --with-gui=qt5 --disable-tests \
    && make -j"$(nproc)"

# Copy artifacts
RUN mkdir -p /opt/artifacts/bin \
    && cp -a src/rhinod src/rhino-cli src/rhino-tx src/rhino-wallet src/qt/rhino-qt /opt/artifacts/bin/

CMD ["bash", "-lc", "mkdir -p /out/linux-gui && cp -a /opt/artifacts/bin/* /out/linux-gui/"]
