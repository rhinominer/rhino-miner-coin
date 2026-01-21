# Rhino Miner Coin Mining Guide

Complete guide to mining Rhino Miner Coin (RMC) with CPU.

## Quick Facts

- **Algorithm:** Yespower (N=4096, r=16)
- **Block Time:** 60 seconds
- **Block Reward:** 50 RMC (halves every 800,000 blocks)
- **Difficulty Adjustment:** Every block (Zawy LWMA)
- **Preferred Method:** CPU mining via pool

---

## Why Mine Rhino Miner Coin?

### ✅ **CPU-Friendly**
- No expensive ASICs needed
- No high-end GPUs required
- Mine with regular desktop/laptop CPU

### ✅ **Fair Launch**
- No premine
- No developer allocation
- Everyone starts equal

### ✅ **Sustainable Rewards**
- Tail emission ensures perpetual rewards
- Transaction fees supplement block rewards
- Long-term mining viability

---

## Mining Methods

### Method 1: Pool Mining (Recommended) ⭐⭐⭐

**Pros:**
- Regular, predictable payouts
- Lower variance
- No need to sync full blockchain
- Perfect for beginners

**Cons:**
- Pool fees (usually 1-2%)
- Relies on pool operator
- Slightly lower rewards per block

**When to Use:** Always, unless you have 10%+ of network hashrate

---

### Method 2: Solo Mining

**Pros:**
- Full block reward (50 RMC)
- No pool fees
- Complete independence

**Cons:**
- High variance (may wait days/weeks for a block)
- Requires full node
- Only profitable with significant hashpower

**When to Use:** Only if you have 10%+ of network hashrate

---

## Pool Mining Setup

### Step 1: Install CPU Miner

**Linux:**
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install build-essential libssl-dev libcurl4-openssl-dev libjansson-dev automake

# Clone and build cpuminer-opt
git clone https://github.com/JayDDee/cpuminer-opt.git
cd cpuminer-opt
./build.sh

# Binary will be at: ./cpuminer
```

**Windows:**
```
1. Download pre-built binary:
   https://github.com/JayDDee/cpuminer-opt/releases

2. Extract to C:\mining\

3. Open Command Prompt as Administrator
```

**macOS:**
```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install automake autoconf pkg-config curl

# Build cpuminer-opt
git clone https://github.com/JayDDee/cpuminer-opt.git
cd cpuminer-opt
./build.sh
```

### Step 2: Choose a Pool

| Pool | URL | Fee | Min Payout |
|------|-----|-----|------------|
| **Official Pool** | pool.rhinominer.rocks:3333 | 1% | 1 RMC |

### Step 3: Start Mining

**Basic Command:**
```bash
./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 -u YOUR_RMC_ADDRESS -p x
```

**Optimized Command:**
```bash
./cpuminer \
  -a yespower \
  -o stratum+tcp://pool.rhinominer.rocks:3333 \
  -u YOUR_RMC_ADDRESS \
  -p x \
  -t 4 \
  --cpu-priority 3
```

**Parameters Explained:**
- `-a yespower` - Algorithm
- `-o` - Pool address
- `-u` - Your RMC wallet address
- `-p` - Password (usually `x` or `password`)
- `-t 4` - Use 4 CPU threads (adjust based on your CPU)
- `--cpu-priority 3` - Set CPU priority (1=low, 5=high)

### Step 4: Optimize Performance

**Find Optimal Thread Count:**
```bash
# Test different thread counts
./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 -u YOUR_ADDRESS -p x -t 2
# Wait 5 minutes, note hashrate

./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 -u YOUR_ADDRESS -p x -t 4
# Wait 5 minutes, note hashrate

./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 -u YOUR_ADDRESS -p x -t 8
# Wait 5 minutes, note hashrate

# Use thread count with highest hashrate
```

**CPU-Specific Optimizations:**

**Intel CPUs:**
```bash
./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 \
  -u YOUR_ADDRESS -p x \
  -t $(nproc) \
  --cpu-priority 3 \
  --cpu-affinity 0x5555  # Use even cores
```

**AMD Ryzen:**
```bash
./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 \
  -u YOUR_ADDRESS -p x \
  -t $(($(nproc) - 2)) \
  --cpu-priority 3
```

**Low-Power Mode (Laptops):**
```bash
./cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 \
  -u YOUR_ADDRESS -p x \
  -t 2 \
  --cpu-priority 1  # Low priority
```

---

## Solo Mining Setup

### Step 1: Run Full Node

```bash
# Edit config
nano ~/.rhino/rhino.conf
```

```ini
rpcuser=your_username
rpcpassword=your_secure_password
rpcallowip=127.0.0.1
server=1
daemon=1
txindex=1
```

```bash
# Start node
./rhinod -daemon

