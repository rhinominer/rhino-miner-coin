FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

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
        g++-mingw-w64-x86-64 \
        bison \
        flex \
        gperf \
        python3 \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix \
    && update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

WORKDIR /src
COPY . /src

RUN find . -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} + \
    && find depends -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} + \
    && PATH=$(echo "$PATH" | sed -e 's|:/mnt.*||g') \
    && cd depends \
    && make HOST=x86_64-w64-mingw32 DOWNLOAD_RETRIES=10 DOWNLOAD_CONNECT_TIMEOUT=60 \
    && cd .. \
    && bash ./autogen.sh \
    && CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure --prefix=/ --disable-tests --with-gui=qt5 \
    && make -j"$(nproc)"

RUN mkdir -p /opt/artifacts/bin \
    && cp -a src/rhinod.exe src/rhino-cli.exe src/rhino-tx.exe src/rhino-wallet.exe src/qt/rhino-qt.exe /opt/artifacts/bin/

CMD ["bash", "-lc", "mkdir -p /out/windows && cp -a /opt/artifacts/bin/* /out/windows/"]
