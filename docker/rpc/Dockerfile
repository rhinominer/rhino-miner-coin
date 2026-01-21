FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        autotools-dev \
        autoconf \
        libtool \
        pkg-config \
        libdb5.3-dev \
        libdb5.3++-dev \
        libssl-dev \
        libboost-all-dev \
        libevent-dev \
        libzmq3-dev \
        ca-certificates \
        git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . /src

RUN find /src -type f -print0 | xargs -0 sed -i 's/\r$//' \
    && bash /src/autogen.sh \
    && ./configure --without-gui --with-incompatible-bdb \
    && make -j"$(nproc)" \
    && make install

COPY docker/rpc/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN useradd -m -u 10001 rhino
USER rhino

VOLUME ["/data"]
EXPOSE 9981 9982

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
