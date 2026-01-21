Rhino Miner Coin Core
=====================

Website: https://rhinominer.rocks
Repo: https://github.com/rhinominer/rhino-miner-coin
Explorer: https://explorer.rhinominer.rocks

Rhino Miner Coin is a CPU-focused cryptocurrency with a browser-mining goal and a community-first mindset.
No premine. No ICO. CPU-friendly by design.

Logo assets: text-only placeholders for now. Drop-in assets will be wired later.

Monetary policy
---------------

- Target block time: 60 seconds
- Halving interval: 800,000 blocks (~1.52 years)
- Starting subsidy: 50.0 RMC
- Tail emission: 0.1 RMC per block once halvings reduce subsidy below 0.1
- Max supply: none (tail emission continues indefinitely)

Development fee: none

Final genesis values (Rhino Miner Coin)
--------------------------------------

Mainnet/testnet:
- nTime: 1768348800
- nBits: 0x1e3fffff
- nNonce: 158404
- MerkleRoot: 4cb0701f2cd0765b722b28c55714afcd158322ccfe06073a92fbc293f2b0436e
- BlockHash: 3f350f85287a47ed10b23efaa77a6c6f388bbdf28f342b79cf4ef931978639f2

Regtest:
- nTime: 1768348800
- nBits: 0x207fffff
- nNonce: 1
- MerkleRoot: 4cb0701f2cd0765b722b28c55714afcd158322ccfe06073a92fbc293f2b0436e
- BlockHash: c19456a4eb41aef4ab8d1562395c29d7aa3e43683370294c424fb14eeec03d31

Docker: genesis generation
--------------------------

Build:

```
docker build -t rmc-genesis -f docker/genesis/Dockerfile .
```

Run (mines if yespower is available in the image):

```
docker run --rm rmc-genesis \
  --timestamp "Rhino Miner Coin genesis 2026-01-14" \
  --pubkey 04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f \
  --time 1768348800 --bits 0x1e3fffff
```
This image compiles a small genesis miner against the bundled yespower
implementation (no PyPI dependency).

Testnet funding
---------------

After updating genesis and building:

```
rhino-qt -testnet
rhino-cli -testnet createwallet "dev"
rhino-cli -testnet getnewaddress
rhino-cli -testnet generatetoaddress 120 <ADDRESS>
```

Docker: RPC node
----------------

Build:

```
docker build -t rmc-rpc -f docker/rpc/Dockerfile .
```

Run (mainnet):

```
docker run --rm -p 6002:6002 -p 6001:6001 \
  -e RPC_USER=rmc -e RPC_PASSWORD=rmc \
  -v rmc-data:/data rmc-rpc
```

Run (testnet):

```
docker run --rm -p 6004:6004 -p 6003:6003 \
  -e NETWORK=testnet -e RPC_USER=rmc -e RPC_PASSWORD=rmc \
  -v rmc-testnet:/data rmc-rpc
```

Docker: binary builds (Linux + Windows)
---------------------------------------

Build Linux binaries:

```
docker build -f docker/build-linux.Dockerfile -t rmc-linux .
docker run --rm -v ${PWD}/build:/out rmc-linux
```

Build Windows binaries (mingw-w64 cross-compile):

```
docker build -f docker/build-windows.Dockerfile -t rmc-win .
docker run --rm -v ${PWD}/build:/out rmc-win
```

Artifacts will be staged under `build/linux` and `build/windows` on the host.

Build (Ubuntu 20.04+)
--------------------

```
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install git
sudo apt-get install build-essential
sudo apt-get install libtool autotools-dev autoconf
sudo apt-get install libssl-dev
sudo apt-get install libboost-all-dev
sudo apt-get install pkg-config
sudo apt-get install libevent-dev
sudo apt-get install libzmq3-dev

git clone https://github.com/rhinominer/rhino-miner-coin.git
cd rhino-miner-coin
./autogen.sh
./configure --enable-upnp-default --without-gui
make -j 4
```

Config
------

Config file: `rhino.conf`
Data dir: `~/.rhino/`

Example:

```
server=1
daemon=1
gen=0
rpcuser=user
rpcpassword=your_password
rpcallowip=127.0.0.1
```

Resources
---------

Explorer: https://explorer.rhinominer.rocks
Website: https://rhinominer.rocks
GitHub: https://github.com/rhinominer/rhino-miner-coin

License
-------

Rhino Miner Coin Core is released under the terms of the MIT license. See [COPYING](COPYING) for more
information or see https://opensource.org/licenses/MIT.
