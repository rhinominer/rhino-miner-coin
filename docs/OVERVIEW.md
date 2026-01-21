# Rhino Miner Coin - Project Overview

## Quick Facts

- **Name:** Rhino Miner Coin
- **Ticker:** RMC  
- **Algorithm:** Yespower (CPU-friendly)
- **Block Time:** 60 seconds
- **Initial Reward:** 50 RMC
- **Halving:** Every 800,000 blocks (~1.52 years)
- **Max Supply:** INFINITE (0.1 RMC tail emission)
- **Genesis:** January 14, 2026
- **Network:** Mainnet launched

## Links

- **Website:** https://rhinominer.rocks
- **Explorer:** https://explorer.rhinominer.rocks  
- **GitHub:** https://github.com/rhinominer/rhino-miner-coin
- **Ports:** Mainnet P2P: 6001, RPC: 6002

## Technology Stack

### Core
- **Base:** Bitcoin Core fork (via Yeten)
- **Consensus:** Proof-of-Work (Yespower)
- **Address Format:** Base58 (prefix `R`) and Bech32 (`rh`)

### Mining
- **Algorithm:** Yespower N=4096, r=16
- **Difficulty Adjustment:** Every block (based on last 144 blocks)
- **CPU-Friendly:** Designed for browser and CPU mining
- **No Premine:** Fair launch, no ICO

### Network
- **P2P Port:** 6001 (mainnet), 6003 (testnet)
- **RPC Port:** 6002 (mainnet), 6004 (testnet)  
- **Magic Bytes:** 0xad5aeb9f
- **Genesis Hash:** `3f350f85287a47ed10b23efaa77a6c6f388bbdf28f342b79cf4ef931978639f2`

## Project Structure

```
rhino-miner-coin/     # Core wallet & daemon
├── src/              # C++ source code
├── doc/              # Documentation
└── contrib/          # Tools and utilities

server/               # Mining pool
├── lib/              # Pool logic
├── pool.config.js    # Pool configuration
└── docker-compose.yml

explorer/             # Block explorer
├── lib/              # Explorer logic
└── settings.json     # Explorer config

web/                  # Frontend website
└── src/              # Vue.js application
```

## Key Features

### 1. Fair Distribution
- No premine or developer allocation
- No ICO or token sale
- Pure Proof-of-Work mining from genesis

### 2. CPU-Friendly Mining
- Yespower algorithm optimized for CPUs
- Browser mining capable
- Accessible to everyday users

### 3. Sustainable Emission
- Halving every ~1.52 years
- Predictable supply schedule
- Long-term incentive structure

### 4. Community-Driven
- Open source (MIT License)
- Transparent development
- Community governance

## Getting Started

### For Users
1. Download wallet from GitHub releases
2. Sync blockchain
3. Create new address
4. Start receiving RMC

### For Miners
1. Download miner (CPU/GPU)
2. Point to pool: `stratum+tcp://pool.rhinominer.rocks:3333`
3. Use your RMC address as username
4. Start mining!

### For Developers
1. Clone repository
2. Build from source (see README.md)
3. Run tests
4. Submit pull requests

## Technical Specifications

| Parameter | Value |
|-----------|-------|
| Block Time | 60 seconds |
| Block Reward (initial) | 50 RMC |
| Halving Interval | 800,000 blocks |
| Max Supply | INFINITE (tail emission) |
| Difficulty Retarget | Every block (DGW) |
| SegWit | Activated |
| RPC Port | 6002 |
| P2P Port | 6001 |

## Emission Schedule

| Epoch | Blocks | Reward | Duration | Total Emission |
|-------|--------|--------|----------|----------------|
| 1 | 0 - 800,000 | 50 RMC | ~1.52 years | 40,000,000 RMC |
| 2 | 800,001 - 1,600,000 | 25 RMC | ~1.52 years | 20,000,000 RMC |
| 3 | 1,600,001 - 2,400,000 | 12.5 RMC | ~1.52 years | 10,000,000 RMC |
| 4 | 2,400,001 - 3,200,000 | 6.25 RMC | ~1.52 years | 5,000,000 RMC |
| ... | ... | ... | ... | ... |

## Development Roadmap

### Phase 1: Launch (Q1 2026) ✅
- [x] Genesis block mined
- [x] Mainnet launched
- [x] Block explorer live
- [x] Mining pool operational

### Phase 2: Growth (Q2 2026)
- [ ] Exchange listings
- [ ] Mobile wallet
- [ ] Browser mining plugin
- [ ] Community expansion

### Phase 3: Ecosystem (Q3-Q4 2026)
- [ ] Additional pools
- [ ] Payment processors
- [ ] Merchant adoption
- [ ] DeFi integrations

## Contributing

We welcome contributions! Please see:
- [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines
- [GitHub Issues](https://github.com/rhinominer/rhino-miner-coin/issues) for tasks
- Community channels for discussions

## License

Rhino Miner Coin is released under the MIT License.
Copyright (C) 2026 Rhino Miner Coin Core Team

Based on Yeten (C) 2017-2025 Yeten Core Team  
Based on Bitcoin Core (C) 2009-2026 Bitcoin Core Developers

## Support

- **Issues:** https://github.com/rhinominer/rhino-miner-coin/issues
- **Website:** https://rhinominer.rocks
- **Explorer:** https://explorer.rhinominer.rocks

---

*Last Updated: January 2026*
