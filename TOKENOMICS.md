# Rhino Miner Coin Tokenomics

## Overview
- **Name:** Rhino Miner Coin
- **Ticker:** `RMC`
- **Consensus:** Proof-of-Work (Yespower)
- **Algorithm:** `yespower` (`N=4096`, `r=16`, `pers=""`)
- **Block time target:** 60 seconds
- **Genesis:** `2026-01-14 00:00:00 UTC` (hash `3f350f85287a47ed10b23efaa77a6c6f388bbdf28f342b79cf4ef931978639f2`)

## Monetary Policy
- **Initial block subsidy:** 50 RMC per block
- **Halving interval:** every 800,000 blocks (~1.52 years)
- **Tail emission:** 0.1 RMC per block once halvings drop below 0.1 RMC
- **Max supply:** none (infinite, due to tail emission)
- **Practical supply before tail emission:** ~79,843,750 RMC
- **Blocks per year:** ~525,600 (60s target)

## Distribution
- **No premine** and **no ICO**
- **No developer fee**
- **PoW from genesis** with emissions enforced by consensus

## Annual Burn Program (Operational)
- **Burn source:** Funds collected over the year (pool fees, miner/app fees, donations, etc.) are sent to a dedicated burn-holding wallet.
- **Burn cadence:** Once per year, the accumulated balance in the burn-holding wallet is permanently burned.
- **Notes:** This is an operational policy (not consensus) and can be audited on-chain by tracking the burn-holding wallet and the annual burn transaction(s).

## Implementation Notes
- **Halving interval** is defined in `src/chainparams.cpp`.
- **Subsidy and tail emission** are enforced in `src/validation.cpp`.