# Wait for sync
./rhino-cli getblockchaininfo
```

### Step 2: Mine to Your Address

```bash
# Get mining address
./rhino-cli getnewaddress "mining"

# Start mining
./cpuminer \
  -a yespower \
  -o http://127.0.0.1:6002 \
  -u your_username \
  -p your_secure_password \
  --coinbase-addr=YOUR_MINING_ADDRESS
```

### Step 3: Monitor

```bash
# Check if you found a block
./rhino-cli getblockcount

# Check balance
./rhino-cli getbalance

# View mining info
./rhino-cli getmininginfo
```

---

## Mining Profitability

### Calculate Your Earnings

**Formula:**
```
Daily RMC = (Your Hashrate / Network Hashrate) × Blocks Per Day × Block Reward
```

**Example:**
- Your hashrate: 5 kH/s
- Network hashrate: 500 kH/s (check explorer)
- Blocks per day: 1,440 (60s blocks)
- Block reward: 50 RMC

```
Daily RMC = (5 / 500) × 1,440 × 50 = 720 RMC/day
```

### Expected Hashrates

| CPU | Threads | Hashrate | Daily RMC (est.) |
|-----|---------|----------|------------------|
| Intel i3-8100 | 4 | ~2 kH/s | ~288 RMC |
| Intel i5-9600K | 6 | ~4 kH/s | ~576 RMC |
| Intel i7-9700K | 8 | ~6 kH/s | ~864 RMC |
| AMD Ryzen 5 3600 | 12 | ~8 kH/s | ~1,152 RMC |
| AMD Ryzen 7 5800X | 16 | ~12 kH/s | ~1,728 RMC |
| AMD Ryzen 9 5950X | 32 | ~22 kH/s | ~3,168 RMC |

*Values are estimates. Actual results vary based on network difficulty.*

### Check Current Profitability

**1. Get Network Hashrate:**
```
Visit: https://explorer.rhinominer.rocks
Look for: "Network Hashrate"
```

**2. Calculate Your Share:**
```
Your % = (Your Hashrate / Network Hashrate) × 100
```

**3. Estimate Earnings:**
```
Daily RMC = Your % × 1,440 blocks × 50 RMC
```

**4. Factor in Costs:**
```
Power consumption × Hours × Cost per kWh = Daily power cost
```

---

## Mining Scripts

### Linux Auto-Restart Script

```bash
#!/bin/bash
# mining-auto-restart.sh

POOL="stratum+tcp://pool.rhinominer.rocks:3333"
ADDRESS="YOUR_RMC_ADDRESS"
THREADS=4

while true; do
    echo "Starting miner..."
    ./cpuminer -a yespower -o $POOL -u $ADDRESS -p x -t $THREADS --cpu-priority 3
    
    echo "Miner stopped. Restarting in 10 seconds..."
    sleep 10
done
```

```bash
chmod +x mining-auto-restart.sh
./mining-auto-restart.sh
```

### Systemd Service (Linux)

```bash
sudo nano /etc/systemd/system/rmc-miner.service
```

```ini
[Unit]
Description=Rhino Miner Coin CPU Miner
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/home/your_username/cpuminer-opt
ExecStart=/home/your_username/cpuminer-opt/cpuminer -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 -u YOUR_ADDRESS -p x -t 4
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable rmc-miner
sudo systemctl start rmc-miner
sudo systemctl status rmc-miner

# View logs
journalctl -u rmc-miner -f
```

### Windows Batch Script

```batch
@echo off
:start
cpuminer.exe -a yespower -o stratum+tcp://pool.rhinominer.rocks:3333 -u YOUR_ADDRESS -p x -t 4
echo Miner stopped. Restarting in 10 seconds...
timeout /t 10
goto start
```

Save as `mine.bat` and run.

---

## Monitoring & Optimization

### Monitor Hashrate

**In Miner Output:**
```
[2026-01-16 12:34:56] CPU #0: 1.23 kH/s
[2026-01-16 12:34:56] Total: 4.92 kH/s
```

**Pool Dashboard:**
```
Visit: https://pool.rhinominer.rocks/workers/YOUR_ADDRESS
```

**API Call:**
```bash
curl -s https://pool.rhinominer.rocks/api/worker_stats?YOUR_ADDRESS
```

### Temperature Monitoring

**Linux:**
```bash
# Install sensors
sudo apt-get install lm-sensors
sudo sensors-detect

