# DNS Seed Setup Guide for Rhino Miner Coin

## What is a DNS Seed?

A DNS seed is a DNS server that returns IP addresses of active Rhino Miner Coin nodes. When a new wallet starts up, it queries DNS seeds to find peers to connect to the network.

## Current DNS Seed Configuration

In `src/chainparams.cpp`, line 134:

```cpp
vSeeds.emplace_back("seed.rhinominer.rocks");
```

This means wallets will query `seed.rhinominer.rocks` for A records containing node IPs.

## Setup Options

You have **3 options** for implementing DNS seeds:

### Option 1: Simple DNS A Records (Quick & Easy) ⭐

**Best for:** Small networks with a few known nodes

**Setup:**
1. Add multiple A records to your DNS:
   ```
   seed.rhinominer.rocks.  IN  A  66.23.199.52
   seed.rhinominer.rocks.  IN  A  <IP_OF_NODE_2>
   seed.rhinominer.rocks.  IN  A  <IP_OF_NODE_3>
   ```

2. Test it:
   ```bash
   dig seed.rhinominer.rocks +short
   # Should return multiple IPs
   ```

**Pros:**
- ✅ Simple to set up
- ✅ No additional software needed
- ✅ Works with any DNS provider

**Cons:**
- ❌ Returns dead nodes (no health checking)
- ❌ Manual updates required
- ❌ No geographic distribution

---

### Option 2: Bitcoin DNS Seeder (Recommended) ⭐⭐⭐

**Best for:** Production networks requiring automatic node discovery

Bitcoin has an open-source DNS seeder that crawls the network and returns only active nodes.

#### Installation

```bash
# Clone the seeder
git clone https://github.com/sipa/bitcoin-seeder.git
cd bitcoin-seeder

# Build it
sudo apt-get install build-essential libboost-all-dev libssl-dev
make

# Run the seeder
./dnsseed -h seed.rhinominer.rocks -n <YOUR_NS_SERVER> -m <YOUR_EMAIL>
```

#### Configuration

1. **Set up NS record:**
   ```
   seed.rhinominer.rocks.  IN  NS  ns1.rhinominer.rocks.
   ns1.rhinominer.rocks.   IN  A   <YOUR_SEEDER_IP>
   ```

2. **Modify for Rhino Miner Coin:**
   
   Edit `bitcoin-seeder/main.cpp`:
   ```cpp
   // Change magic bytes to match RMC
   static const unsigned char pchMessageStart[4] = {0xad, 0x5a, 0xeb, 0x9f};
   
   // Change default port
   #define DEFAULT_PORT 6001
   ```

3. **Rebuild and run:**
   ```bash
   make clean && make
   sudo ./dnsseed -h seed.rhinominer.rocks -n ns1.rhinominer.rocks -m admin@rhinominer.rocks -p 6001
   ```

4. **Keep it running (systemd):**
   ```bash
   sudo nano /etc/systemd/system/rmc-seeder.service
   ```
   
   ```ini
   [Unit]
   Description=Rhino Miner Coin DNS Seeder
   After=network.target

   [Service]
   Type=simple
   User=rmc
   WorkingDirectory=/home/rmc/bitcoin-seeder
   ExecStart=/home/rmc/bitcoin-seeder/dnsseed -h seed.rhinominer.rocks -n ns1.rhinominer.rocks -m admin@rhinominer.rocks -p 6001
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=multi-user.target
   ```
   
   ```bash
   sudo systemctl enable rmc-seeder
   sudo systemctl start rmc-seeder
   sudo systemctl status rmc-seeder
   ```

**Pros:**
- ✅ Automatically finds active nodes
- ✅ Health checks nodes regularly
- ✅ Returns only reachable peers
- ✅ Geographic distribution support

**Cons:**
- ❌ Requires dedicated server
- ❌ Needs modification for custom chains
- ❌ More complex setup

---

### Option 3: Custom Seeder with Cloudflare (Modern) ⭐⭐

**Best for:** Using Cloudflare or other dynamic DNS providers

Build a simple crawler that updates DNS via API:

```python
#!/usr/bin/env python3
# rmc-seed-updater.py

import socket
import requests
import json

# Cloudflare API credentials
CF_API_KEY = "your_api_key"
CF_ZONE_ID = "your_zone_id"
CF_EMAIL = "your@email.com"

# Rhino Miner Coin nodes to check
NODES_TO_CHECK = [
    "66.23.199.52:6001",
    "node2.rhinominer.rocks:6001",
    "node3.rhinominer.rocks:6001"
]

def check_node(ip, port):
    """Check if RMC node is reachable"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        result = sock.connect_ex((ip, port))
        sock.close()
        return result == 0
    except:
        return False

def update_cloudflare_dns(active_ips):
    """Update Cloudflare DNS with active IPs"""
    headers = {
        "X-Auth-Email": CF_EMAIL,
        "X-Auth-Key": CF_API_KEY,
        "Content-Type": "application/json"
    }
    
    # Delete old records
    url = f"https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records"
    response = requests.get(url, headers=headers, params={"name": "seed.rhinominer.rocks"})
    
    for record in response.json()["result"]:
        requests.delete(f"{url}/{record['id']}", headers=headers)
    
    # Add new records
    for ip in active_ips:
        data = {
            "type": "A",
            "name": "seed.rhinominer.rocks",
            "content": ip,
            "ttl": 300
        }
        requests.post(url, headers=headers, json=data)

# Main loop
active_nodes = []
for node in NODES_TO_CHECK:
    ip, port = node.split(":")
    if check_node(ip, int(port)):
        active_nodes.append(ip)
        print(f"✓ {node} is alive")
    else:
        print(f"✗ {node} is dead")

if active_nodes:
    update_cloudflare_dns(active_nodes)
    print(f"\nUpdated DNS with {len(active_nodes)} active nodes")
else:
    print("⚠ No active nodes found!")
```

