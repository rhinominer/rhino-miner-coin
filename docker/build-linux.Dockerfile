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
        python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . /src

RUN find . -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} + \
    && find depends -type f \( -name '*.sh' -o -name '*.ac' -o -name '*.am' -o -name '*.m4' -o -name '*.in' -o -name '*.mk' -o -name 'Makefile' -o -name 'config.*' \) -exec sed -i 's/\r$//' {} + \
    && cd depends \
    && make HOST=x86_64-pc-linux-gnu NO_QT=1 \
    && cd .. \
    && bash ./autogen.sh \
    && CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure --enable-upnp-default --without-gui --disable-tests \
    && make -j"$(nproc)"

RUN mkdir -p /opt/artifacts/bin \
    && cp -a src/rhinod src/rhino-cli src/rhino-tx src/rhino-wallet /opt/artifacts/bin/

CMD ["bash", "-lc", "mkdir -p /out/linux && cp -a /opt/artifacts/bin/* /out/linux/"]
