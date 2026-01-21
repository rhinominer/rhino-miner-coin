# Getting Started with Rhino Miner Coin

## What is Rhino Miner Coin?

Rhino Miner Coin (RMC) is a CPU-friendly cryptocurrency built on Yespower proof-of-work algorithm. It's designed for fair distribution with no premine, no ICO, and accessible mining for everyone.

## Quick Links

- **Website:** https://rhinominer.rocks
- **Explorer:** https://explorer.rhinominer.rocks
- **GitHub:** https://github.com/rhinominer/rhino-miner-coin
- **Pools:** https://rhinominer.rocks/pools

---

## For Users (Wallet Setup)

### Step 1: Download the Wallet

**Option A: Pre-built Binaries (Easiest)**
```bash
# Download from GitHub releases
https://github.com/rhinominer/rhino-miner-coin/releases

# Or use wget
wget https://github.com/rhinominer/rhino-miner-coin/releases/download/v1.0.0/rhino-miner-coin-linux-x64.tar.gz
```

**Option B: Build from Source**
See [BUILD-INSTRUCTIONS.md](BUILD-INSTRUCTIONS.md)

### Step 2: Install & Run

**Linux:**
```bash
tar -xzf rhino-miner-coin-linux-x64.tar.gz
cd rhino-miner-coin/bin
./rhinod -daemon  # Start daemon
./rhino-cli getblockchaininfo  # Check status
```

**Windows:**
```
1. Extract zip file
2. Run rhino-qt.exe (GUI wallet)
   OR
   Run rhinod.exe (daemon)
```

**macOS:**
```bash
# Open .dmg file
# Drag Rhino Miner Coin to Applications
# Launch from Applications folder
```

### Step 3: Create Your First Address

**GUI Wallet:**
1. Click "Receive" tab
2. Click "Create new receiving address"
3. Label it (e.g., "My Wallet")
4. Copy the address (starts with `R`)

**Command Line:**
```bash
# Create wallet
./rhino-cli createwallet "mywallet"

# Generate address
./rhino-cli getnewaddress

# Get your balance
./rhino-cli getbalance
```

### Step 4: Sync the Blockchain

First sync takes time. Monitor progress:

```bash
# Check sync status
./rhino-cli getblockchaininfo

# Should see:
# "blocks": 350,
# "headers": 350,
# "verificationprogress": 1.0
```

**Sync time:** ~10-30 minutes (depending on current blockchain size)

### Step 5: Receive Your First RMC

Share your address and receive coins!

**Check balance:**
```bash
./rhino-cli getbalance
```

**View transactions:**
```bash
./rhino-cli listtransactions
```

---

## For Miners

### Step 1: Choose Your Mining Method

**Option A: Solo Mining (Not Recommended)**
- Only profitable if you have significant hashpower
- Irregular payouts

**Option B: Pool Mining (Recommended) ⭐**
- Consistent payouts
- Lower variance
- Better for beginners

### Step 2: Get Mining Software

**CPU Miner (yespower):**
```bash
# Download cpuminer-opt with yespower support
git clone https://github.com/JayDDee/cpuminer-opt.git
cd cpuminer-opt
./build.sh
```

### Step 3: Start Mining

**Pool Mining:**
```bash
./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 -u YOUR_RMC_ADDRESS -p x
```

**Parameters:**
- `-a yespower`: Algorithm
- `-o`: Pool address
- `-u`: Your RMC wallet address
- `-p`: Password (usually just `x`)

**Solo Mining:**
```bash
# Edit rhino.conf
echo "rpcuser=user" >> ~/.rhino/rhino.conf
echo "rpcpassword=pass" >> ~/.rhino/rhino.conf
echo "rpcallowip=127.0.0.1" >> ~/.rhino/rhino.conf
echo "server=1" >> ~/.rhino/rhino.conf

# Mine to your address
./cpuminer -a yespower -o http://127.0.0.1:6002 -u user -p pass --coinbase-addr=YOUR_ADDRESS
```

### Step 4: Monitor Your Mining

**Check hashrate:**
```
Look for lines like: [2026-01-16 12:34:56] CPU #0: 1.23 kH/s
```

**Check pool stats:**
```
Visit: https://pool.rhinominer.rocks/workers/YOUR_ADDRESS
```

**Check wallet for payments:**
```bash
./rhino-cli listtransactions
```

---

## For Developers

### Set Up Development Environment

```bash
# Clone repository
git clone https://github.com/rhinominer/rhino-miner-coin.git
cd rhino-miner-coin

# Install dependencies (Ubuntu/Debian)
sudo apt-get install build-essential libtool autotools-dev automake pkg-config \
  libssl-dev libevent-dev bsdmainutils libboost-all-dev libzmq3-dev

# Build
./autogen.sh
./configure --without-gui  # Or with GUI: omit --without-gui
make -j$(nproc)
make install  # Optional

# Run tests
make check
```

### Run Testnet Node

