# Rhino Miner Coin - Emission Schedule & Tokenomics

## Summary

- **Initial Block Reward:** 50 RMC
- **Halving Interval:** Every 800,000 blocks (~1.52 years)
- **Tail Emission:** 0.1 RMC per block (permanent)
- **Max Supply:** **INFINITE** (due to tail emission)
- **Practical Supply:** ~79.85M RMC before tail emission begins

## How Tail Emission Works

The tail emission ensures perpetual mining incentives while maintaining scarcity:

```
When halvings reduce reward below 0.1 RMC → permanent 0.1 RMC reward
```

This happens around **block 7,200,000** (~10.6 years after launch).

## Detailed Emission Schedule

### Phase 1: Halving Epochs (First ~10.6 years)

| Epoch | Block Range | Reward | Duration | Coins Minted | Cumulative |
|-------|-------------|--------|----------|--------------|------------|
| 1 | 0 - 800,000 | 50.0000 RMC | 1.52 years | 40,000,000 | 40,000,000 |
| 2 | 800,001 - 1,600,000 | 25.0000 RMC | 1.52 years | 20,000,000 | 60,000,000 |
| 3 | 1,600,001 - 2,400,000 | 12.5000 RMC | 1.52 years | 10,000,000 | 70,000,000 |
| 4 | 2,400,001 - 3,200,000 | 6.2500 RMC | 1.52 years | 5,000,000 | 75,000,000 |
| 5 | 3,200,001 - 4,000,000 | 3.1250 RMC | 1.52 years | 2,500,000 | 77,500,000 |
| 6 | 4,000,001 - 4,800,000 | 1.5625 RMC | 1.52 years | 1,250,000 | 78,750,000 |
| 7 | 4,800,001 - 5,600,000 | 0.7813 RMC | 1.52 years | 625,000 | 79,375,000 |
| 8 | 5,600,001 - 6,400,000 | 0.3906 RMC | 1.52 years | 312,500 | 79,687,500 |
| 9 | 6,400,001 - 7,200,000 | 0.1953 RMC | 1.52 years | 156,250 | 79,843,750 |

**Total after 9 halvings:** ~79,843,750 RMC

### Phase 2: Tail Emission (Block 7,200,001+)

| Period | Reward | Annual Inflation |
|--------|--------|------------------|
| **Forever** | **0.1 RMC/block** | **~0.66%** (initially) |

- **Blocks per year:** ~525,600 (60s blocks)
- **RMC minted per year:** ~52,560 RMC
- **Inflation (Year 11):** ~0.66% annually
- **Inflation (Year 20):** ~0.56% annually
- **Inflation (Year 50):** ~0.42% annually
- **Inflation approaches 0%** over time (but never reaches it)

## Why Tail Emission?

### 1. **Perpetual Mining Incentives**
Without tail emission, mining would eventually rely solely on transaction fees, which can be unpredictable and may not sustain network security.

### 2. **Lost Coin Replacement**
Studies suggest 2-4% of coins are lost annually (forgotten passwords, dead wallets, etc.). Tail emission compensates for this natural attrition.

### 3. **Predictable Security Budget**
Miners always know there's a base reward (0.1 RMC + fees), ensuring network security indefinitely.

### 4. **Soft Inflation**
At 0.1 RMC per block, annual inflation starts at ~0.66% and decreases over time as supply grows, eventually stabilizing near 0%.

## Comparison with Other Coins

| Coin | Max Supply | Tail Emission | Notes |
|------|------------|---------------|-------|
| **Rhino Miner Coin** | **Infinite** | **0.1 RMC/block** | Perpetual incentive |
| Bitcoin | 21M BTC | None | Relies on fees after 2140 |
| Monero | Infinite | 0.6 XMR/block | Similar model |
| Ethereum | Infinite | ~0.5-2% annual | Variable issuance |
| Dogecoin | Infinite | 10,000 DOGE/block | Fixed tail emission |

## Supply Projections

### Circulating Supply Over Time