# View temps
watch -n 1 sensors
```

**Windows:**
- Use HWMonitor or Core Temp
- Download from: https://www.cpuid.com/softwares/hwmonitor.html

### Performance Tuning

**1. Disable CPU Throttling (Linux):**
```bash
# Set performance mode
sudo cpupower frequency-set -g performance

# Verify
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Should say "performance"
```

**2. Increase Process Priority:**
```bash
sudo nice -n -10 ./cpuminer -a yespower -o ... (other params)
```

**3. Disable SMT/Hyper-Threading:**
```bash
# Often improves hashrate
echo off | sudo tee /sys/devices/system/cpu/smt/control
```

**4. Overclock CPU (Advanced):**
- Increase CPU multiplier in BIOS
- Monitor temperatures carefully
- Test stability with stress tests

---

## Troubleshooting

### Low Hashrate

**Problem:** Hashrate lower than expected

**Solutions:**
1. Check CPU usage: `top` (Linux) or Task Manager (Windows)
2. Close other programs
3. Adjust thread count
4. Disable CPU throttling
5. Check temperatures (thermal throttling?)

### High Reject Rate

**Problem:** Many rejected shares

**Solutions:**
1. Check internet connection stability
2. Reduce threads (less CPU load = faster share submission)
3. Try different pool server
4. Update miner software

### Miner Crashes

**Problem:** Miner keeps stopping

**Solutions:**
1. Update cpuminer to latest version
2. Reduce thread count
3. Check RAM usage (maybe running out?)
4. Check CPU temperatures
5. Test with `-t 1` (single thread)

### No Accepted Shares

**Problem:** Mining but no shares accepted

**Solutions:**
1. Verify wallet address is correct
2. Check pool is online: `ping pool.rhinominer.rocks`
3. Try different pool port
4. Check firewall isn't blocking stratum

---

## Best Practices

### ✅ DO:
- Monitor temperatures regularly
- Use auto-restart scripts
- Keep miner software updated
- Join a pool (unless you have huge hashrate)
- Back up your wallet
- Verify payouts regularly

### ❌ DON'T:
- Mine on laptops without cooling pads
- Use all CPU threads (leave 1-2 for system)
- Run miner on public/shared computers
- Mine to exchange addresses (use personal wallet)
- Overclock without proper cooling
- Leave miner unmonitored for weeks

---

## Advanced Topics

### GPU Mining

**Status:** Not currently supported
- Yespower is designed for CPUs
- GPU implementations exist but are not significantly faster
- Focus on CPU mining for best results

### Browser Mining

**Status:** In development
- WebAssembly implementation planned
- Will allow mining via web browser
- Lower hashrate but highly accessible

### Mining Pool Operators

Want to run your own pool? See:
- [server/README.md](../server/README.md) - Pool setup guide
- [server/pool.config.js](../server/pool.config.js) - Configuration reference

---

## Mining Economics

### Current Economics (Launch Era)

- **Block Reward:** 50 RMC
- **Blocks Per Day:** ~1,440
- **Daily Emission:** ~72,000 RMC
- **Network Hashrate:** Check explorer

### Future Changes

| Year | Block | Reward | Daily Emission |
|------|-------|--------|----------------|
| 2026 | 0 | 50 RMC | 72,000 RMC |
| 2028 | 800,000 | 25 RMC | 36,000 RMC |
| 2030 | 1,600,000 | 12.5 RMC | 18,000 RMC |
| 2032 | 2,400,000 | 6.25 RMC | 9,000 RMC |
| 2036+ | 7,200,000 | 0.1 RMC | 144 RMC (tail emission) |

See [EMISSION-SCHEDULE.md](EMISSION-SCHEDULE.md) for full details.

---

## Getting Help

### Documentation
- [GETTING-STARTED.md](GETTING-STARTED.md) - Wallet setup
- [EMISSION-SCHEDULE.md](EMISSION-SCHEDULE.md) - Tokenomics
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

### Community
- GitHub: https://github.com/rhinominer/rhino-miner-coin
- Website: https://rhinominer.rocks

### Report Mining Issues
1. Include miner version
2. Include command used
3. Include error messages
4. Include CPU model and thread count

---

## Summary

**Quick Start Checklist:**

- [ ] Install cpuminer-opt
- [ ] Get RMC wallet address
- [ ] Choose mining pool
- [ ] Run miner with optimal thread count
- [ ] Monitor hashrate and temperatures
- [ ] Set up auto-restart script
- [ ] Verify payouts in wallet

**Happy Mining!** 🦏⛏️

---

*For questions or support, visit https://rhinominer.rocks*