```bash
# Start testnet
./rhinod -testnet -daemon

# Generate test coins
./rhino-cli -testnet createwallet "test"
./rhino-cli -testnet getnewaddress
./rhino-cli -testnet generatetoaddress 120 YOUR_TESTNET_ADDRESS

# Check balance
./rhino-cli -testnet getbalance
```

### Development Workflow

1. **Make changes** to source code
2. **Rebuild:** `make -j$(nproc)`
3. **Test:** `make check`
4. **Run:** `./src/rhinod -regtest`
5. **Iterate**

---

## Configuration

### Create Config File

```bash
# Create directory
mkdir -p ~/.rhino

# Create config
nano ~/.rhino/rhino.conf
```

### Basic Configuration

```ini
# RPC Settings
rpcuser=your_username
rpcpassword=your_secure_password
rpcallowip=127.0.0.1

# Network
listen=1
server=1
daemon=1

# Mining (if solo mining)
gen=0  # Set to 1 to enable CPU mining (not recommended)

# Connections
maxconnections=50

# Transaction indexing (for explorer)
txindex=1

# Logging
debug=0  # Set to 1 for verbose logs
```

### Advanced Options

```ini
# Bandwidth limits
maxuploadtarget=1000  # MB per day

# Memory pool
maxmempool=300  # MB

# Fee settings
minrelaytxfee=0.00001
fallbackfee=0.0001

# Network specific
addnode=66.23.199.52:6001
addnode=seed.rhinominer.rocks:6001
```

---

## Common Operations

### Send RMC

**GUI:**
1. Click "Send" tab
2. Enter recipient address
3. Enter amount
4. Click "Send"

**CLI:**
```bash
./rhino-cli sendtoaddress "RYourRecipientAddress" 10.5
```

### Check Transaction

```bash
# Get transaction details
./rhino-cli gettransaction YOUR_TXID

# Check if confirmed
./rhino-cli getrawtransaction YOUR_TXID 1
```

### Backup Wallet

**GUI:** File → Backup Wallet

**CLI:**
```bash
./rhino-cli backupwallet ~/rmc-backup-$(date +%Y%m%d).dat
```

### Encrypt Wallet

```bash
# Encrypt
./rhino-cli encryptwallet "YourSecurePassphrase"

# Unlock for transactions (timeout in seconds)
./rhino-cli walletpassphrase "YourSecurePassphrase" 600

# Lock
./rhino-cli walletlock
```

---

## Troubleshooting

### Wallet Won't Sync

```bash
# Check connections
./rhino-cli getpeerinfo

# If no peers, add nodes manually
./rhino-cli addnode "66.23.199.52:6001" "add"
./rhino-cli addnode "seed.rhinominer.rocks:6001" "add"

# Restart
./rhino-cli stop
./rhinod -daemon
```

### Transaction Stuck

```bash
# Check mempool
./rhino-cli getmempoolinfo

# Abandon transaction (if not mined)
./rhino-cli abandontransaction YOUR_TXID

# Or increase fee (RBF)
./rhino-cli bumpfee YOUR_TXID
```

### Corrupted Blockchain

```bash
# Stop wallet
./rhino-cli stop

# Reindex blockchain
./rhinod -reindex -daemon

# Or full resync
rm -rf ~/.rhino/blocks ~/.rhino/chainstate
./rhinod -daemon
```

---

## Security Best Practices

### 1. **Encrypt Your Wallet**
```bash
./rhino-cli encryptwallet "StrongPassphrase123!"
```

### 2. **Backup Regularly**
- Backup after every 100 transactions
- Store backups in multiple locations
- Consider hardware wallet for large amounts

### 3. **Use Strong Passwords**
- Minimum 16 characters
- Mix uppercase, lowercase, numbers, symbols
- Use password manager

### 4. **Verify Downloads**
```bash
# Check SHA256 hash
sha256sum rhino-miner-coin-linux-x64.tar.gz
# Compare with official hash on GitHub releases
```

### 5. **Keep Software Updated**
- Subscribe to GitHub releases
- Update within 1 week of new release
- Always check changelog

### 6. **Network Security**
- Don't expose RPC port (6002) to internet
- Use firewall rules
- Only allow localhost connections

---

## Getting Help

### Documentation
- [EMISSION-SCHEDULE.md](EMISSION-SCHEDULE.md) - Tokenomics
- [DNS-SEED-SETUP.md](DNS-SEED-SETUP.md) - Network setup
- [MINING-GUIDE.md](MINING-GUIDE.md) - Mining details
- [API-REFERENCE.md](API-REFERENCE.md) - RPC commands

### Community
- GitHub Issues: https://github.com/rhinominer/rhino-miner-coin/issues
- Website: https://rhinominer.rocks

### Report Bugs
1. Check existing issues first
2. Include error messages
3. Provide steps to reproduce
4. Include wallet version

---

## Next Steps

✅ **You're ready!** Now:

1. **Get mining:** Join a pool and start earning RMC
2. **Stay informed:** Watch GitHub for updates
3. **Spread the word:** Tell others about Rhino Miner Coin
4. **Contribute:** Help improve the project

Welcome to the Rhino Miner Coin community! 🦏⛏️