Run it with cron:
```bash
*/15 * * * * /usr/bin/python3 /home/rmc/rmc-seed-updater.py
```

**Pros:**
- ✅ Works with Cloudflare's free tier
- ✅ Returns only active nodes
- ✅ Easy to customize
- ✅ API-based updates

**Cons:**
- ❌ Requires API keys
- ❌ Rate limits on some providers
- ❌ Need to maintain node list

---

## Alternative: Use Fixed Seeds Instead

If DNS setup is too complex initially, you can rely on **fixed seed nodes** instead:

Edit `src/chainparamsseeds.h` and add hardcoded IPs:

```cpp
static SeedSpec6 pnSeed6_main[] = {
    {{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0x42,0x17,0xc7,0x34}, 6001},
    // Add more IPs in IPv6 format...
};
```

To convert IP to IPv6 format:
```python
import socket
import struct

def ip_to_seed(ip):
    packed = socket.inet_aton(ip)
    return "{" + ",".join([f"0x{b:02x}" for b in [0]*10 + [0xff, 0xff] + list(packed)]) + "}"

print(ip_to_seed("66.23.199.52"))
# Output: {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0x42,0x17,0xc7,0x34}
```

---

## Recommended Setup for Rhino Miner Coin

### Phase 1: Launch (Now)
**Use:** Fixed seeds + Simple DNS A records

1. Add your known nodes to `chainparamsseeds.h`
2. Set up basic DNS A records for `seed.rhinominer.rocks`
3. This gets you started quickly

### Phase 2: Growth (1-3 months)
**Upgrade to:** Bitcoin DNS Seeder

1. Set up dedicated seeder server
2. Configure NS records
3. Automatic node discovery

### Phase 3: Scale (6+ months)
**Add:** Multiple geographic seeds

```cpp
vSeeds.emplace_back("seed.rhinominer.rocks");      // Primary (US)
vSeeds.emplace_back("seed-eu.rhinominer.rocks");   // Europe
vSeeds.emplace_back("seed-asia.rhinominer.rocks"); // Asia
```

---

## Testing Your DNS Seed

### Test DNS Resolution
```bash
# Should return IPs
dig seed.rhinominer.rocks +short

# Should return multiple IPs (if configured)
nslookup seed.rhinominer.rocks
```

### Test from Wallet
```bash
# Start wallet with only DNS seed
./rhinod -dnsseed=1 -addnode=0

# Check connections
./rhino-cli getpeerinfo

# Should see peers from DNS seed
```

### Monitor Seed Health
```bash
# Check how many nodes the seeder knows
curl http://seed.rhinominer.rocks:53/status

# Or check logs
tail -f /var/log/rmc-seeder.log
```

---

## DNS Provider Setup Examples

### Cloudflare
1. Go to DNS settings
2. Add A record:
   - Type: `A`
   - Name: `seed`
   - Content: `66.23.199.52`
   - TTL: `300` (5 minutes)
3. Repeat for each node IP

### AWS Route53
```bash
aws route53 change-resource-record-sets --hosted-zone-id Z1234 --change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "seed.rhinominer.rocks",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{"Value": "66.23.199.52"}]
    }
  }]
}'
```

### DigitalOcean
1. Networking → Domains → rhinominer.rocks
2. Add Record:
   - Hostname: `seed`
   - Will direct to: `66.23.199.52`
   - TTL: `300`

---

## Security Considerations

1. **Don't run seeder on same server as node** - If node goes down, seeder can still return other nodes
2. **Use low TTL (300s)** - Allows quick updates when nodes change
3. **Monitor seeder uptime** - Dead seeder = new wallets can't bootstrap
4. **Have backup seeds** - Add multiple seed domains
5. **Rate limit queries** - Prevent DNS amplification attacks

---

## Troubleshooting

### Seed not resolving
```bash
# Check DNS propagation
dig seed.rhinominer.rocks @8.8.8.8
dig seed.rhinominer.rocks @1.1.1.1
```

### Wallet not connecting to seeds
```bash
# Enable debug logging
./rhinod -debug=net -debug=addrman

# Check what it's doing
tail -f ~/.rhino/debug.log | grep "seed"
```

### Seeder not finding nodes
1. Check firewall allows port 6001
2. Verify nodes are actually running
3. Check seeder has correct magic bytes
4. Review seeder logs for errors

---

## Quick Start Checklist

- [ ] Add `seed.rhinominer.rocks` to DNS with current node IPs
- [ ] Test: `dig seed.rhinominer.rocks +short`
- [ ] Verify node IPs are reachable on port 6001
- [ ] Test wallet can bootstrap from seed
- [ ] Set up monitoring/alerts
- [ ] Plan upgrade to bitcoin-seeder within 3 months

---

Need help? Check:
- Bitcoin Seeder: https://github.com/sipa/bitcoin-seeder
- DNS Best Practices: https://www.ietf.org/rfc/rfc1912.txt
- Rhino Miner Coin GitHub: https://github.com/rhinominer/rhino-miner-coin