| Year | Block Height | Circulating Supply | Annual Inflation |
|------|--------------|-------------------|------------------|
| 2026 | 525,600 | ~26,280,000 RMC | - |
| 2027 | 1,051,200 | ~52,560,000 RMC | 100% |
| 2028 | 1,576,800 | ~67,340,000 RMC | 28% |
| 2030 | 2,628,000 | ~73,840,000 RMC | 4.8% |
| 2035 | 5,256,000 | ~78,906,250 RMC | 0.79% |
| 2040 | 7,884,000 | ~80,106,910 RMC | 0.57% |
| 2050 | 13,140,000 | ~80,631,560 RMC | 0.42% |
| 2100 | 39,420,000 | ~82,256,560 RMC | 0.32% |

### Inflation Rate Chart (First 50 Years)

```
Year 1:  ████████████████████████████████████████ 100%
Year 2:  ████████████████ 28%
Year 5:  ██ 4.8%
Year 10: █ 0.66%
Year 20: █ 0.56%
Year 50: █ 0.42%
```

## Code Implementation

Located in `src/validation.cpp`:

```cpp
CAmount GetBlockSubsidy(int nHeight, const Consensus::Params& consensusParams)
{
    int halvings = nHeight / consensusParams.nSubsidyHalvingInterval;
    const CAmount tail_subsidy = COIN / 10;  // 0.1 RMC
    
    // After 64 halvings, use tail emission
    if (halvings >= 64)
        return tail_subsidy;
    
    CAmount nSubsidy = 50 * COIN;
    nSubsidy >>= halvings;  // Right-shift = divide by 2^halvings
    
    // If subsidy < 0.1 RMC, switch to tail emission
    if (nSubsidy < tail_subsidy)
        nSubsidy = tail_subsidy;
        
    return nSubsidy;
}
```

## Economic Impact

### Pros
1. ✅ Guaranteed mining rewards forever
2. ✅ Network security maintained long-term
3. ✅ Compensates for lost coins
4. ✅ Predictable, low inflation
5. ✅ No "fee market pressure" concerns

### Cons
1. ❌ No hard supply cap (may deter some investors)
2. ❌ Slight perpetual dilution (though minimal)
3. ❌ Less "digital gold" narrative

### Net Effect
The tail emission of 0.1 RMC per block is **economically neutral** to slightly deflationary when accounting for:
- Lost/burned coins (~2-4% annually)
- Economic growth requiring more supply
- Transaction fees supplementing rewards

## Frequently Asked Questions

### Q: Is this inflationary?
**A:** Initially yes (~0.66% annually), but inflation decreases over time and approaches 0%. By year 50, it's ~0.42% annually.

### Q: Why not a hard cap like Bitcoin?
**A:** Bitcoin's model is experimental - we don't know if fees alone can sustain security. Tail emission ensures perpetual mining incentives.

### Q: Won't this devalue the coin?
**A:** At 0.1 RMC/block, the inflation is minimal and likely less than the rate of lost coins. The predictability is more valuable than a hard cap.

### Q: When does tail emission start?
**A:** Around block 7,200,000 (~10.6 years after launch, around 2036).

### Q: Can tail emission be changed?
**A:** Only via hard fork with community consensus. It's hardcoded in `src/validation.cpp`.

## Summary Table

| Parameter | Value |
|-----------|-------|
| **Initial Reward** | 50 RMC |
| **Halving Interval** | 800,000 blocks (~1.52 years) |
| **Tail Emission Starts** | Block ~7,200,000 (year ~11) |
| **Tail Emission Rate** | 0.1 RMC per block |
| **Supply Before Tail** | ~79,843,750 RMC |
| **Max Supply** | INFINITE |
| **Long-term Inflation** | ~0.4-0.6% annually (decreasing) |
| **Block Time** | 60 seconds |
| **Blocks per Year** | ~525,600 |

---

*This emission schedule is enforced by consensus and cannot be changed without a network-wide hard fork.*
